import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { messages, typingStatus, Message, NewMessage, TypingStatus, NewTypingStatus } from '../database/schema/messages.schema';
import { users } from '../database/schema/users.schema';
import { CreateMessageDto } from './dto/create-message.dto';
import { MessageResponseDto } from './dto/message-response.dto';
import { TypingStatusDto } from './dto/typing-status.dto';
import { eq, and, desc, isNull } from 'drizzle-orm';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class ChatService {
  constructor(private readonly databaseService: DatabaseService) {}

  async createMessage(createMessageDto: CreateMessageDto, senderId: string): Promise<MessageResponseDto> {
    const messageId = uuidv4();
    
    const newMessage: NewMessage = {
      messageId,
      eventId: createMessageDto.eventId,
      senderId,
      content: createMessageDto.content,
      messageType: createMessageDto.messageType || 'text',
    };

    await this.databaseService.db.insert(messages).values(newMessage);
    
    // メッセージと送信者情報を取得
    const messageWithUser = await this.databaseService.db
      .select({
        messageId: messages.messageId,
        eventId: messages.eventId,
        senderId: messages.senderId,
        senderUsername: users.username,
        content: messages.content,
        messageType: messages.messageType,
        isEdited: messages.isEdited,
        createdAt: messages.createdAt,
        updatedAt: messages.updatedAt,
      })
      .from(messages)
      .innerJoin(users, eq(messages.senderId, users.userId))
      .where(eq(messages.messageId, messageId))
      .limit(1);

    return messageWithUser[0];
  }

  async getMessageHistory(eventId: string, limit: number = 50, offset: number = 0): Promise<MessageResponseDto[]> {
    const messageHistory = await this.databaseService.db
      .select({
        messageId: messages.messageId,
        eventId: messages.eventId,
        senderId: messages.senderId,
        senderUsername: users.username,
        content: messages.content,
        messageType: messages.messageType,
        isEdited: messages.isEdited,
        createdAt: messages.createdAt,
        updatedAt: messages.updatedAt,
      })
      .from(messages)
      .innerJoin(users, eq(messages.senderId, users.userId))
      .where(and(
        eq(messages.eventId, eventId),
        isNull(messages.deletedAt)
      ))
      .orderBy(desc(messages.createdAt))
      .limit(limit)
      .offset(offset);

    return messageHistory;
  }

  async updateTypingStatus(typingStatusDto: TypingStatusDto, userId: string): Promise<void> {
    const existingStatus = await this.databaseService.db
      .select()
      .from(typingStatus)
      .where(and(
        eq(typingStatus.eventId, typingStatusDto.eventId),
        eq(typingStatus.userId, userId)
      ))
      .limit(1);

    if (existingStatus.length > 0) {
      await this.databaseService.db
        .update(typingStatus)
        .set({
          isTyping: typingStatusDto.isTyping,
          lastTypingAt: new Date(),
        })
        .where(and(
          eq(typingStatus.eventId, typingStatusDto.eventId),
          eq(typingStatus.userId, userId)
        ));
    } else {
      const newTypingStatus: NewTypingStatus = {
        id: uuidv4(),
        eventId: typingStatusDto.eventId,
        userId,
        isTyping: typingStatusDto.isTyping,
        lastTypingAt: new Date(),
      };
      await this.databaseService.db.insert(typingStatus).values(newTypingStatus);
    }
  }

  async getTypingUsers(eventId: string): Promise<{ userId: string; username: string }[]> {
    // 過去30秒以内に入力中状態が更新されたユーザーのみを取得
    const thirtySecondsAgo = new Date(Date.now() - 30000);
    
    const typingUsers = await this.databaseService.db
      .select({
        userId: typingStatus.userId,
        username: users.username,
      })
      .from(typingStatus)
      .innerJoin(users, eq(typingStatus.userId, users.userId))
      .where(and(
        eq(typingStatus.eventId, eventId),
        eq(typingStatus.isTyping, true)
      ));

    return typingUsers;
  }

  async cleanupOldTypingStatus(eventId: string): Promise<void> {
    const fiveMinutesAgo = new Date(Date.now() - 300000);
    
    await this.databaseService.db
      .update(typingStatus)
      .set({ isTyping: false })
      .where(and(
        eq(typingStatus.eventId, eventId)
      ));
  }
}
