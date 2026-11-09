/*
 * MSSV: HE191633
 * Ho ten: Nguyen Truong Giang
 */

'use client';
import { FormEvent, useState } from 'react';
import { useRouter } from 'next/navigation';
import { api, homeFor, saveSession, Session } from '@/lib/api';
import { Alert } from '@/components/ui';

const DEMO = [
  { email: 'reception1.cg@autocare.vn', label: 'Lễ tân', who: 'Lê Thu Hà – Cầu Giấy', note: 'UC27 phân công · UC32 xác nhận · UC38 xuất kho' },
  { email: 'mechanic1.cg@autocare.vn', label: 'Thợ máy 1', who: 'Đỗ Văn Hùng – Cầu Giấy', note: 'UC29 tiến độ · UC37 yêu cầu phụ tùng · UC32 hoàn thành' },
  { email: 'mechanic2.cg@autocare.vn', label: 'Thợ máy 2', who: 'Vũ Đức Thắng – Cầu Giấy', note: 'Lệnh đang chờ phụ tùng' },
  { email: 'manager.cg@autocare.vn', label: 'Quản lý chi nhánh', who: 'Phạm Minh Quân – Cầu Giấy', note: 'UC27 phân công, xem toàn chi nhánh' },
];

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  async function login(e?: FormEvent, preset?: string) {
    e?.preventDefault();
    setBusy(true);
    setError('');
    try {
      const s = await api<Session>('/auth/login', { method: 'POST', body: { email: preset ?? email, password: preset ? 'Password@123' : password } });
      if (s.user.role === 'CUSTOMER') throw new Error('Trang này dành cho nhân viên xưởng');
      saveSession(s);
      router.replace(homeFor(s.user.role));
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="login-wrap">
      <div className="login-card">
        <aside className="login-side">
          <div className="brand"><span className="brand-dot">A</span>AutoCare</div>
          <h1 style={{ marginTop: 28 }}>Quản lý sửa chữa &amp; phụ tùng</h1>
          <p className="muted">Phân công thợ, cập nhật tiến độ, yêu cầu và xuất phụ tùng, hoàn thành lệnh sửa chữa.</p>
          <div className="demo">
            <span className="small" style={{ color: '#94a3b8' }}>Đăng nhập nhanh bằng tài khoản demo (mật khẩu Password@123):</span>
            {DEMO.map((d) => (
              <button key={d.email} disabled={busy} onClick={() => login(undefined, d.email)}>
                <b>{d.label}</b> · {d.who}<br /><span className="small" style={{ color: '#94a3b8' }}>{d.note}</span>
              </button>
            ))}
          </div>
        </aside>
        <form className="login-form" onSubmit={login}>
          <h2 style={{ fontSize: 20 }}>Đăng nhập</h2>
          <p className="muted small" style={{ margin: 0 }}>Dành cho nhân viên các chi nhánh AutoCare</p>
          <Alert onClose={() => setError('')}>{error}</Alert>
          <label className="field-label" htmlFor="email">Email</label>
          <input id="email" type="email" required value={email} onChange={(e) => setEmail(e.target.value)} placeholder="ten@autocare.vn" autoComplete="username" />
          <label className="field-label" htmlFor="password">Mật khẩu</label>
          <input id="password" type="password" required value={password} onChange={(e) => setPassword(e.target.value)} autoComplete="current-password" />
          <button className="btn-primary" disabled={busy} type="submit" style={{ marginTop: 8 }}>{busy ? 'Đang đăng nhập…' : 'Đăng nhập'}</button>
          <p className="small muted">Phiên làm việc hết hạn sau 30 phút. Tài khoản bị khóa 15 phút nếu nhập sai mật khẩu 5 lần liên tiếp.</p>
        </form>
      </div>
    </main>
  );
}
