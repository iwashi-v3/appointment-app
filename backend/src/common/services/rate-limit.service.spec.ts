import { Test, TestingModule } from '@nestjs/testing';
import { RateLimitService } from './rate-limit.service';
import { RedisService } from '../../redis/redis.service';

describe('RateLimitService', () => {
  let service: RateLimitService;
  let redisService: RedisService;

  const mockRedisService = {
    incr: jest.fn(),
    expire: jest.fn(),
    get: jest.fn(),
    del: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RateLimitService,
        {
          provide: RedisService,
          useValue: mockRedisService,
        },
      ],
    }).compile();

    service = module.get<RateLimitService>(RateLimitService);
    redisService = module.get<RedisService>(RedisService);

    // モックをリセット
    jest.clearAllMocks();
  });

  it('サービスが定義されているべき', () => {
    expect(service).toBeDefined();
  });

  describe('checkLimit', () => {
    it('初回リクエストは許可される', async () => {
      const key = 'test-user';
      mockRedisService.incr.mockResolvedValue(1);
      mockRedisService.expire.mockResolvedValue(1);

      const isAllowed = await service.checkLimit(key);

      expect(isAllowed).toBe(true);
      expect(mockRedisService.incr).toHaveBeenCalledWith('ratelimit:test-user');
      expect(mockRedisService.expire).toHaveBeenCalledWith('ratelimit:test-user', 60);
    });

    it('制限内のリクエストは許可される', async () => {
      const key = 'test-user';
      mockRedisService.incr.mockResolvedValue(10);

      const isAllowed = await service.checkLimit(key);

      expect(isAllowed).toBe(true);
    });

    it('制限を超えたリクエストは拒否される', async () => {
      const key = 'test-user';
      mockRedisService.incr.mockResolvedValue(61);

      const isAllowed = await service.checkLimit(key);

      expect(isAllowed).toBe(false);
    });

    it('Redisエラー時はアクセスを許可（フェイルオープン）', async () => {
      const key = 'test-user';
      mockRedisService.incr.mockRejectedValue(new Error('Redis connection failed'));

      const isAllowed = await service.checkLimit(key);

      expect(isAllowed).toBe(true);
    });
  });

  describe('getRemainingRequests', () => {
    it('初回は最大リクエスト数を返す', async () => {
      const key = 'test-user';
      mockRedisService.get.mockResolvedValue(null);

      const remaining = await service.getRemainingRequests(key);

      expect(remaining).toBe(60);
    });

    it('リクエスト後に残数が減る', async () => {
      const key = 'test-user';
      mockRedisService.get.mockResolvedValue('3');

      const remaining = await service.getRemainingRequests(key);

      expect(remaining).toBe(57);
    });

    it('残数が0未満にならない', async () => {
      const key = 'test-user';
      mockRedisService.get.mockResolvedValue('70');

      const remaining = await service.getRemainingRequests(key);

      expect(remaining).toBe(0);
    });

    it('Redisエラー時は最大リクエスト数を返す', async () => {
      const key = 'test-user';
      mockRedisService.get.mockRejectedValue(new Error('Redis error'));

      const remaining = await service.getRemainingRequests(key);

      expect(remaining).toBe(60);
    });
  });

  describe('cleanup', () => {
    it('Redisが自動的にクリーンアップするため0を返す', () => {
      const deletedCount = service.cleanup();

      expect(deletedCount).toBe(0);
    });
  });

  describe('reset', () => {
    it('特定のキーのレート制限をリセットできる', async () => {
      const key = 'test-user';
      mockRedisService.del.mockResolvedValue(1);

      await service.reset(key);

      expect(mockRedisService.del).toHaveBeenCalledWith('ratelimit:test-user');
    });

    it('Redisエラー時も例外をスローしない', async () => {
      const key = 'test-user';
      mockRedisService.del.mockRejectedValue(new Error('Redis error'));

      await expect(service.reset(key)).resolves.not.toThrow();
    });
  });
});
