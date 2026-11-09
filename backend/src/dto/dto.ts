/*
 * MSSV: HE191633
 * Ho ten: Nguyen Truong Giang
 */

import { Type } from 'class-transformer';
import {
  ArrayMinSize, ArrayUnique, IsArray, IsEmail, IsIn, IsInt, IsNumber, IsOptional, IsString, Max, MaxLength, Min, MinLength, ValidateNested,
} from 'class-validator';

/* ------------------------------------------------------------------ auth */
export class LoginDto {
  @IsEmail({}, { message: 'Email không hợp lệ' }) email: string;
  @IsString() @MinLength(6, { message: 'Mật khẩu tối thiểu 6 ký tự' }) password: string;
}

/* ------------------------------------------------------------------ UC27 Assign Mechanic */
export class AssignMechanicDto {
  @Type(() => Number) @IsInt() mechanicId: number;
  /** Optional subset of tasks; default = every not-started task of the order. */
  @IsOptional() @IsArray() @ArrayUnique() @Type(() => Number) @IsInt({ each: true }) taskIds?: number[];
}

/* ------------------------------------------------------------------ UC29 Update Repair Progress */
export class UpdateProgressDto {
  @IsIn(['DOING', 'BLOCKED', 'DONE'], { message: 'Trạng thái chỉ được là DOING, BLOCKED hoặc DONE' }) status: 'DOING' | 'BLOCKED' | 'DONE';
  @Type(() => Number) @IsInt() @Min(0) @Max(100) progressPercent: number;
  @IsOptional() @Type(() => Number) @IsNumber() @Min(0) @Max(99) laborHours?: number;
  @IsOptional() @IsString() @MaxLength(1000) note?: string;
}

/* ------------------------------------------------------------------ UC32 Complete / verify */
export class VerifyCompletionDto {
  @IsOptional() @IsString() @MaxLength(1000) note?: string;
}

/* ------------------------------------------------------------------ UC37 Request Parts */
export class PartRequestItemDto {
  @Type(() => Number) @IsInt() quotationItemId: number;
  @Type(() => Number) @IsInt() @Min(1, { message: 'Số lượng phải lớn hơn 0' }) quantity: number;
}
export class CreatePartRequestDto {
  @Type(() => Number) @IsInt() repairOrderId: number;
  @Type(() => Number) @IsInt() taskId: number;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
  @IsArray() @ArrayMinSize(1, { message: 'Chọn ít nhất một phụ tùng' }) @ValidateNested({ each: true }) @Type(() => PartRequestItemDto)
  items: PartRequestItemDto[];
}

/* ------------------------------------------------------------------ UC38 Issue Parts */
export class IssueItemDto {
  @Type(() => Number) @IsInt() requestItemId: number;
  @Type(() => Number) @IsInt() @Min(1) quantity: number;
}
export class IssuePartsDto {
  /** Optional – empty means "issue every remaining quantity of the request". */
  @IsOptional() @IsArray() @ValidateNested({ each: true }) @Type(() => IssueItemDto) items?: IssueItemDto[];
}
export class RejectRequestDto {
  @IsString() @MinLength(3) @MaxLength(300) reason: string;
}
