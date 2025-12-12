import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { WsException } from '@nestjs/websockets';
import { Socket } from 'socket.io';
import { THROTTLE_KEY, ThrottleOptions } from '../decorators/throttle.decorator';

interface ThrottleRecord {
  count: number;
  resetAt: number;
}

@Injectable()
export class WsThrottleGuard implements CanActivate {
  private records = new Map<string, ThrottleRecord>();

  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const throttleOptions = this.reflector.get<ThrottleOptions>(
      THROTTLE_KEY,
      context.getHandler(),
    );

    if (!throttleOptions) {
      return true;
    }

    const client: Socket = context.switchToWs().getClient();
    const key = this.getThrottleKey(client, context);

    const now = Date.now();
    const record = this.records.get(key);

    // レコードが存在しない、または期限切れの場合は新規作成
    if (!record || now > record.resetAt) {
      this.records.set(key, {
        count: 1,
        resetAt: now + throttleOptions.ttl,
      });
      return true;
    }

    // カウントを増やす
    record.count++;

    // 制限を超えているかチェック
    if (record.count > throttleOptions.limit) {
      const retryAfter = Math.ceil((record.resetAt - now) / 1000);
      throw new WsException(
        `更新頻度が高すぎます。${retryAfter}秒後に再試行してください。`,
      );
    }

    return true;
  }

  /**
   * スロットリングキーを生成
   */
  private getThrottleKey(client: Socket, context: ExecutionContext): string {
    const handler = context.getHandler().name;
    const userId = client.data.user?.userId || client.data.user?.sessionId || client.id;

    return `${userId}:${handler}`;
  }

  /**
   * 期限切れレコードをクリーンアップ
   */
  cleanup(): number {
    const now = Date.now();
    let deletedCount = 0;

    for (const [key, record] of this.records.entries()) {
      if (now > record.resetAt) {
        this.records.delete(key);
        deletedCount++;
      }
    }

    return deletedCount;
  }
}
