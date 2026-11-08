'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api';
import { dt, money } from '@/lib/format';
import { Alert, Badge, Card, Empty, Progress } from '@/components/ui';

interface Order {
  id: number; roCode: string; status: string; typeName: string; licensePlate: string; vehicle: string; customerName: string;
  mechanics: string | null; taskCount: number; doneCount: number; pendingRequests: number; totalCost: number; createdAt: string; avgProgress: number;
  appointmentStatus: string;
}
const FILTERS = ['', 'NEW', 'ASSIGNED', 'IN_PROGRESS', 'WAITING_PARTS', 'COMPLETED', 'CLOSED'];
const FILTER_LABEL: Record<string, string> = { '': 'Tất cả', NEW: 'Mới tạo', ASSIGNED: 'Đã phân công', IN_PROGRESS: 'Đang sửa',
  WAITING_PARTS: 'Chờ phụ tùng', COMPLETED: 'Hoàn thành', CLOSED: 'Đã đóng' };

export default function RepairOrdersPage() {
  const router = useRouter();
  const [rows, setRows] = useState<Order[] | null>(null);
  const [filter, setFilter] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    setRows(null);
    api<Order[]>(`/repair-orders${filter ? `?status=${filter}` : ''}`).then(setRows).catch((e) => setError(e.message));
  }, [filter]);

  return (
    <>
      <div className="page-head">
        <div>
          <h1>Lệnh sửa chữa</h1>
          <p className="muted" style={{ margin: 0 }}>Phân công thợ (UC27) và xác nhận hoàn thành (UC32) cho các lệnh của chi nhánh.</p>
        </div>
        <div className="tabs">
          {FILTERS.map((f) => <button key={f} className={filter === f ? 'on' : ''} onClick={() => setFilter(f)}>{FILTER_LABEL[f]}</button>)}
        </div>
      </div>
      <Alert onClose={() => setError('')}>{error}</Alert>
      <Card>
        {rows === null ? <Empty>Đang tải…</Empty> : rows.length === 0 ? <Empty>Không có lệnh sửa chữa nào.</Empty> : (
          <div className="table-wrap">
            <table>
              <thead>
                <tr><th>Mã lệnh</th><th>Xe</th><th>Khách hàng</th><th>Thợ phụ trách</th><th>Tiến độ</th><th>Trạng thái</th><th className="num">Giá trị</th><th>Tạo lúc</th></tr>
              </thead>
              <tbody>
                {rows.map((o) => (
                  <tr key={o.id} className="clickable" onClick={() => router.push(`/repair-orders/${o.id}`)}>
                    <td><b>{o.roCode}</b><br /><span className="small muted">{o.typeName}</span></td>
                    <td>{o.licensePlate}<br /><span className="small muted">{o.vehicle}</span></td>
                    <td>{o.customerName}</td>
                    <td>{o.mechanics ?? <span className="badge badge-danger">Chưa phân công</span>}</td>
                    <td><Progress value={o.avgProgress} /><span className="small muted">{o.doneCount}/{o.taskCount} hạng mục</span></td>
                    <td>
                      <Badge status={o.status} />
                      {o.pendingRequests > 0 && <><br /><span className="small" style={{ color: 'var(--warn)' }}>{o.pendingRequests} yêu cầu phụ tùng chờ</span></>}
                      {o.status === 'COMPLETED' && o.appointmentStatus === 'IN_SERVICE' && <><br /><span className="small" style={{ color: 'var(--violet)' }}>Chờ lễ tân xác nhận</span></>}
                    </td>
                    <td className="num">{money(o.totalCost)}</td>
                    <td className="small">{dt(o.createdAt)}</td>
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
