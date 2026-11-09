/*
 * MSSV: HE191633
 * Ho ten: Nguyen Truong Giang
 */

import { Injectable } from '@nestjs/common';
import { DataSource, EntityManager } from 'typeorm';

/** Joins a repair order to its appointment, vehicle and customer (RO → quotation → inspection → reception → appointment). */
const RO_CONTEXT = `
  FROM repair_orders ro
  JOIN repair_order_types rot ON rot.type_id = ro.type_id
  JOIN branches b            ON b.branch_id = ro.branch_id
  JOIN quotations q          ON q.quotation_id = ro.quotation_id
  JOIN inspections i         ON i.inspection_id = q.inspection_id
  JOIN vehicle_receptions vr ON vr.reception_id = i.reception_id
  JOIN appointments a        ON a.appointment_id = vr.appointment_id
  JOIN vehicles v            ON v.vehicle_id = a.vehicle_id
  JOIN customers c           ON c.customer_id = a.customer_id
  JOIN users cu              ON cu.user_id = c.user_id`;

const RO_COLUMNS = `
  ro.repair_order_id::int AS id, ro.ro_code AS "roCode", ro.status, ro.total_cost::float8 AS "totalCost",
  ro.branch_id::int AS "branchId", b.branch_name AS "branchName", rot.type_name AS "typeName",
  ro.created_at AS "createdAt", ro.started_at AS "startedAt", ro.completed_at AS "completedAt",
  a.appointment_id::int AS "appointmentId", a.appointment_code AS "appointmentCode", a.status AS "appointmentStatus",
  v.license_plate AS "licensePlate", v.brand || ' ' || v.model AS vehicle, cu.full_name AS "customerName", cu.phone AS "customerPhone",
  (SELECT COUNT(*)::int FROM repair_tasks t WHERE t.repair_order_id = ro.repair_order_id) AS "taskCount",
  (SELECT COUNT(*)::int FROM repair_tasks t WHERE t.repair_order_id = ro.repair_order_id AND t.status = 'DONE') AS "doneCount",
  (SELECT COALESCE(ROUND(AVG(t.progress_percent)), 0)::int FROM repair_tasks t WHERE t.repair_order_id = ro.repair_order_id) AS "avgProgress",
  (SELECT string_agg(DISTINCT mu.full_name, ', ') FROM repair_tasks t JOIN staff ms ON ms.staff_id = t.mechanic_id
     JOIN users mu ON mu.user_id = ms.user_id WHERE t.repair_order_id = ro.repair_order_id) AS mechanics,
  (SELECT COUNT(*)::int FROM part_requests pr WHERE pr.repair_order_id = ro.repair_order_id
     AND pr.status IN ('PENDING','PARTIALLY_ISSUED')) AS "pendingRequests"`;

export interface RepairOrderFilter { branchId?: number | null; status?: string | null; mechanicStaffId?: number | null }

@Injectable()
export class RepairDao {
  constructor(private readonly ds: DataSource) {}

  private q(m?: EntityManager) { return m ?? this.ds.manager; }

  listOrders(f: RepairOrderFilter) {
    return this.ds.query(
      `SELECT ${RO_COLUMNS} ${RO_CONTEXT}
       WHERE ($1::bigint IS NULL OR ro.branch_id = $1) AND ($2::varchar IS NULL OR ro.status = $2)
         AND ($3::bigint IS NULL OR EXISTS (SELECT 1 FROM repair_tasks t WHERE t.repair_order_id = ro.repair_order_id AND t.mechanic_id = $3))
       ORDER BY CASE ro.status WHEN 'NEW' THEN 1 WHEN 'WAITING_PARTS' THEN 2 WHEN 'ASSIGNED' THEN 3 WHEN 'IN_PROGRESS' THEN 4
                WHEN 'COMPLETED' THEN 5 ELSE 6 END, ro.created_at DESC`,
      [f.branchId ?? null, f.status ?? null, f.mechanicStaffId ?? null],
    );
  }

  async orderHeader(id: number) {
    const rows = await this.ds.query(`SELECT ${RO_COLUMNS} ${RO_CONTEXT} WHERE ro.repair_order_id = $1`, [id]);
    return rows[0] ?? null;
  }

  tasksOfOrder(id: number, m?: EntityManager) {
    return this.q(m).query(
      `SELECT t.task_id::int AS id, t.task_name AS "taskName", t.status, t.progress_percent AS "progressPercent",
              t.labor_hours::float8 AS "laborHours", t.started_at AS "startedAt", t.finished_at AS "finishedAt",
              t.mechanic_id::int AS "mechanicId", mu.full_name AS "mechanicName"
       FROM repair_tasks t LEFT JOIN staff ms ON ms.staff_id = t.mechanic_id LEFT JOIN users mu ON mu.user_id = ms.user_id
       WHERE t.repair_order_id = $1 ORDER BY t.task_id`, [id]);
  }

  /** Approved PART items of the order with reservation / request / issue / stock figures. */
  partItemsOfOrder(id: number, m?: EntityManager) {
    return this.q(m).query(
      `SELECT qi.item_id::int AS "quotationItemId", p.part_id::int AS "partId", p.sku, p.part_name AS "partName", p.unit,
              qi.quantity::float8 AS "approvedQty", qi.unit_price::float8 AS "unitPrice",
              COALESCE((SELECT SUM(r.quantity) FROM part_reservations r WHERE r.quotation_item_id = qi.item_id
                        AND r.repair_order_id = ro.repair_order_id AND r.status = 'RESERVED'), 0)::int AS "reservedQty",
              COALESCE((SELECT SUM(ri.quantity_requested) FROM part_request_items ri JOIN part_requests pr ON pr.request_id = ri.request_id
                        WHERE ri.quotation_item_id = qi.item_id AND pr.status <> 'REJECTED'), 0)::int AS "requestedQty",
              COALESCE((SELECT SUM(ri.quantity_issued) FROM part_request_items ri WHERE ri.quotation_item_id = qi.item_id), 0)::int AS "issuedQty",
              COALESCE(inv.quantity_on_hand, 0) AS "onHand", COALESCE(inv.quantity_on_hand - inv.quantity_reserved, 0) AS "available"
       FROM repair_orders ro
       JOIN quotation_items qi ON qi.quotation_id = ro.quotation_id AND qi.item_type = 'PART' AND qi.decision = 'APPROVED'
       JOIN parts p ON p.part_id = qi.part_id
       LEFT JOIN warehouses w ON w.branch_id = ro.branch_id
       LEFT JOIN inventories inv ON inv.warehouse_id = w.warehouse_id AND inv.part_id = p.part_id
       WHERE ro.repair_order_id = $1 ORDER BY qi.item_id`, [id]);
  }

  notesOfOrder(id: number) {
    return this.ds.query(
      `SELECT n.note_id::int AS id, n.content, n.created_at AS "createdAt", u.full_name AS "authorName", t.task_name AS "taskName"
       FROM repair_notes n JOIN staff s ON s.staff_id = n.author_id JOIN users u ON u.user_id = s.user_id
       LEFT JOIN repair_tasks t ON t.task_id = n.task_id WHERE n.repair_order_id = $1 ORDER BY n.created_at DESC`, [id]);
  }

  mechanicsOfBranch(branchId: number) {
    return this.ds.query(
      `SELECT s.staff_id::int AS id, u.full_name AS "fullName", s.staff_code AS "staffCode",
              (SELECT COUNT(*)::int FROM repair_tasks t JOIN repair_orders ro ON ro.repair_order_id = t.repair_order_id
               WHERE t.mechanic_id = s.staff_id AND t.status <> 'DONE' AND ro.status NOT IN ('COMPLETED','CLOSED')) AS "openTasks"
       FROM staff s JOIN users u ON u.user_id = s.user_id
       WHERE s.branch_id = $1 AND s.position = 'MECHANIC' AND s.status = 'ACTIVE' AND u.status = 'ACTIVE'
       ORDER BY "openTasks", u.full_name`, [branchId]);
  }

  tasksOfMechanic(staffId: number) {
    return this.ds.query(
      `SELECT t.task_id::int AS id, t.task_name AS "taskName", t.status, t.progress_percent AS "progressPercent",
              t.labor_hours::float8 AS "laborHours", t.started_at AS "startedAt", t.finished_at AS "finishedAt",
              ro.repair_order_id::int AS "repairOrderId", ro.ro_code AS "roCode", ro.status AS "roStatus",
              v.license_plate AS "licensePlate", v.brand || ' ' || v.model AS vehicle
       FROM repair_tasks t JOIN repair_orders ro ON ro.repair_order_id = t.repair_order_id
       JOIN quotations q ON q.quotation_id = ro.quotation_id JOIN inspections i ON i.inspection_id = q.inspection_id
       JOIN vehicle_receptions vr ON vr.reception_id = i.reception_id JOIN appointments a ON a.appointment_id = vr.appointment_id
       JOIN vehicles v ON v.vehicle_id = a.vehicle_id
       WHERE t.mechanic_id = $1 AND ro.status IN ('ASSIGNED','IN_PROGRESS','WAITING_PARTS','COMPLETED')
       ORDER BY CASE ro.status WHEN 'COMPLETED' THEN 2 ELSE 1 END, ro.created_at, t.task_id`, [staffId]);
  }

  async appointmentIdOfOrder(roId: number, m?: EntityManager): Promise<number> {
    const [r] = await this.q(m).query(
      `SELECT vr.appointment_id::int AS id FROM repair_orders ro JOIN quotations q ON q.quotation_id = ro.quotation_id
       JOIN inspections i ON i.inspection_id = q.inspection_id JOIN vehicle_receptions vr ON vr.reception_id = i.reception_id
       WHERE ro.repair_order_id = $1`, [roId]);
    return r?.id;
  }

  /** user ids of active staff of a branch having one of the positions – used for notifications. */
  async staffUserIds(m: EntityManager, branchId: number, positions: string[]): Promise<number[]> {
    const rows = await m.query(
      `SELECT s.user_id::int AS id FROM staff s WHERE s.branch_id = $1 AND s.position = ANY($2) AND s.status = 'ACTIVE'`,
      [branchId, positions]);
    return rows.map((r: { id: number }) => r.id);
  }

  async userIdOfStaff(m: EntityManager, staffId: number): Promise<number> {
    const [r] = await m.query(`SELECT user_id::int AS id FROM staff WHERE staff_id = $1`, [staffId]);
    return r?.id;
  }
}
