import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { eq, and } from 'drizzle-orm';
import { DatabaseService } from '../database/database.service';
import { participants } from '../database/schema/participants.schema';
import { appointments } from '../database/schema/appointments.schema';

@Injectable()
export class ParticipantsService {
  constructor(private readonly databaseService: DatabaseService) {}

  /**
   * 予約の参加者一覧を取得
   */
  async findByAppointment(appointmentId: number, userId: string) {
    // まず予約が存在し、ユーザーが所有者であることを確認
    const appointment = await this.databaseService.db
      .select()
      .from(appointments)
      .where(
        and(
          eq(appointments.appointmentId, appointmentId),
          eq(appointments.createdUserId, userId),
        ),
      )
      .limit(1);

    if (!appointment[0]) {
      throw new NotFoundException(
        'Appointment not found or you do not have permission',
      );
    }

    // 参加者一覧を取得
    const result = await this.databaseService.db
      .select()
      .from(participants)
      .where(eq(participants.appointmentId, appointmentId));

    return result;
  }

  /**
   * 参加者の位置情報を更新
   */
  async updateLocation(
    participantId: number,
    latitude: number,
    longitude: number,
    userId?: string,
    sessionId?: string,
  ) {
    // 参加者の存在確認と権限チェック
    const participant = await this.databaseService.db
      .select()
      .from(participants)
      .where(eq(participants.id, participantId))
      .limit(1);

    if (!participant[0]) {
      throw new NotFoundException('Participant not found');
    }

    // 権限チェック：自分自身の位置情報のみ更新可能
    const isOwner = userId
      ? participant[0].userId === userId
      : participant[0].sessionId === sessionId;

    if (!isOwner) {
      throw new ForbiddenException(
        'You can only update your own location',
      );
    }

    // 位置情報を更新
    const result = await this.databaseService.db
      .update(participants)
      .set({
        userLatitude: latitude.toString(),
        userLongitude: longitude.toString(),
      })
      .where(eq(participants.id, participantId))
      .returning();

    return result[0];
  }

  /**
   * 参加者を削除
   */
  async remove(participantId: number, requestUserId: string) {
    // 参加者の存在確認
    const participant = await this.databaseService.db
      .select({
        id: participants.id,
        appointmentId: participants.appointmentId,
        userId: participants.userId,
        createdUserId: appointments.createdUserId,
      })
      .from(participants)
      .innerJoin(
        appointments,
        eq(participants.appointmentId, appointments.appointmentId),
      )
      .where(eq(participants.id, participantId))
      .limit(1);

    if (!participant[0]) {
      throw new NotFoundException('Participant not found');
    }

    // 権限チェック：予約の作成者または参加者本人のみ削除可能
    const isAppointmentOwner = participant[0].createdUserId === requestUserId;
    const isParticipantOwner = participant[0].userId === requestUserId;

    if (!isAppointmentOwner && !isParticipantOwner) {
      throw new ForbiddenException(
        'You do not have permission to remove this participant',
      );
    }

    // 参加者を削除
    await this.databaseService.db
      .delete(participants)
      .where(eq(participants.id, participantId));

    return { message: 'Participant removed successfully' };
  }
}
