import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { WsException } from '@nestjs/websockets';
import { Socket } from 'socket.io';
import { RateLimitService } from '../../common/services/rate-limit.service';

@Injectable()
export class WsRateLimitGuard implements CanActivate {
  constructor(private readonly rateLimitService: RateLimitService) {}

  canActivate(context: ExecutionContext): boolean {
    const client: Socket = context.switchToWs().getClient();
    const key = this.getIdentifier(client);

    const isAllowed = this.rateLimitService.checkLimit(key);

    if (!isAllowed) {
      throw new WsException('レート制限を超過しました。しばらくしてから再試行してください。');
    }

    return true;
  }

  /**
   * クライアントの識別子を取得
   * ユーザーIDまたはIPアドレスを使用
   */
  private getIdentifier(client: Socket): string {
    // 認証済みユーザーの場合はユーザーIDを使用
    if (client.data.user?.userId) {
      return `user:${client.data.user.userId}`;
    }

    // ゲストの場合はセッションIDを使用
    if (client.data.user?.sessionId) {
      return `session:${client.data.user.sessionId}`;
    }

    // 認証前の場合はIPアドレスを使用
    const ip = client.handshake.address;
    return `ip:${ip}`;
  }
}
