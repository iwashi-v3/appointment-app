import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from './../src/app.module';
import { DatabaseService } from '../src/database/database.service';
import { JwtService } from '@nestjs/jwt';

describe('Events (e2e)', () => {
  let app: INestApplication;
  let databaseService: DatabaseService;
  let jwtService: JwtService;
  let authToken: string;
  let testUserId: string;
  let testEventId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    databaseService = moduleFixture.get<DatabaseService>(DatabaseService);
    jwtService = moduleFixture.get<JwtService>(JwtService);
    
    await app.init();

    // Create test user and auth token
    testUserId = 'test-user-' + Date.now();
    const testUser = {
      userId: testUserId,
      username: 'testuser',
      email: 'test@example.com',
      password: 'hashedpassword',
    };

    // Insert test user directly to database for testing
    await databaseService.db.insert(require('../src/database/schema/users.schema').users).values(testUser);

    // Generate JWT token
    authToken = jwtService.sign({ userId: testUserId, username: 'testuser' });
  });

  afterAll(async () => {
    // Clean up test data
    if (testEventId) {
      await databaseService.db
        .delete(require('../src/database/schema/events.schema').events)
        .where(require('drizzle-orm').eq(require('../src/database/schema/events.schema').events.eventId, testEventId));
    }
    
    await databaseService.db
      .delete(require('../src/database/schema/users.schema').users)
      .where(require('drizzle-orm').eq(require('../src/database/schema/users.schema').users.userId, testUserId));
    
    await app.close();
  });

  describe('/events (POST)', () => {
    it('should create a new event', () => {
      const createEventDto = {
        title: 'テストイベント',
        description: 'これはテスト用のイベントです',
        location: '東京都渋谷区',
        startTime: '2024-12-11T10:00:00Z',
        endTime: '2024-12-11T12:00:00Z',
      };

      return request(app.getHttpServer())
        .post('/events')
        .set('Authorization', `Bearer ${authToken}`)
        .send(createEventDto)
        .expect(201)
        .expect((res) => {
          expect(res.body.title).toBe(createEventDto.title);
          expect(res.body.description).toBe(createEventDto.description);
          expect(res.body.location).toBe(createEventDto.location);
          expect(res.body.creatorId).toBe(testUserId);
          expect(res.body.isActive).toBe(false);
          expect(res.body.eventId).toBeDefined();
          testEventId = res.body.eventId; // Save for cleanup and further tests
        });
    });

    it('should fail to create event without authentication', () => {
      const createEventDto = {
        title: 'テストイベント',
        startTime: '2024-12-11T10:00:00Z',
        endTime: '2024-12-11T12:00:00Z',
      };

      return request(app.getHttpServer())
        .post('/events')
        .send(createEventDto)
        .expect(401);
    });
  });

  describe('/events (GET)', () => {
    it('should get all events', () => {
      return request(app.getHttpServer())
        .get('/events')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect((res) => {
          expect(Array.isArray(res.body)).toBe(true);
          expect(res.body.length).toBeGreaterThanOrEqual(1);
        });
    });
  });

  describe('/events/:eventId (GET)', () => {
    it('should get event by id', () => {
      return request(app.getHttpServer())
        .get(`/events/${testEventId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect((res) => {
          expect(res.body.eventId).toBe(testEventId);
          expect(res.body.title).toBe('テストイベント');
        });
    });

    it('should return 404 for non-existent event', () => {
      return request(app.getHttpServer())
        .get('/events/non-existent-id')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });
  });

  describe('/events/:eventId (PUT)', () => {
    it('should update event location and trigger notification', () => {
      const updateDto = {
        location: '大阪府大阪市',
        description: '更新されたイベント説明',
      };

      return request(app.getHttpServer())
        .put(`/events/${testEventId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateDto)
        .expect(200)
        .expect((res) => {
          expect(res.body.location).toBe(updateDto.location);
          expect(res.body.description).toBe(updateDto.description);
        });
    });
  });

  describe('/events/:eventId/start (POST)', () => {
    it('should start event and change status to active', () => {
      return request(app.getHttpServer())
        .post(`/events/${testEventId}/start`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(201)
        .expect((res) => {
          expect(res.body.isActive).toBe(true);
        });
    });
  });

  describe('/events/:eventId/join (POST)', () => {
    it('should join event successfully', () => {
      return request(app.getHttpServer())
        .post(`/events/${testEventId}/join`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(201)
        .expect((res) => {
          expect(res.body.message).toBe('Successfully joined the event');
        });
    });
  });

  describe('/events/:eventId/participants (GET)', () => {
    it('should get event participants', () => {
      return request(app.getHttpServer())
        .get(`/events/${testEventId}/participants`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect((res) => {
          expect(Array.isArray(res.body)).toBe(true);
          expect(res.body.length).toBeGreaterThanOrEqual(1);
          expect(res.body[0].userId).toBe(testUserId);
          expect(res.body[0].isCurrentlyInRoom).toBe(true);
        });
    });
  });

  describe('/events/:eventId/notifications (GET)', () => {
    it('should get event notifications', () => {
      return request(app.getHttpServer())
        .get(`/events/${testEventId}/notifications`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect((res) => {
          expect(Array.isArray(res.body)).toBe(true);
          // Should have notifications for location change, event start, and participant join
          expect(res.body.length).toBeGreaterThanOrEqual(3);
          
          const notificationTypes = res.body.map(n => n.type);
          expect(notificationTypes).toContain('location_change');
          expect(notificationTypes).toContain('event_start');
          expect(notificationTypes).toContain('participant_join');
        });
    });
  });

  describe('/events/:eventId/leave (POST)', () => {
    it('should leave event successfully', () => {
      return request(app.getHttpServer())
        .post(`/events/${testEventId}/leave`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(201)
        .expect((res) => {
          expect(res.body.message).toBe('Successfully left the event');
        });
    });
  });

  describe('/events/:eventId/end (POST)', () => {
    it('should end event and change status to inactive', () => {
      return request(app.getHttpServer())
        .post(`/events/${testEventId}/end`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(201)
        .expect((res) => {
          expect(res.body.isActive).toBe(false);
        });
    });
  });

  describe('/events/:eventId (DELETE)', () => {
    it('should soft delete event', () => {
      return request(app.getHttpServer())
        .delete(`/events/${testEventId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);
    });

    it('should not find deleted event', () => {
      return request(app.getHttpServer())
        .get(`/events/${testEventId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });
  });
});
