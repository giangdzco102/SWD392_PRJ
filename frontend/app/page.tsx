/*
 * MSSV: HE191633
 * Ho ten: Nguyen Truong Giang
 */

'use client';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { getSession, homeFor } from '@/lib/api';

export default function Home() {
  const router = useRouter();
  useEffect(() => {
    const s = getSession();
    router.replace(s ? homeFor(s.user.role) : '/login');
  }, [router]);
  return null;
}
