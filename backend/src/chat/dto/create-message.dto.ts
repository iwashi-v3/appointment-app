import { IsString, IsOptional, IsEnum, IsUUID } from 'class-validator';

export enum MessageType {
  TEXT = 'text',
  SYSTEM = 'system',
  IMAGE = 'image',
}

export class CreateMessageDto {
  @IsString()
  @IsUUID()
  eventId: string;

  @IsString()
  content: string;

  @IsOptional()
  @IsEnum(MessageType)
  messageType?: MessageType = MessageType.TEXT;
}
