import { Body, Controller, Get, HttpCode, Param, ParseIntPipe, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { AuthUser, CurrentUser, JwtAuthGuard, Roles, RolesGuard } from '../common/security/security';
import {
  AssignMechanicDto, CreatePartRequestDto, IssuePartsDto, LoginDto, RejectRequestDto, UpdateProgressDto, VerifyCompletionDto,
} from '../dto/dto';
import { AuthService } from '../service/account/auth.service';
import { PartRequestService } from '../service/inventory/part-request.service';
import { RepairService } from '../service/repair/repair.service';

/* ------------------------------------------------------------------ autocare.controller.account */
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('login') @HttpCode(200)
  login(@Body() dto: LoginDto) { return this.auth.login(dto); }

  @Get('me') @UseGuards(JwtAuthGuard)
  me(@CurrentUser() user: AuthUser) { return user; }

  @Get('notifications') @UseGuards(JwtAuthGuard)
  notifications(@CurrentUser() user: AuthUser) { return this.auth.notifications(user); }
}

/* ------------------------------------------------------------------ autocare.controller.repair */
@Controller('repair-orders')
@UseGuards(JwtAuthGuard, RolesGuard)
export class RepairOrderController {
  constructor(private readonly repair: RepairService) {}

  @Get() @Roles('RECEPTIONIST', 'BRANCH_MANAGER', 'MECHANIC')
  list(@CurrentUser() u: AuthUser, @Query('status') status?: string) { return this.repair.listOrders(u, status || undefined); }

  @Get(':id') @Roles('RECEPTIONIST', 'BRANCH_MANAGER', 'MECHANIC', 'CASHIER')
  detail(@CurrentUser() u: AuthUser, @Param('id', ParseIntPipe) id: number) { return this.repair.getOrder(u, id); }

  @Get(':id/mechanics') @Roles('RECEPTIONIST', 'BRANCH_MANAGER')
  mechanics(@CurrentUser() u: AuthUser, @Param('id', ParseIntPipe) id: number) { return this.repair.mechanicsFor(u, id); }

  /** UC27 – Assign Mechanic */
  @Post(':id/assign') @HttpCode(200) @Roles('RECEPTIONIST', 'BRANCH_MANAGER')
  assign(@CurrentUser() u: AuthUser, @Param('id', ParseIntPipe) id: number, @Body() dto: AssignMechanicDto) {
    return this.repair.assignMechanic(u, id, dto);
  }

  /** UC32 step 1 – mechanic marks the repair order COMPLETED */
  @Post(':id/complete') @HttpCode(200) @Roles('MECHANIC')
  complete(@CurrentUser() u: AuthUser, @Param('id', ParseIntPipe) id: number) { return this.repair.completeOrder(u, id); }

  /** UC32 steps 2–3 – receptionist verifies and moves the appointment to WAITING_PAYMENT */
  @Post(':id/verify') @HttpCode(200) @Roles('RECEPTIONIST', 'BRANCH_MANAGER')
  verify(@CurrentUser() u: AuthUser, @Param('id', ParseIntPipe) id: number, @Body() dto: VerifyCompletionDto) {
    return this.repair.verifyCompletion(u, id, dto);
  }
}

@Controller('repair-tasks')
@UseGuards(JwtAuthGuard, RolesGuard)
export class RepairTaskController {
  constructor(private readonly repair: RepairService) {}

  @Get('mine') @Roles('MECHANIC')
  mine(@CurrentUser() u: AuthUser) { return this.repair.myTasks(u); }

  /** UC29 – Update Repair Progress */
  @Patch(':id/progress') @Roles('MECHANIC')
  progress(@CurrentUser() u: AuthUser, @Param('id', ParseIntPipe) id: number, @Body() dto: UpdateProgressDto) {
    return this.repair.updateProgress(u, id, dto);
  }
}

/* ------------------------------------------------------------------ autocare.controller.inventory */
@Controller('part-requests')
@UseGuards(JwtAuthGuard, RolesGuard)
export class PartRequestController {
  constructor(private readonly requests: PartRequestService) {}

  @Get() @Roles('RECEPTIONIST', 'BRANCH_MANAGER', 'MECHANIC')
  list(@CurrentUser() u: AuthUser, @Query('status') status?: string) { return this.requests.list(u, status || undefined); }

  @Get(':id') @Roles('RECEPTIONIST', 'BRANCH_MANAGER', 'MECHANIC')
  detail(@CurrentUser() u: AuthUser, @Param('id', ParseIntPipe) id: number) { return this.requests.get(u, id); }

  /** UC37 – Request Parts */
  @Post() @Roles('MECHANIC')
  create(@CurrentUser() u: AuthUser, @Body() dto: CreatePartRequestDto) { return this.requests.create(u, dto); }

  /** UC38 – Issue Parts */
  @Post(':id/issue') @HttpCode(200) @Roles('RECEPTIONIST')
  issue(@CurrentUser() u: AuthUser, @Param('id', ParseIntPipe) id: number, @Body() dto: IssuePartsDto) { return this.requests.issue(u, id, dto); }

  @Post(':id/reject') @HttpCode(200) @Roles('RECEPTIONIST')
  reject(@CurrentUser() u: AuthUser, @Param('id', ParseIntPipe) id: number, @Body() dto: RejectRequestDto) { return this.requests.reject(u, id, dto); }
}
