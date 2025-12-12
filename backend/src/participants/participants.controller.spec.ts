import { Test, TestingModule } from '@nestjs/testing';
import { ParticipantsController } from './participants.controller';
import { ParticipantsService } from './participants.service';
import { CurrentUserData } from '../auth/strategies/jwt.strategy';

describe('ParticipantsController', () => {
  let controller: ParticipantsController;
  let service: ParticipantsService;

  const mockParticipantsService = {
    updateLocation: jest.fn(),
    remove: jest.fn(),
  };

  const currentUser: CurrentUserData = {
    userId: 'user-1',
    email: 'test@example.com',
  };

  const mockParticipant = {
    id: 1,
    appointmentId: 1,
    userId: 'user-1',
    username: 'テストユーザー',
    isGuest: 'false',
    userLatitude: '35.6812',
    userLongitude: '139.7671',
    joinedAt: new Date(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ParticipantsController],
      providers: [
        {
          provide: ParticipantsService,
          useValue: mockParticipantsService,
        },
      ],
    }).compile();

    controller = module.get<ParticipantsController>(ParticipantsController);
    service = module.get<ParticipantsService>(ParticipantsService);

    jest.clearAllMocks();
  });

  it('コントローラーが定義されているべき', () => {
    expect(controller).toBeDefined();
  });

  describe('updateLocation', () => {
    it('参加者の位置情報を更新できる', async () => {
      const updateDto = {
        userLatitude: 35.7,
        userLongitude: 139.8,
      };

      mockParticipantsService.updateLocation.mockResolvedValue({
        ...mockParticipant,
        userLatitude: '35.7',
        userLongitude: '139.8',
      });

      const result = await controller.updateLocation(1, updateDto, currentUser);

      expect(mockParticipantsService.updateLocation).toHaveBeenCalledWith(
        1,
        35.7,
        139.8,
        currentUser.userId,
      );
      expect(result.userLatitude).toBe('35.7');
    });
  });

  describe('remove', () => {
    it('参加者を削除できる', async () => {
      mockParticipantsService.remove.mockResolvedValue({
        message: 'Participant removed successfully',
      });

      const result = await controller.remove(1, currentUser);

      expect(mockParticipantsService.remove).toHaveBeenCalledWith(
        1,
        currentUser.userId,
      );
      expect(result.message).toBe('Participant removed successfully');
    });
  });
});
