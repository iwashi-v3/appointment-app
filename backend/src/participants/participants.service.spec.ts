import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException, ForbiddenException } from '@nestjs/common';
import { ParticipantsService } from './participants.service';
import { DatabaseService } from '../database/database.service';

describe('ParticipantsService', () => {
  let service: ParticipantsService;
  let mockQueryBuilder: any;

  const mockDatabaseService = {
    db: {
      select: jest.fn(),
      insert: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
  };

  const mockAppointment = {
    appointmentId: 1,
    createdUserId: 'user-1',
    title: 'テスト予約',
  };

  const mockParticipant = {
    id: 1,
    appointmentId: 1,
    userId: 'user-2',
    sessionId: null,
    username: 'テストユーザー',
    isGuest: 'false',
    userLatitude: '35.6812',
    userLongitude: '139.7671',
    joinedAt: new Date(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ParticipantsService,
        {
          provide: DatabaseService,
          useValue: mockDatabaseService,
        },
      ],
    }).compile();

    service = module.get<ParticipantsService>(ParticipantsService);

    // すべてのモックをリセット
    jest.clearAllMocks();
  });

  it('サービスが定義されているべき', () => {
    expect(service).toBeDefined();
  });

  describe('findByAppointment', () => {
    it('予約の参加者一覧を取得できる', async () => {
      const mockChain = {
        from: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue([mockAppointment]),
      };

      // 2つのselect()呼び出しをモック: 1つ目は予約チェック、2つ目は参加者取得
      mockDatabaseService.db.select
        .mockReturnValueOnce(mockChain)
        .mockReturnValueOnce({
          from: jest.fn().mockReturnValue({
            where: jest.fn().mockResolvedValue([
              mockParticipant,
              { ...mockParticipant, id: 2, username: 'ユーザー2' },
            ]),
          }),
        });

      const result = await service.findByAppointment(1, 'user-1');

      expect(mockDatabaseService.db.select).toHaveBeenCalled();
      expect(result).toHaveLength(2);
    });

    it('予約が見つからない場合エラーになる', async () => {
      const mockChain = {
        from: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue([]),
      };

      mockDatabaseService.db.select.mockReturnValueOnce(mockChain);

      await expect(service.findByAppointment(999, 'user-1')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('予約の所有者でない場合エラーになる', async () => {
      const mockChain = {
        from: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue([]),
      };

      mockDatabaseService.db.select.mockReturnValueOnce(mockChain);

      await expect(service.findByAppointment(1, 'user-2')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('updateLocation', () => {
    it('参加者の位置情報を更新できる', async () => {
      const selectMockChain = {
        from: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue([mockParticipant]),
      };

      const updateMockChain = {
        set: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        returning: jest.fn().mockResolvedValue([
          {
            ...mockParticipant,
            userLatitude: '35.7000',
            userLongitude: '139.8000',
          },
        ]),
      };

      mockDatabaseService.db.select.mockReturnValueOnce(selectMockChain);
      mockDatabaseService.db.update.mockReturnValueOnce(updateMockChain);

      const result = await service.updateLocation(1, 35.7, 139.8, 'user-2');

      expect(mockDatabaseService.db.update).toHaveBeenCalled();
      expect(result.userLatitude).toBe('35.7000');
      expect(result.userLongitude).toBe('139.8000');
    });

    it('参加者が見つからない場合エラーになる', async () => {
      const selectMockChain = {
        from: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue([]),
      };

      mockDatabaseService.db.select.mockReturnValueOnce(selectMockChain);

      await expect(
        service.updateLocation(999, 35.7, 139.8, 'user-2'),
      ).rejects.toThrow(NotFoundException);
    });

    it('他人の位置情報は更新できない', async () => {
      const selectMockChain = {
        from: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue([mockParticipant]),
      };

      mockDatabaseService.db.select.mockReturnValueOnce(selectMockChain);

      await expect(
        service.updateLocation(1, 35.7, 139.8, 'user-3'),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('remove', () => {
    it('予約の作成者は参加者を削除できる', async () => {
      const selectMockChain = {
        from: jest.fn().mockReturnThis(),
        innerJoin: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue([
          {
            id: 1,
            appointmentId: 1,
            userId: 'user-2',
            createdUserId: 'user-1',
          },
        ]),
      };

      const deleteMockChain = {
        where: jest.fn().mockResolvedValue([]),
      };

      mockDatabaseService.db.select.mockReturnValueOnce(selectMockChain);
      mockDatabaseService.db.delete.mockReturnValueOnce(deleteMockChain);

      const result = await service.remove(1, 'user-1');

      expect(mockDatabaseService.db.delete).toHaveBeenCalled();
      expect(result.message).toBe('Participant removed successfully');
    });

    it('参加者本人は自分を削除できる', async () => {
      const selectMockChain = {
        from: jest.fn().mockReturnThis(),
        innerJoin: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue([
          {
            id: 1,
            appointmentId: 1,
            userId: 'user-2',
            createdUserId: 'user-1',
          },
        ]),
      };

      const deleteMockChain = {
        where: jest.fn().mockResolvedValue([]),
      };

      mockDatabaseService.db.select.mockReturnValueOnce(selectMockChain);
      mockDatabaseService.db.delete.mockReturnValueOnce(deleteMockChain);

      const result = await service.remove(1, 'user-2');

      expect(mockDatabaseService.db.delete).toHaveBeenCalled();
      expect(result.message).toBe('Participant removed successfully');
    });

    it('参加者が見つからない場合エラーになる', async () => {
      const selectMockChain = {
        from: jest.fn().mockReturnThis(),
        innerJoin: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue([]),
      };

      mockDatabaseService.db.select.mockReturnValueOnce(selectMockChain);

      await expect(service.remove(999, 'user-1')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('権限がない場合エラーになる', async () => {
      const selectMockChain = {
        from: jest.fn().mockReturnThis(),
        innerJoin: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue([
          {
            id: 1,
            appointmentId: 1,
            userId: 'user-2',
            createdUserId: 'user-1',
          },
        ]),
      };

      mockDatabaseService.db.select.mockReturnValueOnce(selectMockChain);

      await expect(service.remove(1, 'user-3')).rejects.toThrow(
        ForbiddenException,
      );
    });
  });
});
