import { Injectable } from '@nestjs/common';
import { DataSource, EntityManager } from 'typeorm';

export interface PartRequestFilter {
  branchId?: number | null; status?: string | null; mechanicStaffId?: number | null; repairOrderId?: number | null; requestId?: number | null;
}

@Injectable()
export class PartRequestDao {
  constructor(private readonly ds: DataSource) {}

  list(f: PartRequestFilter) {
    return this.ds.query(
      `SELECT r.request_id::int AS id, r.request_code AS "requestCode", r.status, r.note, r.created_at AS "createdAt",
              r.processed_at AS "processedAt", ro.repair_order_id::int AS "repairOrderId", ro.ro_code AS "roCode", ro.status AS "roStatus",
              ro.branch_id::int AS "branchId", t.task_name AS "taskName", mu.full_name AS "requestedByName", pu.full_name AS "processedByName",
              v.license_plate AS "licensePlate",
              (SELECT COUNT(*)::int FROM part_request_items i WHERE i.request_id = r.request_id) AS "itemCount"
       FROM part_requests r
       JOIN repair_orders ro ON ro.repair_order_id = r.repair_order_id
       LEFT JOIN repair_tasks t ON t.task_id = r.task_id
       JOIN staff ms ON ms.staff_id = r.requested_by JOIN users mu ON mu.user_id = ms.user_id
       LEFT JOIN staff ps ON ps.staff_id = r.processed_by LEFT JOIN users pu ON pu.user_id = ps.user_id
       JOIN quotations q ON q.quotation_id = ro.quotation_id JOIN inspections i ON i.inspection_id = q.inspection_id
       JOIN vehicle_receptions vr ON vr.reception_id = i.reception_id JOIN appointments a ON a.appointment_id = vr.appointment_id
       JOIN vehicles v ON v.vehicle_id = a.vehicle_id
       WHERE ($1::bigint IS NULL OR ro.branch_id = $1) AND ($2::varchar IS NULL OR r.status = $2)
         AND ($3::bigint IS NULL OR r.requested_by = $3) AND ($4::bigint IS NULL OR r.repair_order_id = $4)
         AND ($5::bigint IS NULL OR r.request_id = $5)
       ORDER BY CASE r.status WHEN 'PENDING' THEN 1 WHEN 'PARTIALLY_ISSUED' THEN 2 ELSE 3 END, r.created_at DESC`,
      [f.branchId ?? null, f.status ?? null, f.mechanicStaffId ?? null, f.repairOrderId ?? null, f.requestId ?? null],
    );
  }

  /** Items of a request with reservation and branch stock figures (for UC38 screen). */
  items(requestId: number, m?: EntityManager) {
    return (m ?? this.ds.manager).query(
      `SELECT ri.request_item_id::int AS id, ri.quotation_item_id::int AS "quotationItemId", p.part_id::int AS "partId", p.sku,
              p.part_name AS "partName", p.unit, ri.quantity_requested AS "quantityRequested", ri.quantity_issued AS "quantityIssued",
              COALESCE((SELECT SUM(rs.quantity) FROM part_reservations rs WHERE rs.quotation_item_id = ri.quotation_item_id
                        AND rs.repair_order_id = r.repair_order_id AND rs.status = 'RESERVED'), 0)::int AS "reservedQty",
              COALESCE(inv.quantity_on_hand, 0) AS "onHand", COALESCE(inv.quantity_on_hand - inv.quantity_reserved, 0) AS "available"
       FROM part_request_items ri JOIN part_requests r ON r.request_id = ri.request_id
       JOIN repair_orders ro ON ro.repair_order_id = r.repair_order_id JOIN parts p ON p.part_id = ri.part_id
       LEFT JOIN warehouses w ON w.branch_id = ro.branch_id
       LEFT JOIN inventories inv ON inv.warehouse_id = w.warehouse_id AND inv.part_id = ri.part_id
       WHERE ri.request_id = $1 ORDER BY ri.request_item_id`, [requestId]);
  }

  async warehouseIdOfBranch(m: EntityManager, branchId: number): Promise<number | null> {
    const [r] = await m.query(`SELECT warehouse_id::int AS id FROM warehouses WHERE branch_id = $1 AND status = 'ACTIVE' ORDER BY warehouse_id LIMIT 1`, [branchId]);
    return r?.id ?? null;
  }
}
