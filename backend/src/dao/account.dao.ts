import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';

@Injectable()
export class AccountDao {
  constructor(private readonly ds: DataSource) {}

  async findLoginByEmail(email: string) {
    const rows = await this.ds.query(
      `SELECT u.user_id::int AS "userId", u.email, u.password_hash AS "passwordHash", u.full_name AS "fullName", u.status,
              u.failed_login_count AS "failedLoginCount", u.locked_until AS "lockedUntil", r.role_code AS role,
              s.staff_id::int AS "staffId", s.branch_id::int AS "branchId", b.branch_name AS "branchName"
       FROM users u JOIN roles r ON r.role_id = u.role_id
       LEFT JOIN staff s ON s.user_id = u.user_id LEFT JOIN branches b ON b.branch_id = s.branch_id
       WHERE LOWER(u.email) = LOWER($1)`, [email]);
    return rows[0] ?? null;
  }

  myNotifications(userId: number) {
    return this.ds.query(
      `SELECT notification_id::int AS id, title, content, reference_type AS "referenceType", reference_id::int AS "referenceId",
              status, created_at AS "createdAt"
       FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 20`, [userId]);
  }
}
