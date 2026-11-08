import { BadRequestException, ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { DataSource, EntityManager, In } from 'typeorm';
import { AuthUser, assertSameBranch } from '../../common/security/security';
import { PartRequestDao } from '../../dao/part-request.dao';
import { RepairDao } from '../../dao/repair.dao';
import { AssignMechanicDto, UpdateProgressDto, VerifyCompletionDto } from '../../dto/dto';
import {
  Appointment, Inventory, InventoryTransaction, PartRequest, PartReservation, RepairNote, RepairOrder, RepairTask, Staff, TaskStatus, User,
} from '../../model/entities';
import { NotificationService } from '../common/notification.service';

/** Allowed task transitions for UC29 (DONE is final). */
const TRANSITIONS: Record<TaskStatus, TaskStatus[]> = {
  TODO: ['DOING', 'BLOCKED'],
  DOING: ['DOING', 'BLOCKED', 'DONE'],
  BLOCKED: ['DOING', 'BLOCKED'],
  DONE: [],
};

@Injectable()
export class RepairService {
  constructor(
    private readonly ds: DataSource,
    private readonly dao: RepairDao,
    private readonly requestDao: PartRequestDao,
    private readonly notifier: NotificationService,
  ) {}

  /* ================================================================ queries */
  listOrders(user: AuthUser, status?: string) {
    if (user.role === 'MECHANIC') return this.dao.listOrders({ mechanicStaffId: user.staffId, status });
    return this.dao.listOrders({ branchId: user.role === 'SYS_ADMIN' ? null : user.branchId, status });
  }

  async getOrder(user: AuthUser, id: number) {
    const header = await this.dao.orderHeader(id);
    if (!header) throw new NotFoundException('Không tìm thấy lệnh sửa chữa');
    assertSameBranch(user, header.branchId);
    const tasks = await this.dao.tasksOfOrder(id);
    if (user.role === 'MECHANIC' && !tasks.some((t: { mechanicId: number }) => t.mechanicId === user.staffId)) {
      throw new ForbiddenException('Bạn không được phân công cho lệnh sửa chữa này');
    }
    const [parts, notes, requests] = await Promise.all([
      this.dao.partItemsOfOrder(id), this.dao.notesOfOrder(id), this.requestDao.list({ repairOrderId: id }),
    ]);
    return { ...header, tasks, parts, notes, requests };
  }

  async mechanicsFor(user: AuthUser, orderId: number) {
    const header = await this.dao.orderHeader(orderId);
    if (!header) throw new NotFoundException('Không tìm thấy lệnh sửa chữa');
    assertSameBranch(user, header.branchId);
    return this.dao.mechanicsOfBranch(header.branchId);
  }

  myTasks(user: AuthUser) {
    return this.dao.tasksOfMechanic(user.staffId!);
  }

  /* ================================================================ UC27 Assign Mechanic */
  async assignMechanic(user: AuthUser, orderId: number, dto: AssignMechanicDto) {
    await this.ds.transaction(async (m) => {
      const ro = await this.lockOrder(m, orderId);
      assertSameBranch(user, ro.branchId);                                                      // BR48
      if (!['NEW', 'ASSIGNED'].includes(ro.status)) {
        throw new ConflictException(`Lệnh đang ở trạng thái ${ro.status}, chỉ phân công khi lệnh là NEW hoặc ASSIGNED`);
      }
      const mech = await m.getRepository(Staff).findOneBy({ staffId: dto.mechanicId });
      const mechUser = mech ? await m.getRepository(User).findOneBy({ userId: mech.userId }) : null;
      if (!mech || mech.position !== 'MECHANIC' || mech.status !== 'ACTIVE' || mechUser?.status !== 'ACTIVE') {
        throw new BadRequestException('Nhân viên được chọn không phải thợ máy đang hoạt động');      // BR22
      }
      if (mech.branchId !== ro.branchId) throw new BadRequestException('Thợ máy phải thuộc cùng chi nhánh với lệnh sửa chữa');

      const taskRepo = m.getRepository(RepairTask);
      const all = await taskRepo.find({ where: { repairOrderId: orderId }, lock: { mode: 'pessimistic_write' } });
      if (!all.length) throw new ConflictException('Lệnh sửa chữa chưa có hạng mục công việc nào');
      const targets = dto.taskIds?.length ? all.filter((t) => dto.taskIds!.includes(t.taskId)) : all.filter((t) => t.status === 'TODO');
      if (dto.taskIds?.length && targets.length !== dto.taskIds.length) throw new BadRequestException('Có hạng mục không thuộc lệnh sửa chữa này');
      if (!targets.length) throw new ConflictException('Không còn hạng mục nào chưa bắt đầu để phân công');
      if (targets.some((t) => t.status !== 'TODO')) throw new ConflictException('Chỉ phân công lại được hạng mục chưa bắt đầu (TODO)');

      await taskRepo.update({ taskId: In(targets.map((t) => t.taskId)) }, { mechanicId: mech.staffId });
      ro.status = 'ASSIGNED';
      ro.updatedAt = new Date();
      await m.getRepository(RepairOrder).save(ro);

      await this.notifier.notify(m, [mech.userId], 'Bạn được phân công lệnh sửa chữa',
        `Lệnh ${ro.roCode}: ${targets.map((t) => t.taskName).join(', ')}`, 'REPAIR_ORDER', ro.repairOrderId);
      await this.notifier.audit(m, user.userId, 'MECHANIC_ASSIGNED', 'repair_orders', ro.repairOrderId,
        { mechanicId: mech.staffId, taskIds: targets.map((t) => t.taskId) });
    });
    return this.getOrder(user, orderId);
  }

  /* ================================================================ UC29 Update Repair Progress */
  async updateProgress(user: AuthUser, taskId: number, dto: UpdateProgressDto) {
    let orderId = 0;
    await this.ds.transaction(async (m) => {
      const taskRepo = m.getRepository(RepairTask);
      const task = await taskRepo.findOne({ where: { taskId }, lock: { mode: 'pessimistic_write' } });
      if (!task) throw new NotFoundException('Không tìm thấy hạng mục công việc');
      if (task.mechanicId !== user.staffId) throw new ForbiddenException('Bạn không phải thợ được phân công cho hạng mục này'); // BR22
      const ro = await this.lockOrder(m, task.repairOrderId);
      orderId = ro.repairOrderId;
      if (!['ASSIGNED', 'IN_PROGRESS', 'WAITING_PARTS'].includes(ro.status)) {
        throw new ConflictException(`Lệnh đang ở trạng thái ${ro.status}, không thể cập nhật tiến độ`);
      }
      if (!TRANSITIONS[task.status].includes(dto.status)) {
        throw new ConflictException(`Không thể chuyển hạng mục từ ${task.status} sang ${dto.status}`);
      }
      let pct = dto.progressPercent;
      if (dto.status === 'DONE') pct = 100;
      else if (pct >= 100) throw new BadRequestException('Tiến độ 100% thì hãy chọn trạng thái DONE');
      if (pct < task.progressPercent) throw new BadRequestException(`Tiến độ không được giảm (hiện tại ${task.progressPercent}%)`);
      if (dto.status === 'BLOCKED' && task.status !== 'BLOCKED' && !dto.note?.trim()) throw new BadRequestException('Vui lòng ghi chú lý do tạm dừng (ví dụ: thiếu phụ tùng)');

      const now = new Date();
      const wasBlocked = task.status === 'BLOCKED';
      task.status = dto.status;
      task.progressPercent = pct;
      if (dto.laborHours !== undefined) task.laborHours = dto.laborHours;
      if (!task.startedAt) task.startedAt = now;
      task.finishedAt = dto.status === 'DONE' ? now : null;
      await taskRepo.save(task);
      if (dto.note?.trim()) {
        await m.getRepository(RepairNote).insert({ repairOrderId: ro.repairOrderId, taskId, authorId: user.staffId!, content: dto.note.trim() });
      }

      // derive order status from its tasks (BR24 – COMPLETED only through UC32)
      const tasks = await taskRepo.findBy({ repairOrderId: ro.repairOrderId });
      const anyDoing = tasks.some((t) => t.status === 'DOING');
      const anyBlocked = tasks.some((t) => t.status === 'BLOCKED');
      ro.status = anyBlocked && !anyDoing ? 'WAITING_PARTS' : 'IN_PROGRESS';
      if (!ro.startedAt) ro.startedAt = now;
      ro.updatedAt = now;
      await m.getRepository(RepairOrder).save(ro);

      if (dto.status === 'BLOCKED' && !wasBlocked) {                                   // 29.A1 alert receptionist
        const receptionists = await this.dao.staffUserIds(m, ro.branchId, ['RECEPTIONIST', 'BRANCH_MANAGER']);
        await this.notifier.notify(m, receptionists, 'Hạng mục chờ phụ tùng',
          `Lệnh ${ro.roCode} – "${task.taskName}": ${dto.note?.trim()}`, 'REPAIR_ORDER', ro.repairOrderId);
      }
      await this.notifier.audit(m, user.userId, 'REPAIR_PROGRESS_UPDATED', 'repair_tasks', taskId, { status: dto.status, progressPercent: pct });
    });
    return this.getOrder(user, orderId);
  }

  /* ================================================================ UC32 step 1 – mechanic marks the order COMPLETED */
  async completeOrder(user: AuthUser, orderId: number) {
    await this.ds.transaction(async (m) => {
      const ro = await this.lockOrder(m, orderId);
      const tasks = await m.getRepository(RepairTask).findBy({ repairOrderId: orderId });
      if (user.role === 'MECHANIC' && !tasks.some((t) => t.mechanicId === user.staffId)) {
        throw new ForbiddenException('Bạn không được phân công cho lệnh sửa chữa này');
      }
      assertSameBranch(user, ro.branchId);
      if (ro.status !== 'IN_PROGRESS') throw new ConflictException(`Chỉ hoàn thành được lệnh đang IN_PROGRESS (hiện tại: ${ro.status})`);
      const unfinished = tasks.filter((t) => t.status !== 'DONE');
      if (unfinished.length) {                                                                          // BR24
        throw new ConflictException(`Còn ${unfinished.length} hạng mục chưa xong: ${unfinished.map((t) => t.taskName).join(', ')}`);
      }
      const openRequests = await m.getRepository(PartRequest).countBy({ repairOrderId: orderId, status: In(['PENDING', 'PARTIALLY_ISSUED']) });
      if (openRequests) throw new ConflictException('Còn yêu cầu phụ tùng chưa được xuất kho, chưa thể hoàn thành lệnh');

      // release reservations that were never issued (parts not used)
      const leftovers = await m.getRepository(PartReservation).find({ where: { repairOrderId: orderId, status: 'RESERVED' }, lock: { mode: 'pessimistic_write' } });
      for (const r of leftovers) {
        const inv = await m.getRepository(Inventory).findOne({ where: { inventoryId: r.inventoryId }, lock: { mode: 'pessimistic_write' } });
        if (!inv) continue;
        inv.quantityReserved -= r.quantity;
        inv.version += 1;
        inv.updatedAt = new Date();
        await m.getRepository(Inventory).save(inv);
        r.status = 'RELEASED';
        r.updatedAt = new Date();
        await m.getRepository(PartReservation).save(r);
        await m.getRepository(InventoryTransaction).insert({
          inventoryId: inv.inventoryId, transactionType: 'RELEASE', quantity: -r.quantity, balanceAfter: inv.quantityOnHand,
          referenceType: 'REPAIR_ORDER', referenceId: orderId, performedBy: user.staffId!,
        });
      }

      ro.status = 'COMPLETED';
      ro.completedAt = new Date();
      ro.updatedAt = new Date();
      await m.getRepository(RepairOrder).save(ro);
      const receptionists = await this.dao.staffUserIds(m, ro.branchId, ['RECEPTIONIST']);
      await this.notifier.notify(m, receptionists, 'Lệnh sửa chữa đã hoàn thành', `Lệnh ${ro.roCode} chờ lễ tân kiểm tra và xác nhận.`,
        'REPAIR_ORDER', ro.repairOrderId);
      await this.notifier.audit(m, user.userId, 'REPAIR_COMPLETED', 'repair_orders', ro.repairOrderId, { releasedReservations: leftovers.length });
    });
    return this.getOrder(user, orderId);
  }

  /* ================================================================ UC32 steps 2–3 – receptionist verifies and hands over to cashier */
  async verifyCompletion(user: AuthUser, orderId: number, dto: VerifyCompletionDto) {
    await this.ds.transaction(async (m) => {
      const ro = await this.lockOrder(m, orderId);
      assertSameBranch(user, ro.branchId);
      if (ro.status !== 'COMPLETED') throw new ConflictException('Lệnh sửa chữa chưa được thợ đánh dấu COMPLETED');
      const appointmentId = await this.dao.appointmentIdOfOrder(orderId, m);
      const apRepo = m.getRepository(Appointment);
      const ap = await apRepo.findOne({ where: { appointmentId }, lock: { mode: 'pessimistic_write' } });
      if (!ap) throw new NotFoundException('Không tìm thấy lịch hẹn của lệnh sửa chữa');
      if (ap.status === 'WAITING_PAYMENT') throw new ConflictException('Lệnh này đã được xác nhận và chuyển thu ngân trước đó');
      if (ap.status !== 'IN_SERVICE') throw new ConflictException(`Lịch hẹn đang ở trạng thái ${ap.status}, không thể chuyển thu ngân`);
      ap.status = 'WAITING_PAYMENT';
      ap.updatedAt = new Date();
      await apRepo.save(ap);
      if (dto.note?.trim() && user.staffId) {
        await m.getRepository(RepairNote).insert({ repairOrderId: orderId, taskId: null, authorId: user.staffId, content: `[Xác nhận] ${dto.note.trim()}` });
      }
      const cashiers = await this.dao.staffUserIds(m, ro.branchId, ['CASHIER']);
      await this.notifier.notify(m, cashiers, 'Hồ sơ chờ thanh toán', `Lệnh ${ro.roCode} đã hoàn tất kỹ thuật, mời thu ngân lập hóa đơn.`,
        'REPAIR_ORDER', ro.repairOrderId);
      await this.notifier.audit(m, user.userId, 'REPAIR_VERIFIED', 'repair_orders', ro.repairOrderId, { appointmentStatus: 'WAITING_PAYMENT' });
    });
    return this.getOrder(user, orderId);
  }

  /* ================================================================ helpers */
  private async lockOrder(m: EntityManager, id: number): Promise<RepairOrder> {
    const ro = await m.getRepository(RepairOrder).findOne({ where: { repairOrderId: id }, lock: { mode: 'pessimistic_write' } });
    if (!ro) throw new NotFoundException('Không tìm thấy lệnh sửa chữa');
    return ro;
  }
}
