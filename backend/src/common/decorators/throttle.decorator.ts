import { SetMetadata } from '@nestjs/common';

export const THROTTLE_KEY = 'throttle';

export interface ThrottleOptions {
  limit: number; // 許可するリクエスト数
  ttl: number; // 時間枠（ミリ秒）
}

/**
 * スロットリングデコレータ
 * @param options スロットリング設定
 */
export const Throttle = (options: ThrottleOptions) =>
  SetMetadata(THROTTLE_KEY, options);
