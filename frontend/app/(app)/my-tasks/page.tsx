/*
 * MSSV: HE191633
 * Ho ten: Nguyen Truong Giang
 */

'use client';
import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { api } from '@/lib/api';
import { dt } from '@/lib/format';
import { Alert, Badge, Card, Empty, Progress } from '@/components/ui';

interface MyTask {
  id: number; taskName: string; status: string; progressPercent: number; laborHours: number; startedAt: string | null;
  repairOrderId: number; roCode: string; roStatus: string; licensePlate: string; vehicle: string;
}

export default function MyTasksPage() {
  const [tasks, setTasks] = useState<MyTask[] | null>(null);
  const [error, setError] = useState('');
  useEffect(() => { api<MyTask[]>('/repair-tasks/mine').then(setTasks).catch((e) => setError(e.message)); }, []);

  const groups = useMemo(() => {
    const m = new Map<number, MyTask[]>();
    (tasks ?? []).forEach((t) => m.set(t.repairOrderId, [...(m.get(t.repairOrderId) ?? []), t]));
    return [...m.values()];
  }, [tasks]);

  return (
    <>
      <div className="page-head">
        <div>
          <h1>Công việc của tôi</h1>
          <p className="muted" style={{ margin: 0 }}>Mở lệnh để cập nhật tiến độ (UC29), yêu cầu phụ tùng (UC37) và đánh dấu hoàn thành (UC32).</p>
        </div>
      </div>
      <Alert onClose={() => setError('')}>{error}</Alert>
      {tasks === null ? <Empty>Đang tải…</Empty> : groups.length === 0 ? <Card><Empty>Bạn chưa được phân công lệnh nào.</Empty></Card> : groups.map((g) => {
        const done = g.filter((t) => t.status === 'DONE').length;
        return (
          <Card key={g[0].repairOrderId}
            title={<><Link href={`/repair-orders/${g[0].repairOrderId}`}>{g[0].roCode}</Link> · {g[0].licensePlate} <span className="muted small">{g[0].vehicle}</span></>}
            actions={<><Badge status={g[0].roStatus} /><Link className="btn btn-primary" href={`/repair-orders/${g[0].repairOrderId}`}>Mở lệnh →</Link></>}>
            <table>
              <thead><tr><th>Hạng mục</th><th>Trạng thái</th><th>Tiến độ</th><th className="num">Giờ công</th><th>Bắt đầu</th></tr></thead>
              <tbody>
                {g.map((t) => (
                  <tr key={t.id}>
                    <td><b>{t.taskName}</b></td><td><Badge status={t.status} /></td><td><Progress value={t.progressPercent} /></td>
                    <td className="num">{t.laborHours}</td><td className="small">{dt(t.startedAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            {g[0].roStatus === 'IN_PROGRESS' && done === g.length && (
              <p className="small" style={{ color: 'var(--ok)', marginBottom: 0 }}>✓ Mọi hạng mục đã xong – mở lệnh để đánh dấu hoàn thành.</p>
            )}
          </Card>
        );
      })}
    </>
  );
}
