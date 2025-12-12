import { Module, Global } from '@nestjs/common';
import { HashService } from './services/hash.service';
import { RateLimitService } from './services/rate-limit.service';
import { WsThrottleGuard } from './guards/ws-throttle.guard';

@Global()
@Module({
  providers: [HashService, RateLimitService, WsThrottleGuard],
  exports: [HashService, RateLimitService, WsThrottleGuard],
})
export class CommonModule {}
