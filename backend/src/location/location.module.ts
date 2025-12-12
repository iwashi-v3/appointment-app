import { Module } from '@nestjs/common';
import { LocationGateway } from './location.gateway';
import { LocationService } from './location.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  providers: [LocationGateway, LocationService],
  exports: [LocationService],
})
export class LocationModule {}
