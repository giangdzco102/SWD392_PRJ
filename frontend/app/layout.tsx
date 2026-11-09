/*
 * MSSV: HE191633
 * Ho ten: Nguyen Truong Giang
 */

import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'AutoCare – Quản lý xưởng',
  description: 'AutoCare garage management – Repair operation & parts (UC27, UC29, UC32, UC37, UC38)',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="vi">
      <body>{children}</body>
    </html>
  );
}
