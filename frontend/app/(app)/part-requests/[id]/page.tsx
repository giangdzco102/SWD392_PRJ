'use client';
import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { api, getSession, SessionUser } from '@/lib/api';
import { dt } from '@/lib/format';
import { Alert, Badge, Card, Empty } from '@/components/ui';

interface Item {
  id: number; sku: string; partName: string; unit: string; quantityRequested: number; quantityIssued: number; reservedQty: number; onHand: number; available: number;
}
interface Req {
  id: number; requestCode: string; status: string; note: string | null; repairOrderId: number; roCode: string; roStatus: string; taskName: string;
  requestedByName: string; processedByName: string | null; licensePlate: string; createdAt: string; processedAt: string | null; items: Item[];
}

export default function PartRequestDetail() {
  const { id } = useParams<{ id: string }>();
  const [me, setMe] = useState<SessionUser | null>(null);
  const [req, setReq] = useState<Req | null>(null);
  const [qty, setQty] = useState<Record<number, number>>({});
  const [reason, setReason] = useState('');
  const [error, setError] = useState('');
  const [ok, setOk] = useState('');
  const [busy, setBusy] = useState(false);

  const apply = (r: Req) => {
    setReq(r);
    setQty(Object.fromEntries(r.items.map((i) => [i.id, i.quantityRequested - i.quantityIssued])));
  };
  const load = useCallback(() => api<Req>(`/part-requests/${id}`).then(apply).catch((e) => setError(e.message)), [id]);
  useEffect(() => { setMe(getSession()?.user ?? null); load(); }, [load]);

  async function issue() {
    setBusy(true); setError(''); setOk('');
    try {
      const items = Object.entries(qty).filter(([, q]) => q > 0).map(([k, q]) => ({ requestItemId: Number(k), quantity: q }));
      const r = await api<Req>(`/part-requests/${id}/issue`, { method: 'POST', body: { items } });
      apply(r);
      setOk(r.status === 'ISSUED' ? 'Đã xuất đủ phụ tùng, tồn kho và sổ kho đã được cập nhật.' : 'Đã xuất một phần, phần còn lại vẫn chờ xuất.');
    } catch (e) { setError((e as Error).message); } finally { setBusy(false); }
  }
  async function reject() {
    setBusy(true); setError(''); setOk('');
    try { apply(await api<Req>(`/part-requests/${id}/reject`, { method: 'POST', body: { reason } })); setOk('Đã từ chối yêu cầu và báo cho thợ.'); }
    catch (e) { setError((e as Error).message); } finally { setBusy(false); }
  }

  if (!req || !me) return error ? <Alert>{error}</Alert> : <Empty>Đang tải…</Empty>;
  const canIssue = me.role === 'RECEPTIONIST' && ['PENDING', 'PARTIALLY_ISSUED'].includes(req.status) && !['COMPLETED', 'CLOSED'].includes(req.roStatus);
  const toIssue = Object.values(qty).filter((q) => q > 0).length;

  return (
    <>
      <div className="page-head">
        <div>
          <Link href="/part-requests" className="small">← Danh sách yêu cầu</Link>
          <h1>{req.requestCode} <Badge status={req.status} /></h1>
          <p className="muted" style={{ margin: 0 }}>
            Lệnh <Link href={`/repair-orders/${req.repairOrderId}`}>{req.roCode}</Link> · {req.licensePlate} · hạng mục “{req.taskName}”
          </p>
        </div>
      </div>
      <Alert onClose={() => setError('')}>{error}</Alert>
      <Alert kind="success" onClose={() => setOk('')}>{ok}</Alert>

      <Card title="Thông tin yêu cầu">
        <div className="grid">
          <div><div className="field-label">Thợ yêu cầu</div><div className="field-value">{req.requestedByName}</div></div>
          <div><div className="field-label">Gửi lúc</div><div className="field-value">{dt(req.createdAt)}</div></div>
          <div><div className="field-label">Người xử lý</div><div className="field-value">{req.processedByName ?? '–'}</div><span className="small muted">{dt(req.processedAt)}</span></div>
          <div><div className="field-label">Ghi chú</div><div className="field-value">{req.note ?? '–'}</div></div>
        </div>
      </Card>

      <Card title={canIssue ? 'UC38 · Xuất phụ tùng' : 'Phụ tùng yêu cầu'}>
        <div className="table-wrap">
          <table>
            <thead>
              <tr><th>Phụ tùng</th><th className="num">Yêu cầu</th><th className="num">Đã xuất</th><th className="num">Giữ cho lệnh</th><th className="num">Tồn kho</th><th className="num">Khả dụng</th>{canIssue && <th className="num">Xuất lần này</th>}</tr>
            </thead>
            <tbody>
              {req.items.map((i) => {
                const remaining = i.quantityRequested - i.quantityIssued;
                const short = (qty[i.id] ?? 0) - Math.min(qty[i.id] ?? 0, i.reservedQty) > i.available;
                return (
                  <tr key={i.id}>
                    <td><b>{i.partName}</b><br /><span className="small muted">{i.sku}</span></td>
                    <td className="num">{i.quantityRequested} {i.unit}</td>
                    <td className="num">{i.quantityIssued}</td>
                    <td className="num">{i.reservedQty}</td>
                    <td className="num">{i.onHand}</td>
                    <td className="num" style={short ? { color: 'var(--danger)', fontWeight: 700 } : undefined}>{i.available}</td>
                    {canIssue && (
                      <td className="num">
                        <input className="qty" type="number" min={0} max={remaining} disabled={remaining <= 0} value={qty[i.id] ?? 0}
                          onChange={(e) => setQty({ ...qty, [i.id]: Math.max(0, Math.min(remaining, Number(e.target.value))) })} />
                        {short && <div className="small" style={{ color: 'var(--danger)' }}>Không đủ tồn kho</div>}
                      </td>
                    )}
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        {canIssue && (
          <>
            <p className="small muted">Xuất kho sẽ giảm tồn kho; phần đã giữ cho lệnh được trừ trước. Mỗi lần xuất tạo một bút toán ISSUE không thể sửa/xóa.</p>
            <div className="form-row">
              <button className="btn-success" disabled={busy || toIssue === 0} onClick={issue}>✓ Xác nhận xuất kho ({toIssue} dòng)</button>
              {req.status === 'PENDING' && (
                <>
                  <input style={{ flex: 1, minWidth: 220 }} value={reason} onChange={(e) => setReason(e.target.value)} placeholder="Lý do từ chối (nếu có)" />
                  <button className="btn-danger" disabled={busy || reason.trim().length < 3} onClick={reject}>Từ chối</button>
                </>
              )}
            </div>
          </>
        )}
      </Card>
    </>
  );
}
