import { io, Socket } from 'socket.io-client';

export class ChatClient {
  private socket: Socket | null = null;
  private eventId: string | null = null;

  constructor(private serverUrl: string, private authToken: string) {}

  connect(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.socket = io(`${this.serverUrl}/chat`, {
        auth: { token: this.authToken },
      });

      this.socket.on('connect', () => {
        console.log('Connected to chat server');
        resolve();
      });

      this.socket.on('connect_error', (error) => {
        console.error('Connection failed:', error);
        reject(error);
      });

      this.setupEventListeners();
    });
  }

  private setupEventListeners() {
    if (!this.socket) return;

    // メッセージ受信
    this.socket.on('newMessage', (message) => {
      console.log('New message:', message);
      this.onNewMessage?.(message);
    });

    // メッセージ履歴受信
    this.socket.on('messageHistory', (history) => {
      console.log('Message history:', history);
      this.onMessageHistory?.(history);
    });

    // ユーザーが入力開始
    this.socket.on('userStartedTyping', (data) => {
      console.log('User started typing:', data);
      this.onUserStartedTyping?.(data);
    });

    // ユーザーが入力停止
    this.socket.on('userStoppedTyping', (data) => {
      console.log('User stopped typing:', data);
      this.onUserStoppedTyping?.(data);
    });

    // エラー処理
    this.socket.on('error', (error) => {
      console.error('Socket error:', error);
      this.onError?.(error);
    });
  }

  joinRoom(eventId: string) {
    this.eventId = eventId;
    this.socket?.emit('joinRoom', { eventId });
  }

  leaveRoom() {
    if (this.eventId) {
      this.socket?.emit('leaveRoom', { eventId: this.eventId });
      this.eventId = null;
    }
  }

  sendMessage(content: string, messageType: 'text' | 'system' | 'image' = 'text') {
    if (!this.eventId) {
      throw new Error('Must join a room before sending messages');
    }

    this.socket?.emit('sendMessage', {
      eventId: this.eventId,
      content,
      messageType,
    });
  }

  startTyping() {
    if (!this.eventId) return;
    this.socket?.emit('startTyping', {
      eventId: this.eventId,
      isTyping: true,
    });
  }

  stopTyping() {
    if (!this.eventId) return;
    this.socket?.emit('stopTyping', {
      eventId: this.eventId,
      isTyping: false,
    });
  }

  getMessageHistory(limit = 50, offset = 0) {
    if (!this.eventId) return;
    this.socket?.emit('getMessageHistory', {
      eventId: this.eventId,
      limit,
      offset,
    });
  }

  disconnect() {
    this.leaveRoom();
    this.socket?.disconnect();
  }

  // イベントハンドラー（外部から設定可能）
  onNewMessage?: (message: any) => void;
  onMessageHistory?: (history: any[]) => void;
  onUserStartedTyping?: (data: { userId: string; username: string }) => void;
  onUserStoppedTyping?: (data: { userId: string; username: string }) => void;
  onError?: (error: any) => void;
}

// 使用例
export function createChatExample() {
  const chatClient = new ChatClient('http://localhost:3000', 'your-jwt-token');

  // イベントハンドラーを設定
  chatClient.onNewMessage = (message) => {
    console.log(`${message.senderUsername}: ${message.content}`);
    // UIにメッセージを表示する処理
  };

  chatClient.onMessageHistory = (history) => {
    console.log(`Loading ${history.length} messages`);
    // 履歴をUIに表示する処理
  };

  chatClient.onUserStartedTyping = (data) => {
    console.log(`${data.username} is typing...`);
    // 入力中表示をUIに追加
  };

  chatClient.onUserStoppedTyping = (data) => {
    console.log(`${data.username} stopped typing`);
    // 入力中表示をUIから削除
  };

  // チャットに接続
  chatClient.connect()
    .then(() => {
      // イベントルームに参加
      chatClient.joinRoom('event-123');
      
      // メッセージを送信
      chatClient.sendMessage('Hello everyone!');
      
      // 入力中状態を送信
      chatClient.startTyping();
      setTimeout(() => {
        chatClient.stopTyping();
        chatClient.sendMessage('How is everyone doing?');
      }, 2000);
    })
    .catch(console.error);

  return chatClient;
}
