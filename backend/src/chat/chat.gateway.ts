import {
  WebSocketGateway,
  SubscribeMessage,
  MessageBody,
  WebSocketServer,
  ConnectedSocket,
  OnGatewayInit,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, ValidationPipe } from '@nestjs/common';
import { ChatService } from './chat.service';
import { CreateMessageDto } from './dto/create-message.dto';
import { TypingStatusDto } from './dto/typing-status.dto';
import { SocketAuthMiddleware } from './middleware/socket-auth.middleware';

interface AuthenticatedSocket extends Socket {
  user?: {
    userId: string;
    username: string;
    email: string;
  };
}

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: '/chat',
})
export class ChatGateway implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private logger: Logger = new Logger('ChatGateway');

  constructor(
    private readonly chatService: ChatService,
    private readonly socketAuthMiddleware: SocketAuthMiddleware
  ) {}

  afterInit(server: Server) {
    this.logger.log('Chat WebSocket Gateway initialized');
    // 認証ミドルウェアを設定
    server.use((socket, next) => this.socketAuthMiddleware.use(socket, next));
  }

  handleConnection(client: AuthenticatedSocket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: AuthenticatedSocket) {
    this.logger.log(`Client disconnected: ${client.id}`);
    
    // クライアントが切断した際、入力中状態をクリア
    if (client.user) {
      // 全てのルームから退出し、入力中状態をリセット
      const rooms = Array.from(client.rooms);
      rooms.forEach(room => {
        if (room !== client.id) {
          this.handleTypingStop(client, { eventId: room, isTyping: false });
        }
      });
    }
  }

  @SubscribeMessage('joinRoom')
  async handleJoinRoom(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() payload: { eventId: string }
  ) {
    try {
      await client.join(payload.eventId);
      this.logger.log(`Client ${client.id} joined room ${payload.eventId}`);
      
      // メッセージ履歴を送信
      const history = await this.chatService.getMessageHistory(payload.eventId);
      client.emit('messageHistory', history);
      
      // 現在の入力中ユーザーを送信
      const typingUsers = await this.chatService.getTypingUsers(payload.eventId);
      client.emit('typingUsers', typingUsers);
      
    } catch (error) {
      this.logger.error(`Error joining room: ${error.message}`);
      client.emit('error', { message: 'Failed to join room' });
    }
  }

  @SubscribeMessage('leaveRoom')
  async handleLeaveRoom(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() payload: { eventId: string }
  ) {
    try {
      await client.leave(payload.eventId);
      this.logger.log(`Client ${client.id} left room ${payload.eventId}`);
      
      // 入力中状態をクリア
      if (client.user) {
        await this.chatService.updateTypingStatus(
          { eventId: payload.eventId, isTyping: false },
          client.user.userId
        );
        
        // 他のクライアントに入力停止を通知
        client.to(payload.eventId).emit('userStoppedTyping', {
          userId: client.user.userId,
          username: client.user.username,
        });
      }
    } catch (error) {
      this.logger.error(`Error leaving room: ${error.message}`);
    }
  }

  @SubscribeMessage('sendMessage')
  async handleMessage(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody(new ValidationPipe()) createMessageDto: CreateMessageDto
  ) {
    try {
      if (!client.user) {
        client.emit('error', { message: 'Authentication required' });
        return;
      }

      const message = await this.chatService.createMessage(createMessageDto, client.user.userId);
      
      // ルーム内の全クライアントにメッセージを配信
      this.server.to(createMessageDto.eventId).emit('newMessage', message);
      
      this.logger.log(`Message sent to room ${createMessageDto.eventId}: ${message.content}`);
    } catch (error) {
      this.logger.error(`Error sending message: ${error.message}`);
      client.emit('error', { message: 'Failed to send message' });
    }
  }

  @SubscribeMessage('startTyping')
  async handleTypingStart(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() payload: TypingStatusDto
  ) {
    try {
      if (!client.user) {
        return;
      }

      await this.chatService.updateTypingStatus(
        { ...payload, isTyping: true },
        client.user.userId
      );

      // 他のクライアントに入力開始を通知（送信者以外）
      client.to(payload.eventId).emit('userStartedTyping', {
        userId: client.user.userId,
        username: client.user.username,
      });

    } catch (error) {
      this.logger.error(`Error updating typing status: ${error.message}`);
    }
  }

  @SubscribeMessage('stopTyping')
  async handleTypingStop(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() payload: TypingStatusDto
  ) {
    try {
      if (!client.user) {
        return;
      }

      await this.chatService.updateTypingStatus(
        { ...payload, isTyping: false },
        client.user.userId
      );

      // 他のクライアントに入力停止を通知（送信者以外）
      client.to(payload.eventId).emit('userStoppedTyping', {
        userId: client.user.userId,
        username: client.user.username,
      });

    } catch (error) {
      this.logger.error(`Error updating typing status: ${error.message}`);
    }
  }

  @SubscribeMessage('getMessageHistory')
  async handleGetMessageHistory(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() payload: { eventId: string; limit?: number; offset?: number }
  ) {
    try {
      const history = await this.chatService.getMessageHistory(
        payload.eventId,
        payload.limit || 50,
        payload.offset || 0
      );
      
      client.emit('messageHistory', history);
    } catch (error) {
      this.logger.error(`Error getting message history: ${error.message}`);
      client.emit('error', { message: 'Failed to get message history' });
    }
  }
}
