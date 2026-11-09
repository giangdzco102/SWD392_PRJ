/*
 * MSSV: HE191633
 * Ho ten: Nguyen Truong Giang
 */

import { BadRequestException, ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { DataSource, In } from 'typeorm';
import { AuthUser, assertSameBranch } from '../../common/security/security';
import { nextCode } from '../../common/util/code-generator';
import { PartRequestDao } from '../../dao/part-request.dao';
import { RepairDao } from '../../dao/repair.dao';
import { CreatePartRequestDto, IssuePartsDto, RejectRequestDto } from '../../dto/dto';
import {
  Inventory, InventoryTransaction, PartRequest, PartRequestItem, PartReservation, QuotationItem, RepairOrder, RepairTask, RepairTaskPart,
} from '../../model/entities';
import { NotificationService } from '../common/notification.service';

@Injectable()
export class PartRequestService {
  constructor(
    private readonly ds: DataSource,
    private readonly dao: PartRequestDao,
    private readonly repairDao: RepairDao,
    private readonly notifier: NotificationService,
  ) {}

  /* ================================================================ queries */
  list(user: AuthUser, status?: string) {
    if (user.role === 'MECHANIC') return this.dao.list({ mechanicStaffId: user.staffId, status });
    return this.dao.list({ branchId: user.role === 'SYS_ADMIN' ? null : user.branchId, status });
  }

  async get(user: AuthUser, id: number) {
    const [header] = await this.dao.list({ requestId: id });
    if (!header) throw new NotFoundException('Không tìm thấy yêu cầu phụ tùng');
    assertSameBranch(user, header.branchId);
    if (user.role === 'MECHANIC') {
      const pr = await this.ds.getRepository(PartRequest).findOneBy({ requestId: id });
      if (pr?.requestedBy !== user.staffId) throw new ForbiddenException('Đây không phải yêu cầu của bạn');
    }
    return { ...header, items: await this.dao.items(id) };
  }

  /* ================================================================ UC37 Request Parts (Mechanic) */
  async create(user: AuthUser, dto: CreatePartRequestDto) {
    const ids = dto.items.map((i) => i.quotationItemId);
    if (new Set(ids).size !== ids.length) throw new BadRequestException('Mỗi phụ tùng chỉ được chọn một lần trong một yêu cầu');
    let requestId = 0;
    await this.ds.transaction(async (m) => {
      const ro = await m.getRepository(RepairOrder).findOne({ where: { repairOrderId: dto.repairOrderId }, lock: { mode: 'pessimistic_write' } });
      if (!ro) throw new NotFoundException('Không tìm thấy lệnh sửa chữa');
      if (!['IN_PROGRESS', 'WAITING_PARTS'].includes(ro.status)) {
        throw new ConflictException(`Chỉ yêu cầu phụ tùng khi lệnh đang thực hiện (hiện tại: ${ro.status})`);
      }
      const task = await m.getRepository(RepairTask).findOneBy({ taskId: dto.taskId, repairOrderId: ro.repairOrderId });
      if (!task) throw new BadRequestException('Hạng mục không thuộc lệnh sửa chữa này');
      if (task.mechanicId !== user.staffId) throw new ForbiddenException('Bạn không được phân công hạng mục này');   // BR22
      if (task.status === 'DONE') throw new ConflictException('Hạng mục đã hoàn thành, không cần thêm phụ tùng');

      const qItems = await m.getRepository(QuotationItem).findBy({ itemId: In(ids) });
      const figures: Array<{ quotationItemId: number; approvedQty: number; requestedQty: number }> =
        await this.repairDao.partItemsOfOrder(ro.repairOrderId, m);
      for (const it of dto.items) {
        const qi = qItems.find((q) => q.itemId === it.quotationItemId);
        if (!qi || qi.quotationId !== ro.quotationId || qi.itemType !== 'PART' || qi.decision !== 'APPROVED') {   // BR19
          throw new BadRequestException(`Phụ tùng #${it.quotationItemId} không nằm trong báo giá đã được duyệt của lệnh`);
        }
        const f = figures.find((x) => x.quotationItemId === qi.itemId)!;
        const remaining = f.approvedQty - f.requestedQty;
        if (it.quantity > remaining) {
          throw new BadRequestException(`"${qi.description}": chỉ còn được yêu cầu tối đa ${remaining} (đã duyệt ${f.approvedQty}, đã yêu cầu ${f.requestedQty})`);
        }
      }

      const requestCode = await nextCode(m, 'PR', 'part_requests', 'request_code');
      const pr = await m.getRepository(PartRequest).save(m.getRepository(PartRequest).create({
        requestCode, repairOrderId: ro.repairOrderId, taskId: task.taskId, requestedBy: user.staffId!, status: 'PENDING',
        note: dto.note?.trim() || null, processedBy: null, processedAt: null,
      }));
      requestId = pr.requestId;
      for (const it of dto.items) {
        const qi = qItems.find((q) => q.itemId === it.quotationItemId)!;
        await m.getRepository(PartRequestItem).insert({
          requestId, quotationItemId: qi.itemId, partId: qi.partId!, quantityRequested: it.quantity, quantityIssued: 0,
        });
      }
      const receptionists = await this.repairDao.staffUserIds(m, ro.branchId, ['RECEPTIONIST']);
      await this.notifier.notify(m, receptionists, 'Yêu cầu xuất phụ tùng mới',
        `${requestCode} – lệnh ${ro.roCode}, ${dto.items.length} phụ tùng cho "${task.taskName}"`, 'PART_REQUEST', requestId);
      await this.notifier.audit(m, user.userId, 'PART_REQUEST_CREATED', 'part_requests', requestId, { items: dto.items });
    });
    return this.get(user, requestId);
  }

  /* ================================================================ UC38 Issue Parts (Receptionist) */
  async issue(user: AuthUser, requestId: number, dto: IssuePartsDto) {
    await this.ds.transaction(async (m) => {
      const prRepo = m.getRepository(PartRequest);
      const pr = await prRepo.findOne({ where: { requestId }, lock: { mode: 'pessimistic_write' } });
      if (!pr) throw new NotFoundException('Không tìm thấy yêu cầu phụ tùng');
      const ro = await m.getRepository(RepairOrder).findOneByOrFail({ repairOrderId: pr.repairOrderId });
      assertSameBranch(user, ro.branchId);                                                               // BR48
      if (!['PENDING', 'PARTIALLY_ISSUED'].includes(pr.status)) throw new ConflictException(`Yêu cầu đã ở trạng thái ${pr.status}`);
      if (['COMPLETED', 'CLOSED'].includes(ro.status)) throw new ConflictException('Lệnh sửa chữa đã hoàn thành, không xuất thêm phụ tùng');
      if (!pr.taskId) throw new ConflictException('Yêu cầu chưa gắn với hạng mục công việc');

      const itemRepo = m.getRepository(PartRequestItem);
      const items = await itemRepo.find({ where: { requestId }, lock: { mode: 'pessimistic_write' } });
      const plan = dto.items?.length
        ? dto.items.map((d) => {
            const it = items.find((i) => i.requestItemId === d.requestItemId);
            if (!it) throw new BadRequestException(`Dòng #${d.requestItemId} không thuộc yêu cầu này`);
            return { it, qty: d.quantity };
          })
        : items.filter((i) => i.quantityIssued < i.quantityRequested).map((it) => ({ it, qty: it.quantityRequested - it.quantityIssued }));
      if (!plan.length) throw new ConflictException('Không còn phụ tùng nào cần xuất');

      const warehouseId = await this.dao.warehouseIdOfBranch(m, ro.branchId);
      if (!warehouseId) throw new ConflictException('Chi nhánh chưa có kho phụ tùng');
      for (const { it, qty } of plan) {
        const remaining = it.quantityRequested - it.quantityIssued;
        if (qty > remaining) throw new BadRequestException(`Dòng #${it.requestItemId}: chỉ còn ${remaining} cần xuất`);

        const inv = await m.getRepository(Inventory).findOne({ where: { warehouseId, partId: it.partId }, lock: { mode: 'pessimistic_write' } });
        if (!inv) throw new ConflictException(`Kho chi nhánh chưa có phụ tùng #${it.partId}`);
        const reservation = await m.getRepository(PartReservation).findOne({
          where: { repairOrderId: ro.repairOrderId, quotationItemId: it.quotationItemId, status: 'RESERVED' }, lock: { mode: 'pessimistic_write' },
        });
        const fromReserved = Math.min(qty, reservation?.quantity ?? 0);
        const fromFree = qty - fromReserved;
        const free = inv.quantityOnHand - inv.quantityReserved;
        if (fromFree > free) {                                                                            // BR25
          const [{ sku }] = await m.query(`SELECT sku FROM parts WHERE part_id = $1`, [it.partId]);
          throw new ConflictException(`Không đủ tồn kho ${sku}: cần thêm ${fromFree}, khả dụng ${free} (đã giữ cho lệnh ${fromReserved})`);
        }

        inv.quantityOnHand -= qty;
        inv.quantityReserved -= fromReserved;
        inv.version += 1;
        inv.updatedAt = new Date();
        await m.getRepository(Inventory).save(inv);
        if (reservation && fromReserved > 0) {
          if (fromReserved >= reservation.quantity) reservation.status = 'ISSUED';
          else reservation.quantity -= fromReserved;
          reservation.updatedAt = new Date();
          await m.getRepository(PartReservation).save(reservation);
        }
        const qi = await m.getRepository(QuotationItem).findOneByOrFail({ itemId: it.quotationItemId });
        await m.getRepository(RepairTaskPart).insert({
          taskId: pr.taskId, inventoryId: inv.inventoryId, reservationId: reservation?.reservationId ?? null, requestItemId: it.requestItemId,
          quantityIssued: qty, quantityReturned: 0, unitPrice: qi.unitPrice, issuedBy: user.staffId!,
        });
        await m.getRepository(InventoryTransaction).insert({                                             // BR27 immutable movement
          inventoryId: inv.inventoryId, transactionType: 'ISSUE', quantity: -qty, balanceAfter: inv.quantityOnHand,
          referenceType: 'PART_REQUEST', referenceId: requestId, performedBy: user.staffId!,
        });
        it.quantityIssued += qty;
        await itemRepo.save(it);
      }

      const allIssued = items.every((i) => i.quantityIssued >= i.quantityRequested);
      pr.status = allIssued ? 'ISSUED' : 'PARTIALLY_ISSUED';
      pr.processedBy = user.staffId;
      pr.processedAt = new Date();
      await prRepo.save(pr);

      const mechUser = await this.repairDao.userIdOfStaff(m, pr.requestedBy);
      await this.notifier.notify(m, [mechUser], allIssued ? 'Phụ tùng đã được xuất đủ' : 'Phụ tùng đã được xuất một phần',
        `Yêu cầu ${pr.requestCode} (lệnh ${ro.roCode}) đã sẵn sàng tại quầy kho.`, 'PART_REQUEST', requestId);
      await this.notifier.audit(m, user.userId, 'PARTS_ISSUED', 'part_requests', requestId,
        { items: plan.map((p) => ({ requestItemId: p.it.requestItemId, quantity: p.qty })), status: pr.status });
    });
    return this.get(user, requestId);
  }

  async reject(user: AuthUser, requestId: number, dto: RejectRequestDto) {
    await this.ds.transaction(async (m) => {
      const pr = await m.getRepository(PartRequest).findOne({ where: { requestId }, lock: { mode: 'pessimistic_write' } });
      if (!pr) throw new NotFoundException('Không tìm thấy yêu cầu phụ tùng');
      const ro = await m.getRepository(RepairOrder).findOneByOrFail({ repairOrderId: pr.repairOrderId });
      assertSameBranch(user, ro.branchId);
      if (pr.status !== 'PENDING') throw new ConflictException('Chỉ từ chối được yêu cầu đang PENDING');
      pr.status = 'REJECTED';
      pr.note = `${pr.note ? pr.note + ' | ' : ''}Từ chối: ${dto.reason}`;
      pr.processedBy = user.staffId;
      pr.processedAt = new Date();
      await m.getRepository(PartRequest).save(pr);
      const mechUser = await this.repairDao.userIdOfStaff(m, pr.requestedBy);
      await this.notifier.notify(m, [mechUser], 'Yêu cầu phụ tùng bị từ chối', `${pr.requestCode}: ${dto.reason}`, 'PART_REQUEST', requestId);
      await this.notifier.audit(m, user.userId, 'PART_REQUEST_REJECTED', 'part_requests', requestId, { reason: dto.reason });
    });
    return this.get(user, requestId);
  }
}
