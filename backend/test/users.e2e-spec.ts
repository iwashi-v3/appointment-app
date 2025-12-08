import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Users (e2e)', () => {
  let app: INestApplication;
  let accessToken: string;
  let userId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();

    // main.tsと同じ設定を適用
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );

    await app.init();

    // テスト用ユーザーを作成してトークンを取得
    const signupResponse = await request(app.getHttpServer())
      .post('/auth/signup')
      .send({
        username: 'userstest',
        email: 'userstest@example.com',
        password: 'password123',
      });

    accessToken = signupResponse.body.accessToken;
    userId = signupResponse.body.user.userId;
  });

  afterAll(async () => {
    await app.close();
  });

  describe('/users/me (GET)', () => {
    it('認証済みユーザーの情報を取得できる', () => {
      return request(app.getHttpServer())
        .get('/users/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('userId', userId);
          expect(res.body).toHaveProperty('username', 'userstest');
          expect(res.body).toHaveProperty('email', 'userstest@example.com');
          expect(res.body).not.toHaveProperty('password');
          expect(res.body).toHaveProperty('createdAt');
          expect(res.body).toHaveProperty('updatedAt');
        });
    });

    it('認証トークンなしの場合、401エラーを返す', () => {
      return request(app.getHttpServer()).get('/users/me').expect(401);
    });

    it('無効なトークンの場合、401エラーを返す', () => {
      return request(app.getHttpServer())
        .get('/users/me')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);
    });
  });

  describe('/users/me (PATCH)', () => {
    it('ユーザー名を更新できる', () => {
      const updateDto = {
        username: 'updatedusername',
      };

      return request(app.getHttpServer())
        .patch('/users/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .send(updateDto)
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('username', 'updatedusername');
          expect(res.body).not.toHaveProperty('password');
        });
    });

    it('メールアドレスを更新できる', () => {
      const updateDto = {
        email: 'newemail@example.com',
      };

      return request(app.getHttpServer())
        .patch('/users/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .send(updateDto)
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('email', 'newemail@example.com');
        });
    });

    it('無効なメールアドレスの場合、400エラーを返す', () => {
      const updateDto = {
        email: 'invalid-email',
      };

      return request(app.getHttpServer())
        .patch('/users/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .send(updateDto)
        .expect(400);
    });

    it('認証トークンなしの場合、401エラーを返す', () => {
      const updateDto = {
        username: 'newusername',
      };

      return request(app.getHttpServer())
        .patch('/users/me')
        .send(updateDto)
        .expect(401);
    });
  });

  describe('/users/me (DELETE)', () => {
    it('ユーザーを削除できる', () => {
      return request(app.getHttpServer())
        .delete('/users/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('message');
        });
    });

    it('削除後はユーザー情報を取得できない', () => {
      return request(app.getHttpServer())
        .get('/users/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(404);
    });

    it('認証トークンなしの場合、401エラーを返す', () => {
      return request(app.getHttpServer()).delete('/users/me').expect(401);
    });
  });
});
