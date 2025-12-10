export class EventResponseDto {
  eventId: string;
  title: string;
  description?: string;
  location?: string;
  startTime: Date;
  endTime: Date;
  creatorId: string;
  isActive: boolean;
  participants?: ParticipantResponseDto[];
  createdAt: Date;
  updatedAt: Date;
}

export class ParticipantResponseDto {
  userId: string;
  username: string;
  joinedAt: Date;
  leftAt?: Date;
  isCurrentlyInRoom: boolean;
}

export class NotificationResponseDto {
  id: string;
  eventId: string;
  type: 'event_start' | 'event_end' | 'location_change' | 'participant_join' | 'participant_leave';
  message: string;
  createdAt: Date;
}
