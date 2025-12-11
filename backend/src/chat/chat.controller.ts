import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  ValidationPipe,
} from '@nestjs/common';
import { ChatService } from './chat.service';
import { CreateMessageDto } from './dto/create-message.dto';
import { MessageResponseDto } from './dto/message-response.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post('messages')
  async createMessage(
    @Body(ValidationPipe) createMessageDto: CreateMessageDto,
    @CurrentUser() user: any
  ): Promise<MessageResponseDto> {
    return this.chatService.createMessage(createMessageDto, user.userId);
  }

  @Get('messages/:eventId')
  async getMessageHistory(
    @Param('eventId') eventId: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string
  ): Promise<MessageResponseDto[]> {
    const limitNum = limit ? parseInt(limit, 10) : 50;
    const offsetNum = offset ? parseInt(offset, 10) : 0;
    
    return this.chatService.getMessageHistory(eventId, limitNum, offsetNum);
  }

  @Get('typing/:eventId')
  async getTypingUsers(
    @Param('eventId') eventId: string
  ): Promise<{ userId: string; username: string }[]> {
    return this.chatService.getTypingUsers(eventId);
  }
}
