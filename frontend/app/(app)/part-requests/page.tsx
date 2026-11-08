'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api';
import { dt } from '@/lib/format';
import { Alert, Badge, Card, Empty } from '@/components/ui';

interface Req {
  id: number; requestCode: string; status: string; roCode: string; roStatus: string; repairOrderId: number; taskName: string;
  requestedByName: string; processedByName: string | null; licensePlate: string; itemCount: number; createdAt: string; processedAt: string | null;
}
const FILTERS = ['PENDING', 'PARTIALLY_ISSUED', 'ISSUED', 'REJECTED', ''];
const LABEL: Record<string, string> = { PENDING: 'Chờ xuất', PARTIALLY_ISSUED: 'Xuất một phần', ISSUED: 'Đã xuất', REJECTED: 'Từ chối', '': 'Tất cả' };

export default function PartRequestsPage() {
  const router = useRouter();
  const [rows, setRows] = useState<Req[] | null>(null);
  const [filter, setFilter] = useState('');
  const [error, setError] = useState('');
  useEffect(() => {
    setRows(null);
    api<Req[]>(`/part-requests${filter ? `?status=${filter}` : ''}`).then(setRows).catch((e) => setError(e.message));
  }, [filter]);

  return (
    <>
      <div className="page-head">
        <div>
          <h1>Yêu cầu phụ tùng</h1>
          <p className="muted" style={{ margin: 0 }}>Thợ gửi yêu cầu (UC37) · Lễ tân kiểm tra và xuất kho (UC38).</p>
        </div>
        <div className="tabs">
          {FILTERS.map((f) => <button key={f} className={filter === f ? 'on' : ''} onClick={() => setFilter(f)}>{LABEL[f]}</button>)}
        </div>
      </div>
      <Alert onClose={() => setError('')}>{error}</Alert>
      <Card>
        {rows === null ? <Empty>Đang tải…</Empty> : rows.length === 0 ? <Empty>Không có yêu cầu nào.</Empty> : (
          <div className="table-wrap">
            <table>
              <thead><tr><th>Mã yêu cầu</th><th>Lệnh / Xe</th><th>Hạng mục</th><th>Thợ yêu cầu</th><th className="num">Số dòng</th><th>Trạng thái</th><th>Gửi lúc</th><th>Xử lý</th></tr></thead>
              <tbody>
                {rows.map((r) => (
                  <tr key={r.id} className="clickable" onClick={() => router.push(`/part-requests/${r.id}`)}>
                    <td><b>{r.requestCode}</b></td>
                    <td>{r.roCode}<br /><span className="small muted">{r.licensePlate}</span></td>
                    <td>{r.taskName}</td>
                    <td>{r.requestedByName}</td>
                    <td className="num">{r.itemCount}</td>
                    <td><Badge status={r.status} /></td>
                    <td className="small">{dt(r.createdAt)}</td>
                    <td className="small">{r.processedByName ? <>{r.processedByName}<br />{dt(r.processedAt)}</> : '–'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>
    </>
  );
}
