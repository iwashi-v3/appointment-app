import { Module } from '@nestjs/common';
import { ChatController } from './chat.controller';
import { ChatService } from './chat.service';
import { ChatGateway } from './chat.gateway';
import { SocketAuthMiddleware } from './middleware/socket-auth.middleware';
import { DatabaseModule } from '../database/database.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [DatabaseModule, AuthModule],
  controllers: [ChatController],
  providers: [ChatService, ChatGateway, SocketAuthMiddleware],
  exports: [ChatService],
})
export class ChatModule {}
