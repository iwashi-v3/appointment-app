import { Injectable, ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Observable } from 'rxjs';

interface JwtPayload {
  sub: string;
  email: string;
  iat?: number;
  exp?: number;
}

/**
 * オプショナルなJWT認証ガード
 * トークンがあれば検証し、なければ通過させる
 */
@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard('jwt') {
  handleRequest(err: Error | null, user: JwtPayload | false): JwtPayload | null {
    // エラーがあってもユーザーがいなくてもnullを返す（認証をスキップ）
    if (err || !user) {
      return null;
    }
    return user;
  }

  canActivate(context: ExecutionContext): boolean | Promise<boolean> | Observable<boolean> {
    // トークンがない場合でも続行を許可
    return super.canActivate(context) as Promise<boolean>;
  }
}
