// フロントエンド（Flutter/Web）でのWebSocket接続例
// このコードはフロントエンド実装時の参考用です

import { io, Socket } from 'socket.io-client';

interface EventNotification {
  eventId: string;
  type: 'event_start' | 'event_end' | 'location_change' | 'participant_join' | 'participant_leave';
  message: string;
  data?: any;
}

class EventWebSocketService {
  private socket: Socket | null = null;
  private serverUrl = 'http://localhost:4000';

  connect(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.socket = io(this.serverUrl);

      this.socket.on('connect', () => {
        console.log('✅ WebSocket接続成功');
        resolve();
      });

      this.socket.on('connect_error', (error) => {
        console.error('❌ WebSocket接続エラー:', error);
        reject(error);
      });

      this.socket.on('disconnect', () => {
        console.log('🔌 WebSocket切断');
      });

      // 通知受信ハンドラー
      this.socket.on('event_notification', (notification: EventNotification) => {
        this.handleNotification(notification);
      });
    });
  }

  // イベントルームに参加
  joinEvent(eventId: string, userId: string): Promise<any> {
    return new Promise((resolve, reject) => {
      if (!this.socket) {
        reject(new Error('WebSocket未接続'));
        return;
      }

      this.socket.emit('join_event', { eventId, userId }, (response: any) => {
        if (response.success) {
          console.log(`📍 イベント${eventId}に参加しました`);
          resolve(response);
        } else {
          reject(new Error(response.message));
        }
      });
    });
  }

  // イベントルームから離脱
  leaveEvent(eventId: string, userId: string): Promise<any> {
    return new Promise((resolve, reject) => {
      if (!this.socket) {
        reject(new Error('WebSocket未接続'));
        return;
      }

      this.socket.emit('leave_event', { eventId, userId }, (response: any) => {
        if (response.success) {
          console.log(`🚪 イベント${eventId}から離脱しました`);
          resolve(response);
        } else {
          reject(new Error(response.message));
        }
      });
    });
  }

  // 通知処理
  private handleNotification(notification: EventNotification): void {
    console.log('🔔 通知受信:', notification);

    switch (notification.type) {
      case 'event_start':
        this.showStartNotification(notification);
        break;
      
      case 'event_end':
        this.showEndNotification(notification);
        break;
      
      case 'location_change':
        this.showLocationChangeNotification(notification);
        break;
      
      case 'participant_join':
        this.showParticipantJoinNotification(notification);
        break;
      
      case 'participant_leave':
        this.showParticipantLeaveNotification(notification);
        break;
    }
  }

  private showStartNotification(notification: EventNotification): void {
    // イベント開始通知の表示
    alert(`🚀 ${notification.message}`);
    // 実際の実装では、アプリ内通知やバナー表示など
  }

  private showEndNotification(notification: EventNotification): void {
    // イベント終了通知の表示
    alert(`⏹️ ${notification.message}`);
  }

  private showLocationChangeNotification(notification: EventNotification): void {
    // 集合場所変更通知の表示
    const newLocation = notification.data?.newLocation;
    alert(`📍 ${notification.message}`);
  }

  private showParticipantJoinNotification(notification: EventNotification): void {
    // 参加者入室通知の表示
    console.log(`👋 ${notification.message}`);
    // 参加者リストの更新など
  }

  private showParticipantLeaveNotification(notification: EventNotification): void {
    // 参加者退室通知の表示
    console.log(`👋 ${notification.message}`);
    // 参加者リストの更新など
  }

  disconnect(): void {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
  }
}

// 使用例
export const eventWebSocketService = new EventWebSocketService();

// アプリケーション初期化時
async function initializeApp() {
  try {
    await eventWebSocketService.connect();
    
    // イベントページに遷移時
    await eventWebSocketService.joinEvent('event-123', 'user-456');
    
  } catch (error) {
    console.error('初期化エラー:', error);
  }
}

// ページ離脱時
function cleanup() {
  eventWebSocketService.disconnect();
}
