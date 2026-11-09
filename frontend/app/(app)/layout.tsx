/*
 * MSSV: HE191633
 * Ho ten: Nguyen Truong Giang
 */

'use client';
import { ReactNode, useEffect, useState } from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { api, clearSession, getSession, SessionUser } from '@/lib/api';
import { dt, ROLE_LABEL } from '@/lib/format';

interface Note { id: number; title: string; content: string; createdAt: string }

export default function AppShell({ children }: { children: ReactNode }) {
  const router = useRouter();
  const path = usePathname();
  const [user, setUser] = useState<SessionUser | null>(null);
  const [notes, setNotes] = useState<Note[]>([]);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const s = getSession();
    if (!s) { router.replace('/login'); return; }
    setUser(s.user);
  }, [router]);

  useEffect(() => {
    if (!user) return;
    const load = () => api<Note[]>('/auth/notifications').then(setNotes).catch(() => {});
    load();
    const t = setInterval(load, 15000);
    return () => clearInterval(t);
  }, [user, path]);

  if (!user) return null;
  const staffNav = user.role === 'MECHANIC'
    ? [{ href: '/my-tasks', label: 'Công việc của tôi' }, { href: '/part-requests', label: 'Yêu cầu phụ tùng' }]
    : [{ href: '/repair-orders', label: 'Lệnh sửa chữa' }, { href: '/part-requests', label: 'Yêu cầu phụ tùng' }];

  return (
    <>
      <header className="topbar">
        <div className="brand"><span className="brand-dot">A</span>AutoCare</div>
        <nav className="nav">
          {staffNav.map((n) => (
            <Link key={n.href} href={n.href} className={path.startsWith(n.href) ? 'active' : ''}>{n.label}</Link>
          ))}
        </nav>
        <button className="bell" onClick={() => setOpen(!open)} aria-label="Thông báo">
          🔔 {notes.length > 0 && <span className="count">{notes.length}</span>}
        </button>
        <div className="who">
          <b>{user.fullName}</b>
          <span>{ROLE_LABEL[user.role]}{user.branchName ? ` · ${user.branchName}` : ''}</span>
        </div>
        <button className="btn-ghost" onClick={() => { clearSession(); router.replace('/login'); }}>Đăng xuất</button>
        {open && (
          <div className="notif-panel" onClick={() => setOpen(false)}>
            {notes.length === 0 && <div className="muted">Chưa có thông báo</div>}
            {notes.map((n) => (
              <div key={n.id}><b>{n.title}</b><span className="small">{n.content}</span><br /><span className="small muted">{dt(n.createdAt)}</span></div>
            ))}
          </div>
        )}
      </header>
      <main className="page">
        {user.role === 'CASHIER' ? <p className="empty">Chức năng thu ngân thuộc phân hệ Settlement (chưa có trong bản này).</p> : children}
      </main>
    </>
  );
}
