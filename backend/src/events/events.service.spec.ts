import { Test, TestingModule } from '@nestjs/testing';
import { EventsService } from './events.service';
import { EventsGateway } from './events.gateway';
import { DatabaseService } from '../database/database.service';

describe('EventsService', () => {
  let service: EventsService;
  let mockDatabaseService: jest.Mocked<DatabaseService>;
  let mockEventsGateway: jest.Mocked<EventsGateway>;

  beforeEach(async () => {
    const mockDb = {
      select: jest.fn(),
      insert: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    };

    mockDatabaseService = {
      db: mockDb,
    } as any;

    mockEventsGateway = {
      notifyEventStart: jest.fn(),
      notifyEventEnd: jest.fn(),
      notifyLocationChange: jest.fn(),
      notifyParticipantJoined: jest.fn(),
      notifyParticipantLeft: jest.fn(),
    } as any;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        EventsService,
        {
          provide: DatabaseService,
          useValue: mockDatabaseService,
        },
        {
          provide: EventsGateway,
          useValue: mockEventsGateway,
        },
      ],
    }).compile();

    service = module.get<EventsService>(EventsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createEvent', () => {
    it('should create an event successfully', async () => {
      const createEventDto = {
        title: 'Test Event',
        description: 'Test Description',
        location: 'Test Location',
        startTime: '2024-12-11T10:00:00Z',
        endTime: '2024-12-11T12:00:00Z',
      };

      const mockCreatedEvent = {
        eventId: 'test-event-id',
        ...createEventDto,
        startTime: new Date(createEventDto.startTime),
        endTime: new Date(createEventDto.endTime),
        creatorId: 'user-1',
        isActive: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockDatabaseService.db.insert = jest.fn().mockReturnValue({
        values: jest.fn().mockReturnValue({
          returning: jest.fn().mockResolvedValue([mockCreatedEvent]),
        }),
      });

      const result = await service.createEvent(createEventDto, 'user-1');

      expect(result).toEqual({
        eventId: 'test-event-id',
        title: 'Test Event',
        description: 'Test Description',
        location: 'Test Location',
        startTime: new Date(createEventDto.startTime),
        endTime: new Date(createEventDto.endTime),
        creatorId: 'user-1',
        isActive: false,
        createdAt: mockCreatedEvent.createdAt,
        updatedAt: mockCreatedEvent.updatedAt,
      });
    });
  });
});
