import { Injectable, Logger } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import { RedisService } from '../../redis/redis.service';

export interface GuestSession {
  sessionId: string;
  username: string;
  createdAt: Date;
  expiresAt: Date;
}

@Injectable()
export class SessionService {
  private readonly logger = new Logger(SessionService.name);
  private readonly SESSION_EXPIRY_SECONDS = 24 * 60 * 60; // 24時間
  private readonly SESSION_KEY_PREFIX = 'session:';

  constructor(private readonly redisService: RedisService) {}

  /**
   * 新しいゲストセッションを作成
   */
  async createGuestSession(username: string): Promise<GuestSession> {
    const sessionId = uuidv4();
    const now = new Date();
    const expiresAt = new Date(now.getTime() + this.SESSION_EXPIRY_SECONDS * 1000);

    const session: GuestSession = {
      sessionId,
      username,
      createdAt: now,
      expiresAt,
    };

    try {
      await this.redisService.set(
        `${this.SESSION_KEY_PREFIX}${sessionId}`,
        JSON.stringify(session),
        this.SESSION_EXPIRY_SECONDS,
      );
      this.logger.log(`Guest session created: ${sessionId}`);
      return session;
    } catch (error) {
      this.logger.error('Failed to create guest session:', error);
      throw error;
    }
  }

  /**
   * セッションIDからセッション情報を取得
   */
  async getSession(sessionId: string): Promise<GuestSession | null> {
    try {
      const data = await this.redisService.get(
        `${this.SESSION_KEY_PREFIX}${sessionId}`,
      );

      if (!data) {
        return null;
      }

      const session: GuestSession = JSON.parse(data);

      // 有効期限チェック（Redisでも自動削除されるが念のため）
      if (new Date() > new Date(session.expiresAt)) {
        await this.deleteSession(sessionId);
        return null;
      }

      return session;
    } catch (error) {
      this.logger.error('Failed to get session:', error);
      return null;
    }
  }

  /**
   * セッションを削除
   */
  async deleteSession(sessionId: string): Promise<boolean> {
    try {
      const result = await this.redisService.del(
        `${this.SESSION_KEY_PREFIX}${sessionId}`,
      );
      return result > 0;
    } catch (error) {
      this.logger.error('Failed to delete session:', error);
      return false;
    }
  }

  /**
   * 期限切れセッションをクリーンアップ（Redisが自動で行うため不要だが互換性のため残す）
   */
  async cleanupExpiredSessions(): Promise<number> {
    // Redisが自動的にTTLで削除するため、このメソッドは何もしない
    return 0;
  }

  /**
   * すべてのアクティブセッション数を取得
   */
  async getActiveSessionCount(): Promise<number> {
    try {
      const keys = await this.redisService.keys(`${this.SESSION_KEY_PREFIX}*`);
      return keys.length;
    } catch (error) {
      this.logger.error('Failed to get active session count:', error);
      return 0;
    }
  }
}
