import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { WsException } from '@nestjs/websockets';
import { Socket } from 'socket.io';
import { SessionService } from '../services/session.service';

export interface AuthenticatedUser {
  userId?: string;
  email?: string;
  sessionId?: string;
  username?: string;
  isGuest: boolean;
}

@Injectable()
export class WsAuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly sessionService: SessionService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const client: Socket = context.switchToWs().getClient();
    const token = this.extractToken(client);
    const sessionId = this.extractSessionId(client);

    // JWTトークン認証を試行（登録ユーザー）
    if (token) {
      try {
        const payload = this.jwtService.verify(token);
        const user: AuthenticatedUser = {
          userId: payload.sub,
          email: payload.email,
          isGuest: false,
        };
        client.data.user = user;
        return true;
      } catch (error) {
        // トークンが無効な場合は次の認証方法を試す
      }
    }

    // セッションID認証を試行（ゲストユーザー）
    if (sessionId) {
      const session = await this.sessionService.getSession(sessionId);
      if (session) {
        const user: AuthenticatedUser = {
          sessionId: session.sessionId,
          username: session.username,
          isGuest: true,
        };
        client.data.user = user;
        return true;
      }
    }

    throw new WsException('認証に失敗しました');
  }

  /**
   * ヘッダーまたはハンドシェイクからJWTトークンを抽出
   */
  private extractToken(client: Socket): string | null {
    const authHeader =
      client.handshake.headers.authorization ||
      client.handshake.auth?.token;

    if (typeof authHeader === 'string' && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }

    if (typeof authHeader === 'string') {
      return authHeader;
    }

    return null;
  }

  /**
   * ハンドシェイクからセッションIDを抽出
   */
  private extractSessionId(client: Socket): string | null {
    return client.handshake.auth?.sessionId || null;
  }
}
