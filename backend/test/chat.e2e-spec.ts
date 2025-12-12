import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { Socket, io } from 'socket.io-client';
import { AppModule } from '../src/app.module';
import { JwtService } from '@nestjs/jwt';

describe('ChatGateway (e2e)', () => {
  let app: INestApplication;
  let clientSocket: Socket;
  let jwtService: JwtService;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    jwtService = moduleFixture.get<JwtService>(JwtService);
    
    await app.listen(3000);
  });

  afterAll(async () => {
    await app.close();
  });

  beforeEach((done) => {
    // テスト用のJWTトークンを生成
    const token = jwtService.sign({
      userId: 'test-user-id',
      username: 'testuser',
      email: 'test@example.com',
    });

    clientSocket = io('http://localhost:3000/chat', {
      auth: { token },
    });

    clientSocket.on('connect', () => {
      done();
    });
  });

  afterEach(() => {
    clientSocket.close();
  });

  it('should connect to chat namespace', (done) => {
    expect(clientSocket.connected).toBe(true);
    done();
  });

  it('should join a room and receive message history', (done) => {
    const eventId = 'test-event-id';

    clientSocket.on('messageHistory', (history) => {
      expect(Array.isArray(history)).toBe(true);
      done();
    });

    clientSocket.emit('joinRoom', { eventId });
  });

  it('should send and receive messages', (done) => {
    const eventId = 'test-event-id';
    const message = {
      eventId,
      content: 'Hello, world!',
      messageType: 'text',
    };

    clientSocket.on('newMessage', (receivedMessage) => {
      expect(receivedMessage.content).toBe(message.content);
      expect(receivedMessage.eventId).toBe(message.eventId);
      done();
    });

    // ルームに参加してからメッセージを送信
    clientSocket.emit('joinRoom', { eventId });
    setTimeout(() => {
      clientSocket.emit('sendMessage', message);
    }, 100);
  });

  it('should handle typing status', (done) => {
    const eventId = 'test-event-id';

    clientSocket.on('userStartedTyping', (data) => {
      expect(data.userId).toBe('test-user-id');
      expect(data.username).toBe('testuser');
      done();
    });

    clientSocket.emit('joinRoom', { eventId });
    setTimeout(() => {
      clientSocket.emit('startTyping', { eventId, isTyping: true });
    }, 100);
  });
});
