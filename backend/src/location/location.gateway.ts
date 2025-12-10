import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, UseGuards } from '@nestjs/common';
import { WsAuthGuard } from '../auth/guards/ws-auth.guard';
import { WsRateLimitGuard } from '../auth/guards/ws-rate-limit.guard';
import { WsThrottleGuard } from '../common/guards/ws-throttle.guard';
import { Throttle } from '../common/decorators/throttle.decorator';
import { LocationService } from './location.service';
import { UpdateLocationDto } from './dto/update-location.dto';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: 'location',
})
@UseGuards(WsAuthGuard)
export class LocationGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(LocationGateway.name);

  constructor(private readonly locationService: LocationService) {}

  /**
   * クライアント接続時の処理
   */
  async handleConnection(client: Socket) {
    const user = client.data.user;
    const identifier = user?.userId || user?.sessionId || 'unknown';

    this.logger.log(`クライアント接続: ${client.id} (${identifier})`);
  }

  /**
   * クライアント切断時の処理
   */
  async handleDisconnect(client: Socket) {
    const user = client.data.user;
    const identifier = user?.userId || user?.sessionId || 'unknown';

    this.logger.log(`クライアント切断: ${client.id} (${identifier})`);

    // 切断時に位置情報を削除
    await this.locationService.removeLocation(client.id);
  }

  /**
   * 予約への参加
   */
  @SubscribeMessage('joinAppointment')
  async handleJoinAppointment(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { appointmentId: number },
  ) {
    const { appointmentId } = data;
    const roomName = `appointment:${appointmentId}`;

    await client.join(roomName);

    this.logger.log(`クライアント ${client.id} が予約 ${appointmentId} に参加しました`);

    // 参加通知を送信
    this.server.to(roomName).emit('userJoined', {
      userId: client.data.user?.userId || client.data.user?.sessionId,
      username: client.data.user?.username,
      isGuest: client.data.user?.isGuest,
    });

    return { success: true, message: '予約に参加しました' };
  }

  /**
   * 予約からの退出
   */
  @SubscribeMessage('leaveAppointment')
  async handleLeaveAppointment(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { appointmentId: number },
  ) {
    const { appointmentId } = data;
    const roomName = `appointment:${appointmentId}`;

    await client.leave(roomName);
    await this.locationService.removeLocation(client.id);

    this.logger.log(`クライアント ${client.id} が予約 ${appointmentId} から退出しました`);

    // 退出通知を送信
    this.server.to(roomName).emit('userLeft', {
      userId: client.data.user?.userId || client.data.user?.sessionId,
    });

    return { success: true, message: '予約から退出しました' };
  }

  /**
   * 位置情報の更新
   * 1秒に1回まで更新可能
   */
  @SubscribeMessage('updateLocation')
  @UseGuards(WsRateLimitGuard, WsThrottleGuard)
  @Throttle({ limit: 1, ttl: 1000 })
  async handleUpdateLocation(
    @ConnectedSocket() client: Socket,
    @MessageBody() updateLocationDto: UpdateLocationDto,
  ) {
    const { appointmentId, latitude, longitude } = updateLocationDto;
    const user = client.data.user;

    // 位置情報を保存
    await this.locationService.updateLocation(client.id, {
      userId: user?.userId,
      sessionId: user?.sessionId,
      username: user?.username || user?.email,
      isGuest: user?.isGuest,
      latitude,
      longitude,
      appointmentId,
      timestamp: new Date(),
    });

    // 同じ予約の参加者全員に位置情報を配信
    const roomName = `appointment:${appointmentId}`;
    this.server.to(roomName).emit('locationUpdated', {
      userId: user?.userId || user?.sessionId,
      username: user?.username || user?.email,
      latitude,
      longitude,
      timestamp: new Date().toISOString(),
    });

    return { success: true };
  }

  /**
   * 予約の全参加者の位置情報を取得
   */
  @SubscribeMessage('getAppointmentLocations')
  async handleGetAppointmentLocations(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { appointmentId: number },
  ) {
    const { appointmentId } = data;
    const locations = await this.locationService.getLocationsByAppointment(
      appointmentId,
    );

    return { success: true, locations };
  }
}
