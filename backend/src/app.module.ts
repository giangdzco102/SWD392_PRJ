import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtAuthGuard, RolesGuard } from './common/security/security';
import { config } from './config/app.config';
import { AuthController, PartRequestController, RepairOrderController, RepairTaskController } from './controller/controllers';
import { AccountDao } from './dao/account.dao';
import { PartRequestDao } from './dao/part-request.dao';
import { RepairDao } from './dao/repair.dao';
import { ENTITIES } from './model/entities';
import { AuthService } from './service/account/auth.service';
import { NotificationService } from './service/common/notification.service';
import { PartRequestService } from './service/inventory/part-request.service';
import { RepairService } from './service/repair/repair.service';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: config.db.host,
      port: config.db.port,
      username: config.db.user,
      password: config.db.password,
      database: config.db.name,
      entities: ENTITIES,
      synchronize: false,            // schema is owned by database/01_schema.sql
    }),
    JwtModule.register({ global: true, secret: config.jwt.secret, signOptions: { expiresIn: config.jwt.expiresIn as any } }),
  ],
  controllers: [AuthController, RepairOrderController, RepairTaskController, PartRequestController],
  providers: [
    JwtAuthGuard, RolesGuard,
    AccountDao, RepairDao, PartRequestDao,
    NotificationService, AuthService, RepairService, PartRequestService,
  ],
})
export class AppModule {}
