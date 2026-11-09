/*
 * MSSV: HE191633
 * Ho ten: Nguyen Truong Giang
 */

import 'reflect-metadata';
import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { config } from './config/app.config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api');
  app.enableCors({ origin: config.webOrigin });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true, forbidNonWhitelisted: true }));
  await app.listen(config.port);
  console.log(`AutoCare API running on http://localhost:${config.port}/api`);
}
bootstrap();
