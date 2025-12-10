import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { LocationGateway } from './location.gateway';
import { LocationService } from './location.service';
import { WsAuthGuard } from '../auth/guards/ws-auth.guard';
import { WsRateLimitGuard } from '../auth/guards/ws-rate-limit.guard';
import { WsThrottleGuard } from '../common/guards/ws-throttle.guard';
import { SessionService } from '../auth/services/session.service';
import { RateLimitService } from '../common/services/rate-limit.service';

describe('LocationGateway', () => {
  let gateway: LocationGateway;
  let locationService: LocationService;

  const mockLocationService = {
    updateLocation: jest.fn(),
    removeLocation: jest.fn(),
    getLocationsByAppointment: jest.fn(),
  };

  const mockJwtService = {
    verify: jest.fn(),
    sign: jest.fn(),
  };

  const mockSessionService = {
    createSession: jest.fn(),
    getSession: jest.fn(),
    deleteSession: jest.fn(),
    cleanupExpiredSessions: jest.fn(),
  };

  const mockRateLimitService = {
    checkLimit: jest.fn(),
    resetLimit: jest.fn(),
  };

  const mockSocket = {
    id: 'test-socket-id',
    data: {
      user: {
        userId: 'user-1',
        email: 'test@example.com',
        isGuest: false,
      },
    },
    join: jest.fn(),
    leave: jest.fn(),
  };

  const mockServer = {
    to: jest.fn().mockReturnThis(),
    emit: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        LocationGateway,
        {
          provide: LocationService,
          useValue: mockLocationService,
        },
        WsAuthGuard,
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
        {
          provide: SessionService,
          useValue: mockSessionService,
        },
        WsRateLimitGuard,
        WsThrottleGuard,
        {
          provide: RateLimitService,
          useValue: mockRateLimitService,
        },
      ],
    }).compile();

    gateway = module.get<LocationGateway>(LocationGateway);
    locationService = module.get<LocationService>(LocationService);
    gateway.server = mockServer as any;

    jest.clearAllMocks();
  });

  it('ゲートウェイが定義されているべき', () => {
    expect(gateway).toBeDefined();
  });

  describe('handleConnection', () => {
    it('クライアント接続を処理できる', async () => {
      await gateway.handleConnection(mockSocket as any);

      expect(mockSocket).toBeDefined();
    });
  });

  describe('handleDisconnect', () => {
    it('クライアント切断を処理し、位置情報を削除する', async () => {
      await gateway.handleDisconnect(mockSocket as any);

      expect(mockLocationService.removeLocation).toHaveBeenCalledWith(mockSocket.id);
    });
  });

  describe('handleJoinAppointment', () => {
    it('予約に参加できる', async () => {
      const data = { appointmentId: 1 };

      const result = await gateway.handleJoinAppointment(mockSocket as any, data);

      expect(mockSocket.join).toHaveBeenCalledWith('appointment:1');
      expect(result.success).toBe(true);
      expect(result.message).toBe('予約に参加しました');
    });

    it('参加通知を送信する', async () => {
      const data = { appointmentId: 1 };

      await gateway.handleJoinAppointment(mockSocket as any, data);

      expect(mockServer.to).toHaveBeenCalledWith('appointment:1');
      expect(mockServer.emit).toHaveBeenCalledWith('userJoined', {
        userId: 'user-1',
        username: undefined,
        isGuest: false,
      });
    });
  });

  describe('handleLeaveAppointment', () => {
    it('予約から退出できる', async () => {
      const data = { appointmentId: 1 };

      const result = await gateway.handleLeaveAppointment(mockSocket as any, data);

      expect(mockSocket.leave).toHaveBeenCalledWith('appointment:1');
      expect(mockLocationService.removeLocation).toHaveBeenCalledWith(mockSocket.id);
      expect(result.success).toBe(true);
      expect(result.message).toBe('予約から退出しました');
    });

    it('退出通知を送信する', async () => {
      const data = { appointmentId: 1 };

      await gateway.handleLeaveAppointment(mockSocket as any, data);

      expect(mockServer.to).toHaveBeenCalledWith('appointment:1');
      expect(mockServer.emit).toHaveBeenCalledWith('userLeft', {
        userId: 'user-1',
      });
    });
  });

  describe('handleUpdateLocation', () => {
    it('位置情報を更新できる', async () => {
      const updateLocationDto = {
        appointmentId: 1,
        latitude: 35.6812,
        longitude: 139.7671,
      };

      const result = await gateway.handleUpdateLocation(
        mockSocket as any,
        updateLocationDto,
      );

      expect(mockLocationService.updateLocation).toHaveBeenCalled();
      expect(result.success).toBe(true);
    });

    it('位置情報更新を全参加者に配信する', async () => {
      const updateLocationDto = {
        appointmentId: 1,
        latitude: 35.6812,
        longitude: 139.7671,
      };

      await gateway.handleUpdateLocation(mockSocket as any, updateLocationDto);

      expect(mockServer.to).toHaveBeenCalledWith('appointment:1');
      expect(mockServer.emit).toHaveBeenCalledWith(
        'locationUpdated',
        expect.objectContaining({
          userId: 'user-1',
          latitude: 35.6812,
          longitude: 139.7671,
        }),
      );
    });
  });

  describe('handleGetAppointmentLocations', () => {
    it('予約の全参加者の位置情報を取得できる', async () => {
      const data = { appointmentId: 1 };
      const mockLocations = [
        {
          userId: 'user-1',
          username: 'ユーザー1',
          isGuest: false,
          latitude: 35.6812,
          longitude: 139.7671,
          appointmentId: 1,
          timestamp: new Date(),
        },
      ];

      mockLocationService.getLocationsByAppointment.mockResolvedValue(mockLocations);

      const result = await gateway.handleGetAppointmentLocations(
        mockSocket as any,
        data,
      );

      expect(mockLocationService.getLocationsByAppointment).toHaveBeenCalledWith(1);
      expect(result.success).toBe(true);
      expect(result.locations).toEqual(mockLocations);
    });
  });
});
