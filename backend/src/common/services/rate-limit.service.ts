import { Injectable } from '@nestjs/common';

interface RateLimitRecord {
  count: number;
  resetAt: Date;
}

@Injectable()
export class RateLimitService {
  private records = new Map<string, RateLimitRecord>();
  private readonly WINDOW_MS = 60 * 1000; // 1分
  private readonly MAX_REQUESTS = 60; // 1分あたり60リクエスト

  /**
   * レート制限をチェック
   * @param key 識別キー（IPアドレスやユーザーIDなど）
   * @returns 制限内であればtrue、超過していればfalse
   */
  checkLimit(key: string): boolean {
    const now = new Date();
    const record = this.records.get(key);

    // レコードが存在しない、または期限切れの場合は新規作成
    if (!record || now > record.resetAt) {
      this.records.set(key, {
        count: 1,
        resetAt: new Date(now.getTime() + this.WINDOW_MS),
      });
      return true;
    }

    // カウントを増やす
    record.count++;

    // 制限を超えているかチェック
    if (record.count > this.MAX_REQUESTS) {
      return false;
    }

    return true;
  }

  /**
   * 特定のキーの残りリクエスト数を取得
   */
  getRemainingRequests(key: string): number {
    const record = this.records.get(key);
    if (!record) {
      return this.MAX_REQUESTS;
    }

    const now = new Date();
    if (now > record.resetAt) {
      return this.MAX_REQUESTS;
    }

    return Math.max(0, this.MAX_REQUESTS - record.count);
  }

  /**
   * 期限切れレコードをクリーンアップ
   */
  cleanup(): number {
    const now = new Date();
    let deletedCount = 0;

    for (const [key, record] of this.records.entries()) {
      if (now > record.resetAt) {
        this.records.delete(key);
        deletedCount++;
      }
    }

    return deletedCount;
  }

  /**
   * 特定のキーのレート制限をリセット
   */
  reset(key: string): void {
    this.records.delete(key);
  }
}
