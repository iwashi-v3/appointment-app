import { Test, TestingModule } from '@nestjs/testing';
import { SessionService } from './session.service';
import { RedisService } from '../../redis/redis.service';

describe('SessionService', () => {
  let service: SessionService;
  let redisService: RedisService;

  const mockRedisService = {
    set: jest.fn(),
    get: jest.fn(),
    del: jest.fn(),
    keys: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SessionService,
        {
          provide: RedisService,
          useValue: mockRedisService,
        },
      ],
    }).compile();

    service = module.get<SessionService>(SessionService);
    redisService = module.get<RedisService>(RedisService);

    // モックをリセット
    jest.clearAllMocks();
  });

  it('サービスが定義されているべき', () => {
    expect(service).toBeDefined();
  });

  describe('createGuestSession', () => {
    it('新しいゲストセッションを作成できる', async () => {
      const username = 'テストユーザー';
      mockRedisService.set.mockResolvedValue(undefined);

      const session = await service.createGuestSession(username);

      expect(session).toBeDefined();
      expect(session.sessionId).toBeDefined();
      expect(session.username).toBe(username);
      expect(session.createdAt).toBeInstanceOf(Date);
      expect(session.expiresAt).toBeInstanceOf(Date);
      expect(session.expiresAt.getTime()).toBeGreaterThan(session.createdAt.getTime());

      expect(mockRedisService.set).toHaveBeenCalledWith(
        expect.stringContaining('session:'),
        expect.any(String),
        86400,
      );
    });

    it('異なるセッションIDを生成する', async () => {
      mockRedisService.set.mockResolvedValue(undefined);

      const session1 = await service.createGuestSession('ユーザー1');
      const session2 = await service.createGuestSession('ユーザー2');

      expect(session1.sessionId).not.toBe(session2.sessionId);
    });
  });

  describe('getSession', () => {
    it('有効なセッションを取得できる', async () => {
      const username = 'テストユーザー';
      const sessionData = {
        sessionId: 'test-session-id',
        username,
        createdAt: new Date(),
        expiresAt: new Date(Date.now() + 86400000),
      };

      mockRedisService.get.mockResolvedValue(JSON.stringify(sessionData));

      const retrievedSession = await service.getSession('test-session-id');

      expect(retrievedSession).toBeDefined();
      expect(retrievedSession?.sessionId).toBe(sessionData.sessionId);
      expect(retrievedSession?.username).toBe(username);
    });

    it('存在しないセッションIDの場合nullを返す', async () => {
      mockRedisService.get.mockResolvedValue(null);

      const session = await service.getSession('non-existent-id');

      expect(session).toBeNull();
    });

    it('期限切れセッションの場合nullを返す', async () => {
      const sessionData = {
        sessionId: 'test-session-id',
        username: 'テストユーザー',
        createdAt: new Date(Date.now() - 90000000),
        expiresAt: new Date(Date.now() - 1000),
      };

      mockRedisService.get.mockResolvedValue(JSON.stringify(sessionData));
      mockRedisService.del.mockResolvedValue(1);

      const retrievedSession = await service.getSession('test-session-id');

      expect(retrievedSession).toBeNull();
      expect(mockRedisService.del).toHaveBeenCalledWith('session:test-session-id');
    });
  });

  describe('deleteSession', () => {
    it('セッションを削除できる', async () => {
      mockRedisService.del.mockResolvedValue(1);

      const deleted = await service.deleteSession('test-session-id');

      expect(deleted).toBe(true);
      expect(mockRedisService.del).toHaveBeenCalledWith('session:test-session-id');
    });

    it('存在しないセッションの削除は失敗する', async () => {
      mockRedisService.del.mockResolvedValue(0);

      const deleted = await service.deleteSession('non-existent-id');

      expect(deleted).toBe(false);
    });
  });

  describe('cleanupExpiredSessions', () => {
    it('Redisが自動的にクリーンアップするため0を返す', async () => {
      const deletedCount = await service.cleanupExpiredSessions();

      expect(deletedCount).toBe(0);
    });
  });

  describe('getActiveSessionCount', () => {
    it('アクティブなセッション数を取得できる', async () => {
      mockRedisService.keys.mockResolvedValue([
        'session:id1',
        'session:id2',
        'session:id3',
      ]);

      const count = await service.getActiveSessionCount();

      expect(count).toBe(3);
      expect(mockRedisService.keys).toHaveBeenCalledWith('session:*');
    });

    it('セッションが存在しない場合は0を返す', async () => {
      mockRedisService.keys.mockResolvedValue([]);

      const count = await service.getActiveSessionCount();

      expect(count).toBe(0);
    });
  });
});
