import {
  WebSocketGateway,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Injectable } from '@nestjs/common';

export interface NotificationPayload {
  eventId: string;
  type: 'event_start' | 'event_end' | 'location_change' | 'participant_join' | 'participant_leave';
  message: string;
  data?: any;
}

@Injectable()
@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class EventsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private eventRooms = new Map<string, Set<string>>();
  private userSockets = new Map<string, string>();

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
    
    // Remove user from all event rooms and notify participants
    for (const [eventId, participants] of this.eventRooms.entries()) {
      if (participants.has(client.id)) {
        participants.delete(client.id);
        this.notifyParticipantLeft(eventId, client.id);
      }
    }

    // Remove from user sockets map
    for (const [userId, socketId] of this.userSockets.entries()) {
      if (socketId === client.id) {
        this.userSockets.delete(userId);
        break;
      }
    }
  }

  @SubscribeMessage('join_event')
  handleJoinEvent(
    @MessageBody() data: { eventId: string; userId: string },
    @ConnectedSocket() client: Socket,
  ) {
    const { eventId, userId } = data;
    
    // Add to event room
    client.join(`event_${eventId}`);
    
    // Track in our internal map
    if (!this.eventRooms.has(eventId)) {
      this.eventRooms.set(eventId, new Set());
    }
    this.eventRooms.get(eventId)!.add(client.id);
    this.userSockets.set(userId, client.id);

    // Notify other participants
    this.notifyParticipantJoined(eventId, userId);

    return { success: true, message: 'Joined event successfully' };
  }

  @SubscribeMessage('leave_event')
  handleLeaveEvent(
    @MessageBody() data: { eventId: string; userId: string },
    @ConnectedSocket() client: Socket,
  ) {
    const { eventId, userId } = data;
    
    // Leave event room
    client.leave(`event_${eventId}`);
    
    // Remove from our internal map
    if (this.eventRooms.has(eventId)) {
      this.eventRooms.get(eventId)!.delete(client.id);
    }
    this.userSockets.delete(userId);

    // Notify other participants
    this.notifyParticipantLeft(eventId, userId);

    return { success: true, message: 'Left event successfully' };
  }

  // Notification methods
  notifyEventStart(eventId: string, eventTitle: string) {
    const payload: NotificationPayload = {
      eventId,
      type: 'event_start',
      message: `イベント「${eventTitle}」が開始されました`,
    };
    
    this.server.to(`event_${eventId}`).emit('event_notification', payload);
  }

  notifyEventEnd(eventId: string, eventTitle: string) {
    const payload: NotificationPayload = {
      eventId,
      type: 'event_end',
      message: `イベント「${eventTitle}」が終了しました`,
    };
    
    this.server.to(`event_${eventId}`).emit('event_notification', payload);
  }

  notifyLocationChange(eventId: string, newLocation: string, eventTitle: string) {
    const payload: NotificationPayload = {
      eventId,
      type: 'location_change',
      message: `イベント「${eventTitle}」の集合場所が「${newLocation}」に変更されました`,
      data: { newLocation },
    };
    
    this.server.to(`event_${eventId}`).emit('event_notification', payload);
  }

  notifyParticipantJoined(eventId: string, userId: string) {
    const payload: NotificationPayload = {
      eventId,
      type: 'participant_join',
      message: `参加者が入室しました`,
      data: { userId },
    };
    
    this.server.to(`event_${eventId}`).emit('event_notification', payload);
  }

  notifyParticipantLeft(eventId: string, userId: string) {
    const payload: NotificationPayload = {
      eventId,
      type: 'participant_leave',
      message: `参加者が退室しました`,
      data: { userId },
    };
    
    this.server.to(`event_${eventId}`).emit('event_notification', payload);
  }

  // Get participants count for an event
  getEventParticipants(eventId: string): number {
    return this.eventRooms.get(eventId)?.size || 0;
  }
}
