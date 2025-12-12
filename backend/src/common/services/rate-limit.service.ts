import { Injectable, Logger } from '@nestjs/common';
import { RedisService } from '../../redis/redis.service';

@Injectable()
export class RateLimitService {
  private readonly logger = new Logger(RateLimitService.name);
  private readonly WINDOW_SECONDS = 60; // 1分
  private readonly MAX_REQUESTS = 60; // 1分あたり60リクエスト
  private readonly KEY_PREFIX = 'ratelimit:';

  constructor(private readonly redisService: RedisService) {}

  /**
   * レート制限をチェック（Redisベース）
   * @param key 識別キー（IPアドレスやユーザーIDなど）
   * @returns 制限内であればtrue、超過していればfalse
   */
  async checkLimit(key: string): Promise<boolean> {
    const redisKey = `${this.KEY_PREFIX}${key}`;

    try {
      const current = await this.redisService.incr(redisKey);

      // 初回アクセスの場合、TTLを設定
      if (current === 1) {
        await this.redisService.expire(redisKey, this.WINDOW_SECONDS);
      }

      // 制限を超えているかチェック
      if (current > this.MAX_REQUESTS) {
        this.logger.warn(`Rate limit exceeded for key: ${key}`);
        return false;
      }

      return true;
    } catch (error) {
      this.logger.error('Rate limit check failed:', error);
      // Redisエラー時はアクセスを許可（フェイルオープン）
      return true;
    }
  }

  /**
   * 特定のキーの残りリクエスト数を取得
   */
  async getRemainingRequests(key: string): Promise<number> {
    const redisKey = `${this.KEY_PREFIX}${key}`;

    try {
      const value = await this.redisService.get(redisKey);
      if (!value) {
        return this.MAX_REQUESTS;
      }

      const current = parseInt(value, 10);
      return Math.max(0, this.MAX_REQUESTS - current);
    } catch (error) {
      this.logger.error('Failed to get remaining requests:', error);
      return this.MAX_REQUESTS;
    }
  }

  /**
   * 特定のキーのレート制限をリセット
   */
  async reset(key: string): Promise<void> {
    const redisKey = `${this.KEY_PREFIX}${key}`;

    try {
      await this.redisService.del(redisKey);
    } catch (error) {
      this.logger.error('Failed to reset rate limit:', error);
    }
  }

  /**
   * 期限切れレコードのクリーンアップ（Redisが自動で行うため不要）
   * @deprecated Redis TTLが自動的にクリーンアップを行います
   */
  cleanup(): number {
    // Redisが自動的にTTLで削除するため、このメソッドは何もしない
    return 0;
  }
}
