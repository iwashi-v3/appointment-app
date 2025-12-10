import { Injectable } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';

export interface GuestSession {
  sessionId: string;
  username: string;
  createdAt: Date;
  expiresAt: Date;
}

@Injectable()
export class SessionService {
  private sessions = new Map<string, GuestSession>();
  private readonly SESSION_EXPIRY_MS = 24 * 60 * 60 * 1000; // 24時間

  /**
   * 新しいゲストセッションを作成
   */
  createGuestSession(username: string): GuestSession {
    const sessionId = uuidv4();
    const now = new Date();
    const expiresAt = new Date(now.getTime() + this.SESSION_EXPIRY_MS);

    const session: GuestSession = {
      sessionId,
      username,
      createdAt: now,
      expiresAt,
    };

    this.sessions.set(sessionId, session);
    return session;
  }

  /**
   * セッションIDからセッション情報を取得
   */
  getSession(sessionId: string): GuestSession | null {
    const session = this.sessions.get(sessionId);

    if (!session) {
      return null;
    }

    // 有効期限チェック
    if (new Date() > session.expiresAt) {
      this.sessions.delete(sessionId);
      return null;
    }

    return session;
  }

  /**
   * セッションを削除
   */
  deleteSession(sessionId: string): boolean {
    return this.sessions.delete(sessionId);
  }

  /**
   * 期限切れセッションをクリーンアップ
   */
  cleanupExpiredSessions(): number {
    const now = new Date();
    let deletedCount = 0;

    for (const [sessionId, session] of this.sessions.entries()) {
      if (now > session.expiresAt) {
        this.sessions.delete(sessionId);
        deletedCount++;
      }
    }

    return deletedCount;
  }

  /**
   * すべてのアクティブセッション数を取得
   */
  getActiveSessionCount(): number {
    this.cleanupExpiredSessions();
    return this.sessions.size;
  }
}
