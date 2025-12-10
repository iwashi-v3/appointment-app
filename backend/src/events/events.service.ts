import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { events, eventParticipants, eventNotifications, Event, NewEvent, NewEventParticipant, NewEventNotification } from '../database/schema/events.schema';
import { users } from '../database/schema/users.schema';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';
import { EventResponseDto, ParticipantResponseDto, NotificationResponseDto } from './dto/event-response.dto';
import { EventsGateway } from './events.gateway';
import { eq, and, isNull } from 'drizzle-orm';
const { v4: uuidv4 } = require('uuid');

@Injectable()
export class EventsService {
  constructor(
    private readonly databaseService: DatabaseService,
    private readonly eventsGateway: EventsGateway,
  ) {}

  async createEvent(createEventDto: CreateEventDto, creatorId: string): Promise<EventResponseDto> {
    const eventId = uuidv4();
    
    const newEvent: NewEvent = {
      eventId,
      title: createEventDto.title,
      description: createEventDto.description,
      location: createEventDto.location,
      startTime: new Date(createEventDto.startTime),
      endTime: new Date(createEventDto.endTime),
      creatorId,
      isActive: false,
    };

    const [createdEvent] = await this.databaseService.db
      .insert(events)
      .values(newEvent)
      .returning();

    return this.mapEventToResponse(createdEvent);
  }

  async getAllEvents(): Promise<EventResponseDto[]> {
    const eventList = await this.databaseService.db
      .select()
      .from(events)
      .where(isNull(events.deletedAt));

    return eventList.map(event => this.mapEventToResponse(event));
  }

  async getEventById(eventId: string): Promise<EventResponseDto> {
    const event = await this.databaseService.db
      .select()
      .from(events)
      .where(and(eq(events.eventId, eventId), isNull(events.deletedAt)))
      .limit(1);

    if (!event.length) {
      throw new NotFoundException('Event not found');
    }

    const participants = await this.getEventParticipants(eventId);
    const eventResponse = this.mapEventToResponse(event[0]);
    eventResponse.participants = participants;

    return eventResponse;
  }

  async updateEvent(eventId: string, updateEventDto: UpdateEventDto, userId: string): Promise<EventResponseDto> {
    const event = await this.databaseService.db
      .select()
      .from(events)
      .where(and(eq(events.eventId, eventId), isNull(events.deletedAt)))
      .limit(1);

    if (!event.length) {
      throw new NotFoundException('Event not found');
    }

    if (event[0].creatorId !== userId) {
      throw new BadRequestException('Only the event creator can update the event');
    }

    const updateData: Partial<Event> = {
      ...updateEventDto,
      startTime: updateEventDto.startTime ? new Date(updateEventDto.startTime) : undefined,
      endTime: updateEventDto.endTime ? new Date(updateEventDto.endTime) : undefined,
      updatedAt: new Date(),
    };

    const [updatedEvent] = await this.databaseService.db
      .update(events)
      .set(updateData)
      .where(eq(events.eventId, eventId))
      .returning();

    // Notify about location change if location was updated
    if (updateEventDto.location && updateEventDto.location !== event[0].location) {
      this.eventsGateway.notifyLocationChange(eventId, updateEventDto.location, updatedEvent.title);
      
      // Save notification to database
      await this.createNotification({
        eventId,
        type: 'location_change',
        message: `イベント「${updatedEvent.title}」の集合場所が「${updateEventDto.location}」に変更されました`,
      });
    }

    return this.mapEventToResponse(updatedEvent);
  }

  async deleteEvent(eventId: string, userId: string): Promise<void> {
    const event = await this.databaseService.db
      .select()
      .from(events)
      .where(and(eq(events.eventId, eventId), isNull(events.deletedAt)))
      .limit(1);

    if (!event.length) {
      throw new NotFoundException('Event not found');
    }

    if (event[0].creatorId !== userId) {
      throw new BadRequestException('Only the event creator can delete the event');
    }

    await this.databaseService.db
      .update(events)
      .set({ deletedAt: new Date() })
      .where(eq(events.eventId, eventId));
  }

  async startEvent(eventId: string, userId: string): Promise<EventResponseDto> {
    const event = await this.databaseService.db
      .select()
      .from(events)
      .where(and(eq(events.eventId, eventId), isNull(events.deletedAt)))
      .limit(1);

    if (!event.length) {
      throw new NotFoundException('Event not found');
    }

    if (event[0].creatorId !== userId) {
      throw new BadRequestException('Only the event creator can start the event');
    }

    const [updatedEvent] = await this.databaseService.db
      .update(events)
      .set({ isActive: true, updatedAt: new Date() })
      .where(eq(events.eventId, eventId))
      .returning();

    // Notify participants
    this.eventsGateway.notifyEventStart(eventId, updatedEvent.title);
    
    // Save notification to database
    await this.createNotification({
      eventId,
      type: 'event_start',
      message: `イベント「${updatedEvent.title}」が開始されました`,
    });

    return this.mapEventToResponse(updatedEvent);
  }

  async endEvent(eventId: string, userId: string): Promise<EventResponseDto> {
    const event = await this.databaseService.db
      .select()
      .from(events)
      .where(and(eq(events.eventId, eventId), isNull(events.deletedAt)))
      .limit(1);

    if (!event.length) {
      throw new NotFoundException('Event not found');
    }

    if (event[0].creatorId !== userId) {
      throw new BadRequestException('Only the event creator can end the event');
    }

    const [updatedEvent] = await this.databaseService.db
      .update(events)
      .set({ isActive: false, updatedAt: new Date() })
      .where(eq(events.eventId, eventId))
      .returning();

    // Notify participants
    this.eventsGateway.notifyEventEnd(eventId, updatedEvent.title);
    
    // Save notification to database
    await this.createNotification({
      eventId,
      type: 'event_end',
      message: `イベント「${updatedEvent.title}」が終了しました`,
    });

    return this.mapEventToResponse(updatedEvent);
  }

  async joinEvent(eventId: string, userId: string): Promise<void> {
    const event = await this.databaseService.db
      .select()
      .from(events)
      .where(and(eq(events.eventId, eventId), isNull(events.deletedAt)))
      .limit(1);

    if (!event.length) {
      throw new NotFoundException('Event not found');
    }

    // Check if user is already a participant
    const existingParticipant = await this.databaseService.db
      .select()
      .from(eventParticipants)
      .where(and(
        eq(eventParticipants.eventId, eventId),
        eq(eventParticipants.userId, userId),
        isNull(eventParticipants.leftAt)
      ))
      .limit(1);

    if (existingParticipant.length) {
      // Update to currently in room
      await this.databaseService.db
        .update(eventParticipants)
        .set({ isCurrentlyInRoom: true })
        .where(eq(eventParticipants.id, existingParticipant[0].id));
    } else {
      // Add new participant
      const newParticipant: NewEventParticipant = {
        id: uuidv4(),
        eventId,
        userId,
        isCurrentlyInRoom: true,
      };

      await this.databaseService.db
        .insert(eventParticipants)
        .values(newParticipant);
    }

    // Save notification to database
    await this.createNotification({
      eventId,
      type: 'participant_join',
      message: `参加者が入室しました`,
    });
  }

  async leaveEvent(eventId: string, userId: string): Promise<void> {
    const participant = await this.databaseService.db
      .select()
      .from(eventParticipants)
      .where(and(
        eq(eventParticipants.eventId, eventId),
        eq(eventParticipants.userId, userId),
        isNull(eventParticipants.leftAt)
      ))
      .limit(1);

    if (!participant.length) {
      throw new NotFoundException('Participant not found');
    }

    await this.databaseService.db
      .update(eventParticipants)
      .set({ 
        leftAt: new Date(),
        isCurrentlyInRoom: false 
      })
      .where(eq(eventParticipants.id, participant[0].id));

    // Save notification to database
    await this.createNotification({
      eventId,
      type: 'participant_leave',
      message: `参加者が退室しました`,
    });
  }

  async getEventParticipants(eventId: string): Promise<ParticipantResponseDto[]> {
    const participantsData = await this.databaseService.db
      .select({
        userId: eventParticipants.userId,
        username: users.username,
        joinedAt: eventParticipants.joinedAt,
        leftAt: eventParticipants.leftAt,
        isCurrentlyInRoom: eventParticipants.isCurrentlyInRoom,
      })
      .from(eventParticipants)
      .innerJoin(users, eq(eventParticipants.userId, users.userId))
      .where(eq(eventParticipants.eventId, eventId));

    return participantsData.map(participant => ({
      userId: participant.userId,
      username: participant.username,
      joinedAt: participant.joinedAt,
      leftAt: participant.leftAt || undefined,
      isCurrentlyInRoom: participant.isCurrentlyInRoom,
    }));
  }

  async getEventNotifications(eventId: string): Promise<NotificationResponseDto[]> {
    const notifications = await this.databaseService.db
      .select()
      .from(eventNotifications)
      .where(eq(eventNotifications.eventId, eventId))
      .orderBy(eventNotifications.createdAt);

    return notifications.map(notification => ({
      id: notification.id,
      eventId: notification.eventId,
      type: notification.type as any,
      message: notification.message,
      createdAt: notification.createdAt,
    }));
  }

  private async createNotification(notification: Omit<NewEventNotification, 'id'>): Promise<void> {
    const newNotification: NewEventNotification = {
      id: uuidv4(),
      ...notification,
    };

    await this.databaseService.db
      .insert(eventNotifications)
      .values(newNotification);
  }

  private mapEventToResponse(event: Event): EventResponseDto {
    return {
      eventId: event.eventId,
      title: event.title,
      description: event.description || undefined,
      location: event.location || undefined,
      startTime: event.startTime,
      endTime: event.endTime,
      creatorId: event.creatorId,
      isActive: event.isActive,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    };
  }
}
