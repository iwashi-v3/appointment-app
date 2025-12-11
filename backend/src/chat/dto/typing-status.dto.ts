import { IsString, IsUUID, IsBoolean } from 'class-validator';

export class TypingStatusDto {
  @IsString()
  @IsUUID()
  eventId: string;

  @IsBoolean()
  isTyping: boolean;
}
