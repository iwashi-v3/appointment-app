import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Appointments (e2e)', () => {
  let app: INestApplication;
  let authToken: string;
  let userId: string;
  let appointmentId: number;
  let inviteToken: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    await app.init();

    // テスト用ユーザーを作成
    const signupResponse = await request(app.getHttpServer())
      .post('/auth/signup')
      .send({
        username: `testuser_${Date.now()}`,
        email: `test_${Date.now()}@example.com`,
        password: 'Test1234!',
      })
      .expect(201);

    authToken = signupResponse.body.accessToken;
    userId = signupResponse.body.user.userId;
  });

  afterAll(async () => {
    await app.close();
  });

  describe('POST /appointments', () => {
    it('should create a new appointment', async () => {
      const response = await request(app.getHttpServer())
        .post('/appointments')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Test Appointment',
          latitude: 35.6812,
          longitude: 139.7671,
          appointmentDate: '2025-12-31',
          appointmentTime: '14:00:00',
          status: 'active',
        })
        .expect(201);

      expect(response.body).toHaveProperty('appointmentId');
      expect(response.body.title).toBe('Test Appointment');
      expect(response.body.inviteUrl).toBeDefined();

      appointmentId = response.body.appointmentId;
      inviteToken = response.body.inviteToken;
    });

    it('should fail without authentication', async () => {
      await request(app.getHttpServer())
        .post('/appointments')
        .send({
          title: 'Test Appointment',
          latitude: 35.6812,
          longitude: 139.7671,
          appointmentDate: '2025-12-31',
          appointmentTime: '14:00:00',
        })
        .expect(401);
    });

    it('should fail with invalid data', async () => {
      await request(app.getHttpServer())
        .post('/appointments')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: '',
          latitude: 'invalid',
          longitude: 'invalid',
        })
        .expect(400);
    });
  });

  describe('GET /appointments', () => {
    it('should get all appointments for authenticated user', async () => {
      const response = await request(app.getHttpServer())
        .get('/appointments')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
    });
  });

  describe('GET /appointments/:id', () => {
    it('should get a specific appointment', async () => {
      const response = await request(app.getHttpServer())
        .get(`/appointments/${appointmentId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.appointmentId).toBe(appointmentId);
      expect(response.body.title).toBe('Test Appointment');
    });

    it('should fail for non-existent appointment', async () => {
      await request(app.getHttpServer())
        .get('/appointments/999999')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });
  });

  describe('PATCH /appointments/:id', () => {
    it('should update an appointment', async () => {
      const response = await request(app.getHttpServer())
        .patch(`/appointments/${appointmentId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Updated Appointment',
        })
        .expect(200);

      expect(response.body.title).toBe('Updated Appointment');
    });
  });

  describe('POST /appointments/:inviteToken/join', () => {
    it('should allow guest to join appointment', async () => {
      // ゲストセッションを作成
      const guestSessionResponse = await request(app.getHttpServer())
        .post('/auth/guest/session')
        .send({
          username: 'GuestUser',
        })
        .expect(201);

      const sessionId = guestSessionResponse.body.sessionId;

      const response = await request(app.getHttpServer())
        .post(`/appointments/${inviteToken}/join`)
        .send({
          sessionId,
          username: 'GuestUser',
          userLatitude: 35.6812,
          userLongitude: 139.7671,
        })
        .expect(201);

      expect(response.body.message).toBe('Successfully joined the appointment');
      expect(response.body.participant).toBeDefined();
    });
  });

  describe('DELETE /appointments/:id', () => {
    it('should delete (cancel) an appointment', async () => {
      const response = await request(app.getHttpServer())
        .delete(`/appointments/${appointmentId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.message).toBe('Appointment cancelled successfully');
    });
  });
});
