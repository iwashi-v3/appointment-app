import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { NotFoundException } from '@nestjs/common';
import { AppointmentsService } from './appointments.service';
import { DatabaseService } from '../database/database.service';

describe('AppointmentsService', () => {
  let service: AppointmentsService;
  let databaseService: DatabaseService;

  // クエリチェーンをモック - 各メソッドが自身を返すシンプルなモック
  let mockQueryBuilder: any;

  const createMockQueryBuilder = () => {
    const builder: any = {
      insert: jest.fn(),
      select: jest.fn(),
      update: jest.fn(),
      from: jest.fn(),
      where: jest.fn(),
      orderBy: jest.fn(),
      limit: jest.fn(),
      values: jest.fn(),
      set: jest.fn(),
      returning: jest.fn(),
    };

    // すべてのメソッドがbuilder自身を返すように設定（チェーン可能に）
    Object.keys(builder).forEach((key) => {
      builder[key].mockReturnValue(builder);
    });

    return builder;
  };

  const mockDatabaseService = {
    db: null as any, // beforeEachで初期化
  };

  const mockConfigService = {
    get: jest.fn().mockReturnValue('http://localhost:3001'),
  };

  const mockAppointment = {
    appointmentId: 1,
    createdUserId: 'user-1',
    title: 'テスト予約',
    latitude: '35.6812',
    longitude: '139.7671',
    appointmentDate: '2025-12-15',
    appointmentTime: '14:00:00',
    status: 'active',
    inviteToken: 'test-token-123',
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    // モックをリセット
    mockQueryBuilder = createMockQueryBuilder();
    mockDatabaseService.db = mockQueryBuilder;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AppointmentsService,
        {
          provide: DatabaseService,
          useValue: mockDatabaseService,
        },
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
      ],
    }).compile();

    service = module.get<AppointmentsService>(AppointmentsService);
    databaseService = module.get<DatabaseService>(DatabaseService);
  });

  it('サービスが定義されているべき', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('予約を作成できる', async () => {
      const createDto = {
        title: 'テスト予約',
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentDate: '2025-12-15',
        appointmentTime: '14:00:00',
      };

      mockQueryBuilder.returning.mockResolvedValue([mockAppointment]);

      const result = await service.create('user-1', createDto);

      expect(mockQueryBuilder.insert).toHaveBeenCalled();
      expect(result).toHaveProperty('inviteUrl');
      expect(result.inviteUrl).toContain(mockAppointment.inviteToken);
    });

    it('statusのデフォルト値がactiveである', async () => {
      const createDto = {
        title: 'テスト予約',
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentDate: '2025-12-15',
        appointmentTime: '14:00:00',
      };

      mockQueryBuilder.returning.mockResolvedValue([mockAppointment]);

      await service.create('user-1', createDto);

      expect(mockQueryBuilder.values).toHaveBeenCalledWith(
        expect.objectContaining({
          status: 'active',
        }),
      );
    });
  });

  describe('findAll', () => {
    it('ユーザーの予約一覧を取得できる', async () => {
      mockQueryBuilder.orderBy.mockResolvedValue([
        mockAppointment,
        { ...mockAppointment, appointmentId: 2 },
      ]);

      const result = await service.findAll('user-1');

      expect(mockQueryBuilder.select).toHaveBeenCalled();
      expect(result).toHaveLength(2);
      expect(result[0]).toHaveProperty('inviteUrl');
    });
  });

  describe('findOne', () => {
    it('予約詳細を取得できる', async () => {
      mockQueryBuilder.limit.mockResolvedValueOnce([mockAppointment]);

      const result = await service.findOne(1, 'user-1');

      expect(mockQueryBuilder.select).toHaveBeenCalled();
      expect(result.appointmentId).toBe(1);
      expect(result).toHaveProperty('inviteUrl');
    });

    it('予約が見つからない場合NotFoundExceptionをスローする', async () => {
      mockQueryBuilder.limit.mockResolvedValueOnce([]);

      await expect(service.findOne(999, 'user-1')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('update', () => {
    it('予約を更新できる', async () => {
      const updateDto = {
        title: '更新されたタイトル',
      };

      mockQueryBuilder.limit.mockResolvedValueOnce([mockAppointment]);
      mockQueryBuilder.returning.mockResolvedValueOnce([
        { ...mockAppointment, title: '更新されたタイトル' },
      ]);

      const result = await service.update(1, 'user-1', updateDto);

      expect(mockQueryBuilder.update).toHaveBeenCalled();
      expect(result.title).toBe('更新されたタイトル');
    });

    it('存在しない予約の更新はエラーになる', async () => {
      mockQueryBuilder.limit.mockResolvedValueOnce([]);

      await expect(
        service.update(999, 'user-1', { title: '新しいタイトル' }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('remove', () => {
    it('予約を論理削除できる', async () => {
      // findOne用のモック（limit.mockResolvedValueOnceで予約を返す）
      mockQueryBuilder.limit.mockResolvedValueOnce([mockAppointment]);
      // update用のモック（最後のwhere.mockResolvedValueOnceで空配列を返す）
      // where は2回呼ばれる: 1回目はfindOne内、2回目はupdate内
      // 1回目はチェーンを返し、2回目だけPromiseを返す
      let whereCallCount = 0;
      mockQueryBuilder.where.mockImplementation(() => {
        whereCallCount++;
        if (whereCallCount === 2) {
          return Promise.resolve([]);
        }
        return mockQueryBuilder;
      });

      const result = await service.remove(1, 'user-1');

      expect(mockQueryBuilder.update).toHaveBeenCalled();
      expect(mockQueryBuilder.set).toHaveBeenCalledWith(
        expect.objectContaining({
          status: 'cancelled',
        }),
      );
      expect(result.message).toBe('Appointment cancelled successfully');
    });

    it('存在しない予約の削除はエラーになる', async () => {
      mockQueryBuilder.limit.mockResolvedValueOnce([]);

      await expect(service.remove(999, 'user-1')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('regenerateInviteUrl', () => {
    it('招待URLを再生成できる', async () => {
      mockQueryBuilder.limit.mockResolvedValueOnce([mockAppointment]);
      mockQueryBuilder.returning.mockResolvedValueOnce([
        { ...mockAppointment, inviteToken: 'new-token-456' },
      ]);

      const result = await service.regenerateInviteUrl(1, 'user-1');

      expect(mockQueryBuilder.update).toHaveBeenCalled();
      expect(result.inviteUrl).toContain('new-token-456');
      expect(result.inviteUrl).not.toContain('test-token-123');
    });

    it('存在しない予約のURL再生成はエラーになる', async () => {
      mockQueryBuilder.limit.mockResolvedValueOnce([]);

      await expect(service.regenerateInviteUrl(999, 'user-1')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
