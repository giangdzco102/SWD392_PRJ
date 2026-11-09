/*
 * MSSV: HE191633
 * Ho ten: Nguyen Truong Giang
 */

'use client';
import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { api, getSession, SessionUser } from '@/lib/api';
import { dt, money } from '@/lib/format';
import { Alert, Badge, Card, Empty, Progress } from '@/components/ui';

interface Task {
  id: number; taskName: string; status: string; progressPercent: number; laborHours: number; startedAt: string | null; finishedAt: string | null;
  mechanicId: number | null; mechanicName: string | null;
}
interface PartLine {
  quotationItemId: number; sku: string; partName: string; unit: string; approvedQty: number; unitPrice: number;
  reservedQty: number; requestedQty: number; issuedQty: number; onHand: number; available: number;
}
interface Req { id: number; requestCode: string; status: string; taskName: string; requestedByName: string; createdAt: string; itemCount: number }
interface Order {
  id: number; roCode: string; status: string; typeName: string; branchName: string; totalCost: number; createdAt: string; startedAt: string | null;
  completedAt: string | null; appointmentCode: string; appointmentStatus: string; licensePlate: string; vehicle: string; customerName: string;
  customerPhone: string; taskCount: number; doneCount: number; avgProgress: number; tasks: Task[]; parts: PartLine[]; requests: Req[];
  notes: { id: number; content: string; createdAt: string; authorName: string; taskName: string | null }[];
}
interface Mechanic { id: number; fullName: string; staffCode: string; openTasks: number }

const NEXT: Record<string, string[]> = { TODO: ['DOING', 'BLOCKED'], DOING: ['DOING', 'BLOCKED', 'DONE'], BLOCKED: ['DOING', 'BLOCKED'], DONE: [] };
const NEXT_LABEL: Record<string, string> = { DOING: 'Đang làm', BLOCKED: 'Tạm dừng (chờ phụ tùng)', DONE: 'Hoàn thành' };

export default function RepairOrderDetail() {
  const { id } = useParams<{ id: string }>();
  const [me, setMe] = useState<SessionUser | null>(null);
  const [order, setOrder] = useState<Order | null>(null);
  const [error, setError] = useState('');
  const [ok, setOk] = useState('');
  const [busy, setBusy] = useState(false);

  const load = useCallback(() => api<Order>(`/repair-orders/${id}`).then(setOrder).catch((e) => setError(e.message)), [id]);
  useEffect(() => { setMe(getSession()?.user ?? null); load(); }, [load]);

  async function run(fn: () => Promise<Order>, success: string) {
    setBusy(true); setError(''); setOk('');
    try { setOrder(await fn()); setOk(success); } catch (e) { setError((e as Error).message); } finally { setBusy(false); }
  }

  if (!order || !me) return error ? <Alert>{error}</Alert> : <Empty>Đang tải…</Empty>;
  const isDesk = ['RECEPTIONIST', 'BRANCH_MANAGER', 'SYS_ADMIN'].includes(me.role);
  const isMech = me.role === 'MECHANIC';
  const myTasks = order.tasks.filter((t) => t.mechanicId === me.staffId);
  const workable = ['ASSIGNED', 'IN_PROGRESS', 'WAITING_PARTS'].includes(order.status);
  const allDone = order.tasks.length > 0 && order.tasks.every((t) => t.status === 'DONE');

  return (
    <>
      <div className="page-head">
        <div>
          <Link href={isMech ? '/my-tasks' : '/repair-orders'} className="small">← Quay lại</Link>
          <h1>{order.roCode} <Badge status={order.status} /></h1>
          <p className="muted" style={{ margin: 0 }}>{order.typeName} · {order.branchName} · tạo {dt(order.createdAt)}</p>
        </div>
        <div style={{ minWidth: 220 }}>
          <Progress value={order.avgProgress} />
          <span className="small muted">{order.doneCount}/{order.taskCount} hạng mục hoàn thành</span>
        </div>
      </div>
      <Alert onClose={() => setError('')}>{error}</Alert>
      <Alert kind="success" onClose={() => setOk('')}>{ok}</Alert>

      <Card title="Thông tin xe & khách hàng">
        <div className="grid">
          <div><div className="field-label">Biển số</div><div className="field-value">{order.licensePlate}</div></div>
          <div><div className="field-label">Xe</div><div className="field-value">{order.vehicle}</div></div>
          <div><div className="field-label">Khách hàng</div><div className="field-value">{order.customerName}</div><span className="small muted">{order.customerPhone}</span></div>
          <div><div className="field-label">Lịch hẹn</div><div className="field-value">{order.appointmentCode} <Badge status={order.appointmentStatus} /></div></div>
          <div><div className="field-label">Giá trị đã duyệt</div><div className="field-value">{money(order.totalCost)}</div></div>
          <div><div className="field-label">Bắt đầu / Hoàn thành</div><div className="field-value small">{dt(order.startedAt)} → {dt(order.completedAt)}</div></div>
        </div>
      </Card>

      {isDesk && ['NEW', 'ASSIGNED'].includes(order.status) && (
        <AssignPanel order={order} busy={busy} onAssign={(mechanicId, taskIds) =>
          run(() => api(`/repair-orders/${id}/assign`, { method: 'POST', body: { mechanicId, taskIds } }), 'Đã phân công thợ và gửi thông báo cho thợ.')} />
      )}

      {isMech && order.status === 'IN_PROGRESS' && allDone && (
        <Card title="UC32 · Hoàn thành lệnh sửa chữa">
          <p className="muted">Tất cả hạng mục đã xong. Đánh dấu COMPLETED để lễ tân kiểm tra; phụ tùng giữ chỗ nhưng chưa dùng sẽ được trả lại kho.</p>
          <button className="btn-success" disabled={busy} onClick={() => run(() => api(`/repair-orders/${id}/complete`, { method: 'POST' }), 'Lệnh đã chuyển sang COMPLETED, lễ tân đã được thông báo.')}>
            ✓ Đánh dấu hoàn thành
          </button>
        </Card>
      )}

      {isDesk && order.status === 'COMPLETED' && order.appointmentStatus === 'IN_SERVICE' && (
        <VerifyPanel busy={busy} onVerify={(note) =>
          run(() => api(`/repair-orders/${id}/verify`, { method: 'POST', body: { note } }), 'Đã xác nhận, lịch hẹn chuyển WAITING_PAYMENT và thu ngân đã được thông báo.')} />
      )}

      <Card title="Hạng mục công việc">
        {order.tasks.length === 0 ? <Empty>Chưa có hạng mục.</Empty> : (
          <div className="table-wrap">
            <table>
              <thead><tr><th>Hạng mục</th><th>Thợ</th><th>Trạng thái</th><th>Tiến độ</th><th className="num">Giờ công</th><th>Bắt đầu</th><th>Xong</th></tr></thead>
              <tbody>
                {order.tasks.map((t) => (
                  <tr key={t.id}>
                    <td><b>{t.taskName}</b></td>
                    <td>{t.mechanicName ?? <span className="badge badge-danger">Chưa phân công</span>}</td>
                    <td><Badge status={t.status} /></td>
                    <td><Progress value={t.progressPercent} /></td>
                    <td className="num">{t.laborHours}</td>
                    <td className="small">{dt(t.startedAt)}</td>
                    <td className="small">{dt(t.finishedAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        {isMech && workable && myTasks.filter((t) => t.status !== 'DONE').map((t) => (
          <ProgressForm key={`${t.id}-${t.status}-${t.progressPercent}-${t.laborHours}`} task={t} busy={busy} onSave={(body) =>
            run(() => api(`/repair-tasks/${t.id}/progress`, { method: 'PATCH', body }), `Đã cập nhật "${t.taskName}".`)} />
        ))}
      </Card>

      <Card title="Phụ tùng theo báo giá đã duyệt">
        {order.parts.length === 0 ? <Empty>Báo giá không có phụ tùng.</Empty> : (
          <div className="table-wrap">
            <table>
              <thead><tr><th>Phụ tùng</th><th className="num">Đã duyệt</th><th className="num">Đang giữ</th><th className="num">Đã yêu cầu</th><th className="num">Đã xuất</th><th className="num">Khả dụng kho</th><th className="num">Đơn giá</th></tr></thead>
              <tbody>
                {order.parts.map((p) => (
                  <tr key={p.quotationItemId}>
                    <td><b>{p.partName}</b><br /><span className="small muted">{p.sku}</span></td>
                    <td className="num">{p.approvedQty} {p.unit}</td>
                    <td className="num">{p.reservedQty}</td>
                    <td className="num">{p.requestedQty}</td>
                    <td className="num">{p.issuedQty}</td>
                    <td className="num">{p.available}</td>
                    <td className="num">{money(p.unitPrice)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        {isMech && ['IN_PROGRESS', 'WAITING_PARTS'].includes(order.status) && order.parts.length > 0 && (
          <RequestForm order={order} tasks={myTasks.filter((t) => t.status !== 'DONE')} busy={busy} onSubmit={async (body) => {
            setBusy(true); setError(''); setOk('');
            try {
              const req = await api<{ requestCode: string }>('/part-requests', { method: 'POST', body: { ...body, repairOrderId: order.id } });
              await load();
              setOk(`Đã gửi yêu cầu ${req.requestCode} tới lễ tân.`);
            } catch (e) { setError((e as Error).message); } finally { setBusy(false); }
          }} />
        )}
      </Card>

      <Card title="Yêu cầu phụ tùng của lệnh">
        {order.requests.length === 0 ? <Empty>Chưa có yêu cầu.</Empty> : (
          <table>
            <thead><tr><th>Mã</th><th>Hạng mục</th><th>Người yêu cầu</th><th>Số dòng</th><th>Trạng thái</th><th>Thời gian</th></tr></thead>
            <tbody>
              {order.requests.map((r) => (
                <tr key={r.id}>
                  <td><Link href={`/part-requests/${r.id}`}><b>{r.requestCode}</b></Link></td>
                  <td>{r.taskName}</td><td>{r.requestedByName}</td><td>{r.itemCount}</td><td><Badge status={r.status} /></td><td className="small">{dt(r.createdAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Card>

      <Card title="Ghi chú kỹ thuật">
        {order.notes.length === 0 ? <Empty>Chưa có ghi chú.</Empty> : order.notes.map((n) => (
          <div key={n.id} style={{ padding: '8px 0', borderBottom: '1px solid var(--line)' }}>
            <b>{n.authorName}</b> <span className="small muted">· {dt(n.createdAt)}{n.taskName ? ` · ${n.taskName}` : ''}</span>
            <div>{n.content}</div>
          </div>
        ))}
      </Card>
    </>
  );
}

/* ------------------------------------------------------------------ UC27 */
function AssignPanel({ order, busy, onAssign }: { order: Order; busy: boolean; onAssign: (mechanicId: number, taskIds: number[]) => void }) {
  const [mechanics, setMechanics] = useState<Mechanic[]>([]);
  const todo = order.tasks.filter((t) => t.status === 'TODO');
  const [mechanicId, setMechanicId] = useState<number>(0);
  const [taskIds, setTaskIds] = useState<number[]>(todo.map((t) => t.id));
  useEffect(() => { api<Mechanic[]>(`/repair-orders/${order.id}/mechanics`).then(setMechanics).catch(() => {}); }, [order.id]);
  return (
    <Card title="UC27 · Phân công thợ máy">
      <p className="muted" style={{ marginTop: 0 }}>Chọn thợ cùng chi nhánh. Thợ sẽ nhận thông báo và lệnh chuyển sang ASSIGNED.</p>
      <div className="form-row">
        <label>Thợ máy
          <select value={mechanicId} onChange={(e) => setMechanicId(Number(e.target.value))}>
            <option value={0}>— Chọn thợ —</option>
            {mechanics.map((m) => <option key={m.id} value={m.id}>{m.fullName} ({m.staffCode}) · {m.openTasks} việc đang mở</option>)}
          </select>
        </label>
        <button className="btn-primary" disabled={busy || !mechanicId || taskIds.length === 0} onClick={() => onAssign(mechanicId, taskIds)}>Phân công</button>
      </div>
      <div style={{ marginTop: 10 }}>
        {todo.map((t) => (
          <label key={t.id} style={{ display: 'inline-flex', gap: 6, marginRight: 16, alignItems: 'center' }}>
            <input type="checkbox" checked={taskIds.includes(t.id)} onChange={(e) => setTaskIds(e.target.checked ? [...taskIds, t.id] : taskIds.filter((x) => x !== t.id))} />
            {t.taskName} {t.mechanicName && <span className="small muted">(hiện: {t.mechanicName})</span>}
          </label>
        ))}
      </div>
    </Card>
  );
}

/* ------------------------------------------------------------------ UC29 */
function ProgressForm({ task, busy, onSave }: { task: Task; busy: boolean; onSave: (b: object) => void }) {
  const options = NEXT[task.status];
  const [status, setStatus] = useState(options[0]);
  const [pct, setPct] = useState(Math.max(task.progressPercent, task.status === 'TODO' ? 10 : task.progressPercent));
  const [hours, setHours] = useState<string>(String(task.laborHours ?? 0));
  const [note, setNote] = useState('');
  return (
    <div className="panel">
      <b>UC29 · Cập nhật tiến độ: {task.taskName}</b> <Badge status={task.status} />
      <div className="form-row" style={{ marginTop: 8 }}>
        <label>Trạng thái mới
          <select value={status} onChange={(e) => setStatus(e.target.value)}>
            {options.map((o) => <option key={o} value={o}>{NEXT_LABEL[o]}</option>)}
          </select>
        </label>
        <label>Tiến độ (%)
          <input className="qty" type="number" min={task.progressPercent} max={status === 'DONE' ? 100 : 99} value={status === 'DONE' ? 100 : pct}
            disabled={status === 'DONE'} onChange={(e) => setPct(Number(e.target.value))} />
        </label>
        <label>Giờ công
          <input className="qty" type="number" min={0} step={0.25} value={hours} onChange={(e) => setHours(e.target.value)} />
        </label>
        <label style={{ flex: 1, minWidth: 220 }}>Ghi chú {status === 'BLOCKED' && task.status !== 'BLOCKED' && '(bắt buộc – lý do tạm dừng)'}
          <input value={note} onChange={(e) => setNote(e.target.value)} placeholder="VD: thiếu lọc gió, chờ kho xuất" />
        </label>
        <button className="btn-primary" disabled={busy} onClick={() => onSave({ status, progressPercent: status === 'DONE' ? 100 : pct, laborHours: Number(hours), note: note || undefined })}>
          Lưu
        </button>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ UC32 verify */
function VerifyPanel({ busy, onVerify }: { busy: boolean; onVerify: (note: string) => void }) {
  const [note, setNote] = useState('');
  return (
    <Card title="UC32 · Kiểm tra & chuyển thu ngân">
      <p className="muted" style={{ marginTop: 0 }}>Thợ đã hoàn thành lệnh. Kiểm tra xe, sau đó xác nhận để chuyển lịch hẹn sang WAITING_PAYMENT.</p>
      <textarea value={note} onChange={(e) => setNote(e.target.value)} placeholder="Ghi chú kiểm tra (không bắt buộc): đã chạy thử, xe vận hành tốt…" />
      <button className="btn-success" style={{ marginTop: 10 }} disabled={busy} onClick={() => onVerify(note)}>✓ Xác nhận hoàn thành & chuyển thu ngân</button>
    </Card>
  );
}

/* ------------------------------------------------------------------ UC37 */
function RequestForm({ order, tasks, busy, onSubmit }: { order: Order; tasks: Task[]; busy: boolean;
  onSubmit: (b: { taskId: number; note?: string; items: { quotationItemId: number; quantity: number }[] }) => void }) {
  const [taskId, setTaskId] = useState<number>(tasks[0]?.id ?? 0);
  const [note, setNote] = useState('');
  const [qty, setQty] = useState<Record<number, number>>({});
  const lines = useMemo(() => order.parts.map((p) => ({ ...p, remaining: p.approvedQty - p.requestedQty })), [order.parts]);
  const items = Object.entries(qty).filter(([, q]) => q > 0).map(([k, q]) => ({ quotationItemId: Number(k), quantity: q }));
  if (tasks.length === 0) return <p className="small muted">Bạn không có hạng mục đang mở để yêu cầu phụ tùng.</p>;
  return (
    <div className="panel">
      <b>UC37 · Yêu cầu phụ tùng</b>
      <p className="small muted" style={{ margin: '4px 0 10px' }}>Chỉ được yêu cầu phụ tùng có trong báo giá đã duyệt, tối đa phần còn lại chưa yêu cầu.</p>
      <div className="form-row">
        <label>Cho hạng mục
          <select value={taskId} onChange={(e) => setTaskId(Number(e.target.value))}>
            {tasks.map((t) => <option key={t.id} value={t.id}>{t.taskName}</option>)}
          </select>
        </label>
        <label style={{ flex: 1, minWidth: 220 }}>Ghi chú
          <input value={note} onChange={(e) => setNote(e.target.value)} placeholder="VD: cần ngay để thay lọc" />
        </label>
      </div>
      <table style={{ marginTop: 10 }}>
        <thead><tr><th>Phụ tùng</th><th className="num">Còn được yêu cầu</th><th className="num">Khả dụng kho</th><th className="num">Số lượng</th></tr></thead>
        <tbody>
          {lines.map((p) => (
            <tr key={p.quotationItemId}>
              <td>{p.partName} <span className="small muted">({p.sku})</span></td>
              <td className="num">{p.remaining}</td>
              <td className="num">{p.available + p.reservedQty}</td>
              <td className="num">
                <input className="qty" type="number" min={0} max={p.remaining} disabled={p.remaining <= 0} value={qty[p.quotationItemId] ?? 0}
                  onChange={(e) => setQty({ ...qty, [p.quotationItemId]: Math.max(0, Math.min(p.remaining, Number(e.target.value))) })} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <button className="btn-primary" style={{ marginTop: 10 }} disabled={busy || !taskId || items.length === 0}
        onClick={() => { onSubmit({ taskId, note: note || undefined, items }); setQty({}); setNote(''); }}>
        Gửi yêu cầu ({items.length} phụ tùng)
      </button>
    </div>
  );
}
