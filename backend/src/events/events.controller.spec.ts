import { Test, TestingModule } from '@nestjs/testing';
import { EventsController } from './events.controller';
import { EventsService } from './events.service';

describe('EventsController', () => {
  let controller: EventsController;
  let mockEventsService: jest.Mocked<EventsService>;

  beforeEach(async () => {
    mockEventsService = {
      createEvent: jest.fn(),
      getAllEvents: jest.fn(),
      getEventById: jest.fn(),
      updateEvent: jest.fn(),
      deleteEvent: jest.fn(),
      startEvent: jest.fn(),
      endEvent: jest.fn(),
      joinEvent: jest.fn(),
      leaveEvent: jest.fn(),
      getEventParticipants: jest.fn(),
      getEventNotifications: jest.fn(),
    } as any;

    const module: TestingModule = await Test.createTestingModule({
      controllers: [EventsController],
      providers: [
        {
          provide: EventsService,
          useValue: mockEventsService,
        },
      ],
    }).compile();

    controller = module.get<EventsController>(EventsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('createEvent', () => {
    it('should create an event', async () => {
      const createEventDto = {
        title: 'Test Event',
        description: 'Test Description',
        location: 'Test Location',
        startTime: '2024-12-11T10:00:00Z',
        endTime: '2024-12-11T12:00:00Z',
      };

      const expectedResponse = {
        eventId: 'test-event-id',
        ...createEventDto,
        startTime: new Date(createEventDto.startTime),
        endTime: new Date(createEventDto.endTime),
        creatorId: 'user-1',
        isActive: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockEventsService.createEvent.mockResolvedValue(expectedResponse);

      const result = await controller.createEvent(createEventDto, { userId: 'user-1' });

      expect(mockEventsService.createEvent).toHaveBeenCalledWith(createEventDto, 'user-1');
      expect(result).toEqual(expectedResponse);
    });
  });
});
