import { Test, TestingModule } from '@nestjs/testing';
import { LocationService, LocationData } from './location.service';

describe('LocationService', () => {
  let service: LocationService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [LocationService],
    }).compile();

    service = module.get<LocationService>(LocationService);
  });

  it('サービスが定義されているべき', () => {
    expect(service).toBeDefined();
  });

  describe('updateLocation', () => {
    it('位置情報を更新できる', async () => {
      const clientId = 'client-1';
      const locationData: LocationData = {
        userId: 'user-1',
        username: 'テストユーザー',
        isGuest: false,
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentId: 1,
        timestamp: new Date(),
      };

      await service.updateLocation(clientId, locationData);

      const count = service.getActiveLocationCount();
      expect(count).toBe(1);
    });

    it('同じクライアントIDの位置情報を上書きできる', async () => {
      const clientId = 'client-1';
      const locationData1: LocationData = {
        userId: 'user-1',
        username: 'テストユーザー',
        isGuest: false,
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentId: 1,
        timestamp: new Date(),
      };

      const locationData2: LocationData = {
        ...locationData1,
        latitude: 35.6900,
        longitude: 139.7800,
      };

      await service.updateLocation(clientId, locationData1);
      await service.updateLocation(clientId, locationData2);

      const count = service.getActiveLocationCount();
      expect(count).toBe(1);
    });
  });

  describe('removeLocation', () => {
    it('位置情報を削除できる', async () => {
      const clientId = 'client-1';
      const locationData: LocationData = {
        userId: 'user-1',
        username: 'テストユーザー',
        isGuest: false,
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentId: 1,
        timestamp: new Date(),
      };

      await service.updateLocation(clientId, locationData);
      await service.removeLocation(clientId);

      const count = service.getActiveLocationCount();
      expect(count).toBe(0);
    });

    it('存在しないクライアントIDの削除はエラーにならない', async () => {
      await expect(service.removeLocation('non-existent')).resolves.not.toThrow();
    });
  });

  describe('getLocationsByAppointment', () => {
    it('特定の予約の全参加者の位置情報を取得できる', async () => {
      const appointmentId = 1;

      const location1: LocationData = {
        userId: 'user-1',
        username: 'ユーザー1',
        isGuest: false,
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentId,
        timestamp: new Date(),
      };

      const location2: LocationData = {
        userId: 'user-2',
        username: 'ユーザー2',
        isGuest: false,
        latitude: 35.6900,
        longitude: 139.7800,
        appointmentId,
        timestamp: new Date(),
      };

      await service.updateLocation('client-1', location1);
      await service.updateLocation('client-2', location2);

      const locations = await service.getLocationsByAppointment(appointmentId);

      expect(locations).toHaveLength(2);
      expect(locations[0].userId).toBe('user-1');
      expect(locations[1].userId).toBe('user-2');
    });

    it('異なる予約の位置情報は含まれない', async () => {
      const location1: LocationData = {
        userId: 'user-1',
        username: 'ユーザー1',
        isGuest: false,
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentId: 1,
        timestamp: new Date(),
      };

      const location2: LocationData = {
        userId: 'user-2',
        username: 'ユーザー2',
        isGuest: false,
        latitude: 35.6900,
        longitude: 139.7800,
        appointmentId: 2,
        timestamp: new Date(),
      };

      await service.updateLocation('client-1', location1);
      await service.updateLocation('client-2', location2);

      const locations = await service.getLocationsByAppointment(1);

      expect(locations).toHaveLength(1);
      expect(locations[0].appointmentId).toBe(1);
    });

    it('参加者がいない予約は空配列を返す', async () => {
      const locations = await service.getLocationsByAppointment(999);

      expect(locations).toEqual([]);
    });
  });

  describe('cleanupOldLocations', () => {
    it('古い位置情報をクリーンアップする', async () => {
      const oldLocation: LocationData = {
        userId: 'user-1',
        username: 'ユーザー1',
        isGuest: false,
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentId: 1,
        timestamp: new Date(Date.now() - 6 * 60 * 1000), // 6分前
      };

      const newLocation: LocationData = {
        userId: 'user-2',
        username: 'ユーザー2',
        isGuest: false,
        latitude: 35.6900,
        longitude: 139.7800,
        appointmentId: 1,
        timestamp: new Date(),
      };

      await service.updateLocation('client-1', oldLocation);
      await service.updateLocation('client-2', newLocation);

      const deletedCount = service.cleanupOldLocations();

      expect(deletedCount).toBe(1);
      expect(service.getActiveLocationCount()).toBe(1);
    });
  });

  describe('getActiveLocationCount', () => {
    it('アクティブな位置情報の数を取得できる', async () => {
      const location1: LocationData = {
        userId: 'user-1',
        username: 'ユーザー1',
        isGuest: false,
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentId: 1,
        timestamp: new Date(),
      };

      const location2: LocationData = {
        userId: 'user-2',
        username: 'ユーザー2',
        isGuest: false,
        latitude: 35.6900,
        longitude: 139.7800,
        appointmentId: 1,
        timestamp: new Date(),
      };

      await service.updateLocation('client-1', location1);
      await service.updateLocation('client-2', location2);

      const count = service.getActiveLocationCount();
      expect(count).toBe(2);
    });
  });

  describe('getActiveAppointmentCount', () => {
    it('アクティブな予約の数を取得できる', async () => {
      const location1: LocationData = {
        userId: 'user-1',
        username: 'ユーザー1',
        isGuest: false,
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentId: 1,
        timestamp: new Date(),
      };

      const location2: LocationData = {
        userId: 'user-2',
        username: 'ユーザー2',
        isGuest: false,
        latitude: 35.6900,
        longitude: 139.7800,
        appointmentId: 2,
        timestamp: new Date(),
      };

      await service.updateLocation('client-1', location1);
      await service.updateLocation('client-2', location2);

      const count = service.getActiveAppointmentCount();
      expect(count).toBe(2);
    });
  });
});
