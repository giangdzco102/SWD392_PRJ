/*
 * MSSV: HE191633
 * Ho ten: Nguyen Truong Giang
 */

import { ForbiddenException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { DataSource } from 'typeorm';
import { AuthUser } from '../../common/security/security';
import { AccountDao } from '../../dao/account.dao';
import { LoginDto } from '../../dto/dto';
import { User } from '../../model/entities';

const MAX_FAILED = 5;          // NFR-5: lock after 5 consecutive failures
const LOCK_MINUTES = 15;

@Injectable()
export class AuthService {
  constructor(private readonly dao: AccountDao, private readonly jwt: JwtService, private readonly ds: DataSource) {}

  async login(dto: LoginDto) {
    const acc = await this.dao.findLoginByEmail(dto.email);
    if (!acc) throw new UnauthorizedException('Email hoặc mật khẩu không đúng');
    const users = this.ds.getRepository(User);
    if (acc.lockedUntil && new Date(acc.lockedUntil) > new Date()) {
      throw new ForbiddenException(`Tài khoản tạm khóa đến ${new Date(acc.lockedUntil).toLocaleTimeString('vi-VN')} do nhập sai mật khẩu nhiều lần`);
    }
    if (acc.status === 'INACTIVE') throw new ForbiddenException('Tài khoản đã bị vô hiệu hóa');

    if (!(await bcrypt.compare(dto.password, acc.passwordHash))) {
      const failed = acc.failedLoginCount + 1;
      const lock = failed >= MAX_FAILED;
      await users.update(acc.userId, {
        failedLoginCount: lock ? 0 : failed,
        lockedUntil: lock ? new Date(Date.now() + LOCK_MINUTES * 60_000) : null,
        updatedAt: new Date(),
      });
      throw new UnauthorizedException(lock ? `Sai mật khẩu ${MAX_FAILED} lần, tài khoản bị khóa ${LOCK_MINUTES} phút` : 'Email hoặc mật khẩu không đúng');
    }
    await users.update(acc.userId, { failedLoginCount: 0, lockedUntil: null, status: 'ACTIVE', lastLoginAt: new Date(), updatedAt: new Date() });

    const user: AuthUser = { userId: acc.userId, fullName: acc.fullName, role: acc.role, staffId: acc.staffId ?? null, branchId: acc.branchId ?? null };
    return { accessToken: this.jwt.sign(user), user: { ...user, email: acc.email, branchName: acc.branchName ?? null } };
  }

  notifications(user: AuthUser) {
    return this.dao.myNotifications(user.userId);
  }
}
