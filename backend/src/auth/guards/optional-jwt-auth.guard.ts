import { Injectable, ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/**
 * オプショナルなJWT認証ガード
 * トークンがあれば検証し、なければ通過させる
 */
@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard('jwt') {
  handleRequest(err: any, user: any) {
    // エラーがあってもユーザーがいなくてもnullを返す（認証をスキップ）
    if (err || !user) {
      return null;
    }
    return user;
  }

  canActivate(context: ExecutionContext) {
    // トークンがない場合でも続行を許可
    return super.canActivate(context) as Promise<boolean>;
  }
}
