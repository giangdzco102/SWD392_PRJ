import { Column, Entity, PrimaryColumn } from 'typeorm';
import { numeric } from './columns';

/* ------------------------------------------------------------------ enumerations */
export type RepairOrderStatus = 'NEW' | 'ASSIGNED' | 'IN_PROGRESS' | 'WAITING_PARTS' | 'COMPLETED' | 'CLOSED';
export type TaskStatus = 'TODO' | 'DOING' | 'BLOCKED' | 'DONE';
export type PartRequestStatus = 'PENDING' | 'PARTIALLY_ISSUED' | 'ISSUED' | 'REJECTED';
export type ReservationStatus = 'RESERVED' | 'ISSUED' | 'RELEASED';
export type TransactionType = 'RECEIPT' | 'RESERVE' | 'RELEASE' | 'ISSUE' | 'RETURN' | 'ADJUST';
export type RoleCode = 'CUSTOMER' | 'RECEPTIONIST' | 'MECHANIC' | 'CASHIER' | 'BRANCH_MANAGER' | 'SYS_ADMIN';

const id = (name: string) =>
  PrimaryColumn({ name, type: 'bigint', generated: 'identity', generatedIdentity: 'ALWAYS', transformer: numeric });
const big = (name: string, nullable = false) => Column({ name, type: 'bigint', nullable, transformer: numeric });
const money = (name: string) => Column({ name, type: 'numeric', transformer: numeric });

/* ------------------------------------------------------------------ account */
@Entity('users')
export class User {
  @id('user_id') userId: number;
  @Column({ name: 'role_id', type: 'smallint' }) roleId: number;
  @Column() email: string;
  @Column({ name: 'password_hash' }) passwordHash: string;
  @Column({ name: 'full_name' }) fullName: string;
  @Column() status: 'ACTIVE' | 'LOCKED' | 'INACTIVE';
  @Column({ name: 'failed_login_count', type: 'smallint' }) failedLoginCount: number;
  @Column({ name: 'locked_until', type: 'timestamptz', nullable: true }) lockedUntil: Date | null;
  @Column({ name: 'last_login_at', type: 'timestamptz', nullable: true }) lastLoginAt: Date | null;
  @Column({ name: 'updated_at', type: 'timestamptz' }) updatedAt: Date;
}

@Entity('staff')
export class Staff {
  @id('staff_id') staffId: number;
  @big('user_id') userId: number;
  @big('branch_id', true) branchId: number | null;
  @Column() position: string;
  @Column() status: string;
}

/* ------------------------------------------------------------------ appointment */
@Entity('appointments')
export class Appointment {
  @id('appointment_id') appointmentId: number;
  @big('branch_id') branchId: number;
  @Column() status: string;
  @Column({ name: 'updated_at', type: 'timestamptz' }) updatedAt: Date;
}

/* ------------------------------------------------------------------ repair */
@Entity('repair_orders')
export class RepairOrder {
  @id('repair_order_id') repairOrderId: number;
  @Column({ name: 'ro_code' }) roCode: string;
  @big('quotation_id') quotationId: number;
  @big('branch_id') branchId: number;
  @Column({ type: 'varchar' }) status: RepairOrderStatus;
  @money('total_cost') totalCost: number;
  @Column({ name: 'started_at', type: 'timestamptz', nullable: true }) startedAt: Date | null;
  @Column({ name: 'completed_at', type: 'timestamptz', nullable: true }) completedAt: Date | null;
  @Column({ name: 'updated_at', type: 'timestamptz' }) updatedAt: Date;
}

@Entity('repair_tasks')
export class RepairTask {
  @id('task_id') taskId: number;
  @big('repair_order_id') repairOrderId: number;
  @big('quotation_item_id', true) quotationItemId: number | null;
  @big('mechanic_id', true) mechanicId: number | null;
  @Column({ name: 'task_name' }) taskName: string;
  @Column({ type: 'varchar' }) status: TaskStatus;
  @Column({ name: 'progress_percent', type: 'smallint' }) progressPercent: number;
  @money('labor_hours') laborHours: number;
  @Column({ name: 'started_at', type: 'timestamptz', nullable: true }) startedAt: Date | null;
  @Column({ name: 'finished_at', type: 'timestamptz', nullable: true }) finishedAt: Date | null;
}

@Entity('repair_notes')
export class RepairNote {
  @id('note_id') noteId: number;
  @big('repair_order_id') repairOrderId: number;
  @big('task_id', true) taskId: number | null;
  @big('author_id') authorId: number;
  @Column() content: string;
}

@Entity('quotation_items')
export class QuotationItem {
  @id('item_id') itemId: number;
  @big('quotation_id') quotationId: number;
  @Column({ name: 'item_type' }) itemType: 'SERVICE' | 'PART' | 'LABOR';
  @big('part_id', true) partId: number | null;
  @Column() description: string;
  @money('quantity') quantity: number;
  @money('unit_price') unitPrice: number;
  @Column() decision: 'PENDING' | 'APPROVED' | 'REJECTED';
}

/* ------------------------------------------------------------------ inventory */
@Entity('inventories')
export class Inventory {
  @id('inventory_id') inventoryId: number;
  @big('warehouse_id') warehouseId: number;
  @big('part_id') partId: number;
  @Column({ name: 'quantity_on_hand', type: 'int' }) quantityOnHand: number;
  @Column({ name: 'quantity_reserved', type: 'int' }) quantityReserved: number;
  @Column({ name: 'reorder_level', type: 'int' }) reorderLevel: number;
  @Column({ type: 'int' }) version: number;
  @Column({ name: 'updated_at', type: 'timestamptz' }) updatedAt: Date;
}

@Entity('part_reservations')
export class PartReservation {
  @id('reservation_id') reservationId: number;
  @big('repair_order_id') repairOrderId: number;
  @big('quotation_item_id', true) quotationItemId: number | null;
  @big('inventory_id') inventoryId: number;
  @Column({ type: 'int' }) quantity: number;
  @Column({ type: 'varchar' }) status: ReservationStatus;
  @Column({ name: 'updated_at', type: 'timestamptz' }) updatedAt: Date;
}

@Entity('part_requests')
export class PartRequest {
  @id('request_id') requestId: number;
  @Column({ name: 'request_code' }) requestCode: string;
  @big('repair_order_id') repairOrderId: number;
  @big('task_id', true) taskId: number | null;
  @big('requested_by') requestedBy: number;
  @Column({ type: 'varchar' }) status: PartRequestStatus;
  @Column({ type: 'varchar', nullable: true }) note: string | null;
  @big('processed_by', true) processedBy: number | null;
  @Column({ name: 'processed_at', type: 'timestamptz', nullable: true }) processedAt: Date | null;
}

@Entity('part_request_items')
export class PartRequestItem {
  @id('request_item_id') requestItemId: number;
  @big('request_id') requestId: number;
  @big('quotation_item_id') quotationItemId: number;
  @big('part_id') partId: number;
  @Column({ name: 'quantity_requested', type: 'int' }) quantityRequested: number;
  @Column({ name: 'quantity_issued', type: 'int' }) quantityIssued: number;
}

@Entity('repair_task_parts')
export class RepairTaskPart {
  @id('task_part_id') taskPartId: number;
  @big('task_id') taskId: number;
  @big('inventory_id') inventoryId: number;
  @big('reservation_id', true) reservationId: number | null;
  @big('request_item_id', true) requestItemId: number | null;
  @Column({ name: 'quantity_issued', type: 'int' }) quantityIssued: number;
  @Column({ name: 'quantity_returned', type: 'int' }) quantityReturned: number;
  @money('unit_price') unitPrice: number;
  @big('issued_by') issuedBy: number;
}

/** Append-only ledger (BR27) – a DB trigger rejects UPDATE / DELETE. */
@Entity('inventory_transactions')
export class InventoryTransaction {
  @id('transaction_id') transactionId: number;
  @big('inventory_id') inventoryId: number;
  @Column({ name: 'transaction_type', type: 'varchar' }) transactionType: TransactionType;
  @Column({ type: 'int' }) quantity: number;
  @Column({ name: 'balance_after', type: 'int' }) balanceAfter: number;
  @Column({ name: 'reference_type' }) referenceType: string;
  @big('reference_id') referenceId: number;
  @big('performed_by') performedBy: number;
}

/* ------------------------------------------------------------------ cross-cutting */
@Entity('notifications')
export class Notification {
  @id('notification_id') notificationId: number;
  @big('user_id') userId: number;
  @Column() channel: string;
  @Column() title: string;
  @Column() content: string;
  @Column({ name: 'reference_type', type: 'varchar', nullable: true }) referenceType: string | null;
  @big('reference_id', true) referenceId: number | null;
  @Column() status: string;
  @Column({ name: 'sent_at', type: 'timestamptz', nullable: true }) sentAt: Date | null;
}

@Entity('audit_logs')
export class AuditLog {
  @id('audit_id') auditId: number;
  @big('user_id', true) userId: number | null;
  @Column() action: string;
  @Column({ name: 'entity_name' }) entityName: string;
  @big('entity_id') entityId: number;
  @Column({ name: 'new_value', type: 'jsonb', nullable: true }) newValue: object | null;
}

/** Composite-key helper entity kept for completeness of the model package. */
@Entity('appointment_services')
export class AppointmentServiceLink {
  @PrimaryColumn({ name: 'appointment_id', type: 'bigint' }) appointmentId: number;
  @PrimaryColumn({ name: 'service_id', type: 'bigint' }) serviceId: number;
}

export const ENTITIES = [
  User, Staff, Appointment, RepairOrder, RepairTask, RepairNote, QuotationItem, Inventory, PartReservation,
  PartRequest, PartRequestItem, RepairTaskPart, InventoryTransaction, Notification, AuditLog, AppointmentServiceLink,
];
