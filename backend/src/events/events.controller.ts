import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { EventsService } from './events.service';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';
import { EventResponseDto, ParticipantResponseDto, NotificationResponseDto } from './dto/event-response.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('events')
@UseGuards(JwtAuthGuard)
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  @Post()
  async createEvent(
    @Body() createEventDto: CreateEventDto,
    @CurrentUser() user: any,
  ): Promise<EventResponseDto> {
    return this.eventsService.createEvent(createEventDto, user.userId);
  }

  @Get()
  async getAllEvents(): Promise<EventResponseDto[]> {
    return this.eventsService.getAllEvents();
  }

  @Get(':eventId')
  async getEventById(@Param('eventId') eventId: string): Promise<EventResponseDto> {
    return this.eventsService.getEventById(eventId);
  }

  @Put(':eventId')
  async updateEvent(
    @Param('eventId') eventId: string,
    @Body() updateEventDto: UpdateEventDto,
    @CurrentUser() user: any,
  ): Promise<EventResponseDto> {
    return this.eventsService.updateEvent(eventId, updateEventDto, user.userId);
  }

  @Delete(':eventId')
  async deleteEvent(
    @Param('eventId') eventId: string,
    @CurrentUser() user: any,
  ): Promise<void> {
    return this.eventsService.deleteEvent(eventId, user.userId);
  }

  @Post(':eventId/start')
  async startEvent(
    @Param('eventId') eventId: string,
    @CurrentUser() user: any,
  ): Promise<EventResponseDto> {
    return this.eventsService.startEvent(eventId, user.userId);
  }

  @Post(':eventId/end')
  async endEvent(
    @Param('eventId') eventId: string,
    @CurrentUser() user: any,
  ): Promise<EventResponseDto> {
    return this.eventsService.endEvent(eventId, user.userId);
  }

  @Post(':eventId/join')
  async joinEvent(
    @Param('eventId') eventId: string,
    @CurrentUser() user: any,
  ): Promise<{ message: string }> {
    await this.eventsService.joinEvent(eventId, user.userId);
    return { message: 'Successfully joined the event' };
  }

  @Post(':eventId/leave')
  async leaveEvent(
    @Param('eventId') eventId: string,
    @CurrentUser() user: any,
  ): Promise<{ message: string }> {
    await this.eventsService.leaveEvent(eventId, user.userId);
    return { message: 'Successfully left the event' };
  }

  @Get(':eventId/participants')
  async getEventParticipants(@Param('eventId') eventId: string): Promise<ParticipantResponseDto[]> {
    return this.eventsService.getEventParticipants(eventId);
  }

  @Get(':eventId/notifications')
  async getEventNotifications(@Param('eventId') eventId: string): Promise<NotificationResponseDto[]> {
    return this.eventsService.getEventNotifications(eventId);
  }
}
