import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Participants (e2e)', () => {
  let app: INestApplication;
  let authToken: string;
  let appointmentId: number;
  let participantId: number;
  let guestSessionId: string;

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

    // テスト用予約を作成
    const appointmentResponse = await request(app.getHttpServer())
      .post('/appointments')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Test Appointment for Participants',
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentDate: '2025-12-31',
        appointmentTime: '14:00:00',
        status: 'active',
      })
      .expect(201);

    appointmentId = appointmentResponse.body.appointmentId;

    // ゲストセッションを作成
    const guestResponse = await request(app.getHttpServer())
      .post('/auth/guest/session')
      .send({
        username: 'TestGuest',
      })
      .expect(201);

    guestSessionId = guestResponse.body.sessionId;

    // ゲストユーザーを参加させる
    const joinResponse = await request(app.getHttpServer())
      .post(`/appointments/${appointmentResponse.body.inviteToken}/join`)
      .send({
        sessionId: guestSessionId,
        username: 'TestGuest',
        userLatitude: 35.6812,
        userLongitude: 139.7671,
      })
      .expect(201);

    participantId = joinResponse.body.participant.id;
  });

  afterAll(async () => {
    await app.close();
  });

  describe('GET /participants/appointment/:appointmentId', () => {
    it('should get all participants for an appointment', async () => {
      const response = await request(app.getHttpServer())
        .get(`/participants/appointment/${appointmentId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
    });
  });

  describe('PATCH /participants/:id/location', () => {
    it('should update participant location', async () => {
      const response = await request(app.getHttpServer())
        .patch(`/participants/${participantId}/location`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          userLatitude: 35.6895,
          userLongitude: 139.6917,
        })
        .expect(200);

      expect(response.body.userLatitude).toBe('35.6895');
      expect(response.body.userLongitude).toBe('139.6917');
    });

    it('should fail with invalid coordinates', async () => {
      await request(app.getHttpServer())
        .patch(`/participants/${participantId}/location`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          userLatitude: 'invalid',
          userLongitude: 'invalid',
        })
        .expect(400);
    });
  });

  describe('DELETE /participants/:id', () => {
    it('should remove a participant from appointment', async () => {
      const response = await request(app.getHttpServer())
        .delete(`/participants/${participantId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.message).toBe('Participant removed successfully');
    });

    it('should fail for non-existent participant', async () => {
      await request(app.getHttpServer())
        .delete('/participants/999999')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });
  });
});
