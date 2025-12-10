import { Test, TestingModule } from '@nestjs/testing';
import { SessionService } from './session.service';

describe('SessionService', () => {
  let service: SessionService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [SessionService],
    }).compile();

    service = module.get<SessionService>(SessionService);
  });

  it('サービスが定義されているべき', () => {
    expect(service).toBeDefined();
  });

  describe('createGuestSession', () => {
    it('新しいゲストセッションを作成できる', () => {
      const username = 'テストユーザー';
      const session = service.createGuestSession(username);

      expect(session).toBeDefined();
      expect(session.sessionId).toBeDefined();
      expect(session.username).toBe(username);
      expect(session.createdAt).toBeInstanceOf(Date);
      expect(session.expiresAt).toBeInstanceOf(Date);
      expect(session.expiresAt.getTime()).toBeGreaterThan(session.createdAt.getTime());
    });

    it('異なるセッションIDを生成する', () => {
      const session1 = service.createGuestSession('ユーザー1');
      const session2 = service.createGuestSession('ユーザー2');

      expect(session1.sessionId).not.toBe(session2.sessionId);
    });
  });

  describe('getSession', () => {
    it('有効なセッションを取得できる', () => {
      const username = 'テストユーザー';
      const createdSession = service.createGuestSession(username);

      const retrievedSession = service.getSession(createdSession.sessionId);

      expect(retrievedSession).toBeDefined();
      expect(retrievedSession?.sessionId).toBe(createdSession.sessionId);
      expect(retrievedSession?.username).toBe(username);
    });

    it('存在しないセッションIDの場合nullを返す', () => {
      const session = service.getSession('non-existent-id');

      expect(session).toBeNull();
    });

    it('期限切れセッションの場合nullを返す', () => {
      const username = 'テストユーザー';
      const session = service.createGuestSession(username);

      // 有効期限を過去に設定
      session.expiresAt = new Date(Date.now() - 1000);

      const retrievedSession = service.getSession(session.sessionId);

      expect(retrievedSession).toBeNull();
    });
  });

  describe('deleteSession', () => {
    it('セッションを削除できる', () => {
      const session = service.createGuestSession('テストユーザー');

      const deleted = service.deleteSession(session.sessionId);
      expect(deleted).toBe(true);

      const retrievedSession = service.getSession(session.sessionId);
      expect(retrievedSession).toBeNull();
    });

    it('存在しないセッションの削除は失敗する', () => {
      const deleted = service.deleteSession('non-existent-id');

      expect(deleted).toBe(false);
    });
  });

  describe('cleanupExpiredSessions', () => {
    it('期限切れセッションをクリーンアップする', () => {
      // 有効なセッションを作成
      const validSession = service.createGuestSession('有効ユーザー');

      // 期限切れセッションを作成
      const expiredSession = service.createGuestSession('期限切れユーザー');
      expiredSession.expiresAt = new Date(Date.now() - 1000);

      const deletedCount = service.cleanupExpiredSessions();

      expect(deletedCount).toBe(1);
      expect(service.getSession(validSession.sessionId)).toBeDefined();
      expect(service.getSession(expiredSession.sessionId)).toBeNull();
    });
  });

  describe('getActiveSessionCount', () => {
    it('アクティブなセッション数を取得できる', () => {
      service.createGuestSession('ユーザー1');
      service.createGuestSession('ユーザー2');
      service.createGuestSession('ユーザー3');

      const count = service.getActiveSessionCount();

      expect(count).toBe(3);
    });

    it('期限切れセッションはカウントされない', () => {
      service.createGuestSession('有効ユーザー');

      const expiredSession = service.createGuestSession('期限切れユーザー');
      expiredSession.expiresAt = new Date(Date.now() - 1000);

      const count = service.getActiveSessionCount();

      expect(count).toBe(1);
    });
  });
});
