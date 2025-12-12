import { Test, TestingModule } from '@nestjs/testing';
import { ChatService } from './chat.service';
import { DatabaseService } from '../database/database.service';

describe('ChatService', () => {
  let service: ChatService;
  let mockDatabaseService: Partial<DatabaseService>;

  beforeEach(async () => {
    mockDatabaseService = {
      db: {
        insert: jest.fn(),
        select: jest.fn(),
        update: jest.fn(),
      } as any,
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChatService,
        {
          provide: DatabaseService,
          useValue: mockDatabaseService,
        },
      ],
    }).compile();

    service = module.get<ChatService>(ChatService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // メッセージ作成のテスト
  describe('createMessage', () => {
    it('should create a message successfully', async () => {
      const createMessageDto = {
        eventId: 'test-event-id',
        content: 'Hello, world!',
        messageType: 'text' as any,
      };
      const senderId = 'test-user-id';

      const mockMessage = {
        messageId: 'test-message-id',
        eventId: createMessageDto.eventId,
        senderId,
        senderUsername: 'testuser',
        content: createMessageDto.content,
        messageType: createMessageDto.messageType,
        isEdited: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      (mockDatabaseService.db!.insert as jest.Mock).mockResolvedValue({});
      (mockDatabaseService.db!.select as jest.Mock).mockReturnValue({
        from: jest.fn().mockReturnThis(),
        innerJoin: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue([mockMessage]),
      });

      const result = await service.createMessage(createMessageDto, senderId);
      
      expect(result).toEqual(mockMessage);
      expect(mockDatabaseService.db!.insert).toHaveBeenCalled();
    });
  });

  // メッセージ履歴取得のテスト
  describe('getMessageHistory', () => {
    it('should return message history', async () => {
      const eventId = 'test-event-id';
      const mockHistory = [
        {
          messageId: 'msg1',
          eventId,
          senderId: 'user1',
          senderUsername: 'user1name',
          content: 'Message 1',
          messageType: 'text',
          isEdited: false,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ];

      (mockDatabaseService.db!.select as jest.Mock).mockReturnValue({
        from: jest.fn().mockReturnThis(),
        innerJoin: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        offset: jest.fn().mockResolvedValue(mockHistory),
      });

      const result = await service.getMessageHistory(eventId);
      
      expect(result).toEqual(mockHistory);
    });
  });
});
