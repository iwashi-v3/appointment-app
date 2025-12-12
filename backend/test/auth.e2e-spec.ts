import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

interface AuthResponse {
  accessToken: string;
  user: {
    userId: string;
    username: string;
    email: string;
    createdAt: string | Date;
    updatedAt: string | Date;
  };
}

describe('Auth (e2e)', () => {
  let app: INestApplication;

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
  });

  afterAll(async () => {
    await app.close();
  });

  describe('/auth/signup (POST)', () => {
    it('正しいデータでユーザー登録ができる', () => {
      const signupDto = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
      };

      return request(app.getHttpServer())
        .post('/auth/signup')
        .send(signupDto)
        .expect(201)
        .expect((res) => {
          const body = res.body as AuthResponse;
          expect(body).toHaveProperty('accessToken');
          expect(body).toHaveProperty('user');
          expect(body.user).toHaveProperty('userId');
          expect(body.user).toHaveProperty('username', signupDto.username);
          expect(body.user).toHaveProperty('email', signupDto.email);
          expect(body.user).not.toHaveProperty('password');
        });
    });

    it('無効なメールアドレスの場合、400エラーを返す', () => {
      const signupDto = {
        username: 'testuser',
        email: 'invalid-email',
        password: 'password123',
      };

      return request(app.getHttpServer())
        .post('/auth/signup')
        .send(signupDto)
        .expect(400);
    });

    it('パスワードが短すぎる場合、400エラーを返す', () => {
      const signupDto = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'short',
      };

      return request(app.getHttpServer())
        .post('/auth/signup')
        .send(signupDto)
        .expect(400);
    });

    it('必須フィールドが不足している場合、400エラーを返す', () => {
      const signupDto = {
        email: 'test@example.com',
      };

      return request(app.getHttpServer())
        .post('/auth/signup')
        .send(signupDto)
        .expect(400);
    });
  });

  describe('/auth/signin (POST)', () => {
    // 事前にテストユーザーを作成
    beforeAll(async () => {
      await request(app.getHttpServer()).post('/auth/signup').send({
        username: 'signinuser',
        email: 'signin@example.com',
        password: 'password123',
      });
    });

    it('正しい認証情報でログインができる', () => {
      const signinDto = {
        email: 'signin@example.com',
        password: 'password123',
      };

      return request(app.getHttpServer())
        .post('/auth/signin')
        .send(signinDto)
        .expect(200)
        .expect((res) => {
          const body = res.body as AuthResponse;
          expect(body).toHaveProperty('accessToken');
          expect(body).toHaveProperty('user');
          expect(body.user).toHaveProperty('email', signinDto.email);
          expect(body.user).not.toHaveProperty('password');
        });
    });

    it('間違ったパスワードの場合、401エラーを返す', () => {
      const signinDto = {
        email: 'signin@example.com',
        password: 'wrongpassword',
      };

      return request(app.getHttpServer())
        .post('/auth/signin')
        .send(signinDto)
        .expect(401);
    });

    it('存在しないユーザーの場合、401エラーを返す', () => {
      const signinDto = {
        email: 'nonexistent@example.com',
        password: 'password123',
      };

      return request(app.getHttpServer())
        .post('/auth/signin')
        .send(signinDto)
        .expect(401);
    });
  });

  describe('/auth/signout (POST)', () => {
    let accessToken: string;

    // 事前にログインしてトークンを取得
    beforeAll(async () => {
      const signupResponse = await request(app.getHttpServer())
        .post('/auth/signup')
        .send({
          username: 'signoutuser',
          email: 'signout@example.com',
          password: 'password123',
        });

      const body = signupResponse.body as AuthResponse;
      accessToken = body.accessToken;
    });

    it('認証済みユーザーがログアウトできる', () => {
      return request(app.getHttpServer())
        .post('/auth/signout')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('message');
        });
    });

    it('認証トークンなしの場合、401エラーを返す', () => {
      return request(app.getHttpServer()).post('/auth/signout').expect(401);
    });

    it('無効なトークンの場合、401エラーを返す', () => {
      return request(app.getHttpServer())
        .post('/auth/signout')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);
    });
  });
});
