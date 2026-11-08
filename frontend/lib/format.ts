export const STATUS_LABEL: Record<string, string> = {
  // repair orders
  NEW: 'Mới tạo', ASSIGNED: 'Đã phân công', IN_PROGRESS: 'Đang sửa', WAITING_PARTS: 'Chờ phụ tùng', COMPLETED: 'Hoàn thành', CLOSED: 'Đã đóng',
  // tasks
  TODO: 'Chưa làm', DOING: 'Đang làm', BLOCKED: 'Tạm dừng', DONE: 'Xong',
  // part requests
  PENDING: 'Chờ xuất', PARTIALLY_ISSUED: 'Xuất một phần', ISSUED: 'Đã xuất', REJECTED: 'Từ chối',
  // appointments
  IN_SERVICE: 'Đang phục vụ', WAITING_PAYMENT: 'Chờ thanh toán', CHECKED_IN: 'Đã nhận xe', CONFIRMED: 'Đã xác nhận',
};

const TONE: Record<string, string> = {
  NEW: 'info', ASSIGNED: 'violet', IN_PROGRESS: 'warn', WAITING_PARTS: 'danger', COMPLETED: 'ok', CLOSED: 'muted',
  TODO: 'muted', DOING: 'warn', BLOCKED: 'danger', DONE: 'ok',
  PENDING: 'warn', PARTIALLY_ISSUED: 'info', ISSUED: 'ok', REJECTED: 'danger',
  IN_SERVICE: 'warn', WAITING_PAYMENT: 'violet', CHECKED_IN: 'info', CONFIRMED: 'info',
};
export const tone = (s: string) => TONE[s] ?? 'muted';

export const ROLE_LABEL: Record<string, string> = {
  RECEPTIONIST: 'Lễ tân', MECHANIC: 'Thợ máy', CASHIER: 'Thu ngân', BRANCH_MANAGER: 'Quản lý chi nhánh', SYS_ADMIN: 'Quản trị hệ thống', CUSTOMER: 'Khách hàng',
};

export function money(v: number | null | undefined) {
  return v == null ? '–' : new Intl.NumberFormat('vi-VN').format(v) + ' đ';
}
export function dt(v: string | null | undefined) {
  if (!v) return '–';
  return new Date(v).toLocaleString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}
