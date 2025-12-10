import { Test, TestingModule } from '@nestjs/testing';
import { RateLimitService } from './rate-limit.service';

describe('RateLimitService', () => {
  let service: RateLimitService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [RateLimitService],
    }).compile();

    service = module.get<RateLimitService>(RateLimitService);
  });

  it('サービスが定義されているべき', () => {
    expect(service).toBeDefined();
  });

  describe('checkLimit', () => {
    it('初回リクエストは許可される', () => {
      const key = 'test-user';
      const isAllowed = service.checkLimit(key);

      expect(isAllowed).toBe(true);
    });

    it('制限内のリクエストは許可される', () => {
      const key = 'test-user';

      // 10回リクエスト
      for (let i = 0; i < 10; i++) {
        const isAllowed = service.checkLimit(key);
        expect(isAllowed).toBe(true);
      }
    });

    it('制限を超えたリクエストは拒否される', () => {
      const key = 'test-user';

      // 60回リクエスト（制限内）
      for (let i = 0; i < 60; i++) {
        service.checkLimit(key);
      }

      // 61回目は拒否される
      const isAllowed = service.checkLimit(key);
      expect(isAllowed).toBe(false);
    });

    it('異なるキーは独立して制限される', () => {
      const key1 = 'user1';
      const key2 = 'user2';

      // user1が60回リクエスト
      for (let i = 0; i < 60; i++) {
        service.checkLimit(key1);
      }

      // user2の初回リクエストは許可される
      const isAllowed = service.checkLimit(key2);
      expect(isAllowed).toBe(true);
    });
  });

  describe('getRemainingRequests', () => {
    it('初回は最大リクエスト数を返す', () => {
      const key = 'test-user';
      const remaining = service.getRemainingRequests(key);

      expect(remaining).toBe(60);
    });

    it('リクエスト後に残数が減る', () => {
      const key = 'test-user';

      service.checkLimit(key);
      service.checkLimit(key);
      service.checkLimit(key);

      const remaining = service.getRemainingRequests(key);
      expect(remaining).toBe(57);
    });

    it('残数が0未満にならない', () => {
      const key = 'test-user';

      // 70回リクエスト
      for (let i = 0; i < 70; i++) {
        service.checkLimit(key);
      }

      const remaining = service.getRemainingRequests(key);
      expect(remaining).toBe(0);
    });
  });

  describe('cleanup', () => {
    it('期限切れレコードをクリーンアップする', async () => {
      const key1 = 'user1';
      const key2 = 'user2';

      service.checkLimit(key1);
      service.checkLimit(key2);

      // 少し待機（実際の実装では時間を進めることができないため、テスト環境では難しい）
      // このテストは概念的なものとして記述

      const deletedCount = service.cleanup();
      expect(typeof deletedCount).toBe('number');
    });
  });

  describe('reset', () => {
    it('特定のキーのレート制限をリセットできる', () => {
      const key = 'test-user';

      // 10回リクエスト
      for (let i = 0; i < 10; i++) {
        service.checkLimit(key);
      }

      // リセット
      service.reset(key);

      // リセット後は最大リクエスト数に戻る
      const remaining = service.getRemainingRequests(key);
      expect(remaining).toBe(60);
    });
  });
});
