export class MessageResponseDto {
  messageId: string;
  eventId: string;
  senderId: string;
  senderUsername: string;
  content: string;
  messageType: string;
  isEdited: boolean;
  createdAt: Date;
  updatedAt: Date;
}
