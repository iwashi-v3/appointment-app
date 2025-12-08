import { Module, Global } from '@nestjs/common';
import { HashService } from './services/hash.service';

@Global()
@Module({
  providers: [HashService],
  exports: [HashService],
})
export class CommonModule {}
