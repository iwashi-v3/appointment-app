import { io, Socket } from 'socket.io-client';

interface NotificationPayload {
  eventId: string;
  type: 'event_start' | 'event_end' | 'location_change' | 'participant_join' | 'participant_leave';
  message: string;
  data?: any;
}

describe('Events WebSocket (e2e)', () => {
  let socket: Socket;
  const serverUrl = 'http://localhost:4000';
  
  beforeAll((done) => {
    socket = io(serverUrl);
    socket.on('connect', done);
  });

  afterAll(() => {
    if (socket.connected) {
      socket.disconnect();
    }
  });

  describe('Event Room Management', () => {
    const testEventId = 'test-event-websocket';
    const testUserId = 'test-user-websocket';

    it('should join event room successfully', (done) => {
      socket.emit('join_event', { eventId: testEventId, userId: testUserId }, (response: any) => {
        expect(response.success).toBe(true);
        expect(response.message).toBe('Joined event successfully');
        done();
      });
    });

    it('should receive participant join notification', (done) => {
      const anotherUserId = 'another-user';
      
      socket.on('event_notification', (notification: NotificationPayload) => {
        if (notification.type === 'participant_join' && notification.data?.userId === anotherUserId) {
          expect(notification.eventId).toBe(testEventId);
          expect(notification.message).toBe('参加者が入室しました');
          done();
        }
      });

      // Simulate another user joining
      const anotherSocket = io(serverUrl);
      anotherSocket.on('connect', () => {
        anotherSocket.emit('join_event', { eventId: testEventId, userId: anotherUserId });
      });
    });

    it('should receive event start notification', (done) => {
      socket.on('event_notification', (notification: NotificationPayload) => {
        if (notification.type === 'event_start') {
          expect(notification.eventId).toBe(testEventId);
          expect(notification.message).toContain('開始されました');
          done();
        }
      });

      // This would be triggered by the REST API call to start the event
      // For testing purposes, we simulate it directly via the gateway
      setTimeout(() => {
        // Simulate event start notification
        socket.emit('test_event_start', { eventId: testEventId, title: 'テストイベント' });
      }, 100);
    });

    it('should receive location change notification', (done) => {
      socket.on('event_notification', (notification: NotificationPayload) => {
        if (notification.type === 'location_change') {
          expect(notification.eventId).toBe(testEventId);
          expect(notification.message).toContain('集合場所が');
          expect(notification.data?.newLocation).toBeDefined();
          done();
        }
      });

      // This would be triggered by the REST API call to update event location
      setTimeout(() => {
        socket.emit('test_location_change', { 
          eventId: testEventId, 
          newLocation: '新しい場所',
          eventTitle: 'テストイベント'
        });
      }, 100);
    });

    it('should leave event room successfully', (done) => {
      socket.emit('leave_event', { eventId: testEventId, userId: testUserId }, (response: any) => {
        expect(response.success).toBe(true);
        expect(response.message).toBe('Left event successfully');
        done();
      });
    });
  });

  describe('Connection Management', () => {
    it('should connect to WebSocket server', () => {
      expect(socket.connected).toBe(true);
    });

    it('should handle disconnect gracefully', (done) => {
      socket.on('disconnect', () => {
        done();
      });
      
      socket.disconnect();
    });
  });
});
