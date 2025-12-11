import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { eq, and, desc } from 'drizzle-orm';
import { v4 as uuidv4 } from 'uuid';
import { DatabaseService } from '../database/database.service';
import { appointments } from '../database/schema/appointments.schema';
import { participants } from '../database/schema/participants.schema';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';
import { JoinAppointmentDto } from './dto/join-appointment.dto';

@Injectable()
export class AppointmentsService {
  constructor(
    private readonly databaseService: DatabaseService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * 予約を作成
   */
  async create(userId: string, createAppointmentDto: CreateAppointmentDto) {
    const {
      title,
      latitude,
      longitude,
      appointmentDate,
      appointmentTime,
      status = 'active',
    } = createAppointmentDto;

    const inviteToken = uuidv4();

    const result = await this.databaseService.db
      .insert(appointments)
      .values({
        createdUserId: userId,
        title,
        latitude: latitude.toString(),
        longitude: longitude.toString(),
        appointmentDate,
        appointmentTime,
        status,
        inviteToken,
      })
      .returning();

    return this.buildAppointmentResponse(result[0]);
  }

  /**
   * ユーザーの予約一覧を取得
   */
  async findAll(userId: string) {
    const result = await this.databaseService.db
      .select()
      .from(appointments)
      .where(eq(appointments.createdUserId, userId))
      .orderBy(desc(appointments.createdAt));

    return result.map((appointment) =>
      this.buildAppointmentResponse(appointment),
    );
  }

  /**
   * 予約詳細を取得
   */
  async findOne(id: number, userId: string) {
    const result = await this.databaseService.db
      .select()
      .from(appointments)
      .where(
        and(
          eq(appointments.appointmentId, id),
          eq(appointments.createdUserId, userId),
        ),
      )
      .limit(1);

    if (!result[0]) {
      throw new NotFoundException('Appointment not found');
    }

    return this.buildAppointmentResponse(result[0]);
  }

  /**
   * 予約を更新
   */
  async update(
    id: number,
    userId: string,
    updateAppointmentDto: UpdateAppointmentDto,
  ) {
    // 存在確認と所有者チェック
    await this.findOne(id, userId);

    const updateData: any = {
      ...updateAppointmentDto,
      updatedAt: new Date(),
    };

    // latitude/longitudeがあれば文字列に変換
    if (updateAppointmentDto.latitude !== undefined) {
      updateData.latitude = updateAppointmentDto.latitude.toString();
    }
    if (updateAppointmentDto.longitude !== undefined) {
      updateData.longitude = updateAppointmentDto.longitude.toString();
    }

    const result = await this.databaseService.db
      .update(appointments)
      .set(updateData)
      .where(
        and(
          eq(appointments.appointmentId, id),
          eq(appointments.createdUserId, userId),
        ),
      )
      .returning();

    return this.buildAppointmentResponse(result[0]);
  }

  /**
   * 予約を削除（論理削除：statusをcancelledに変更）
   */
  async remove(id: number, userId: string) {
    // 存在確認と所有者チェック
    await this.findOne(id, userId);

    await this.databaseService.db
      .update(appointments)
      .set({
        status: 'cancelled',
        updatedAt: new Date(),
      })
      .where(
        and(
          eq(appointments.appointmentId, id),
          eq(appointments.createdUserId, userId),
        ),
      );

    return { message: 'Appointment cancelled successfully' };
  }

  /**
   * 招待URLを再生成
   */
  async regenerateInviteUrl(id: number, userId: string) {
    // 存在確認と所有者チェック
    await this.findOne(id, userId);

    const newInviteToken = uuidv4();

    const result = await this.databaseService.db
      .update(appointments)
      .set({
        inviteToken: newInviteToken,
        updatedAt: new Date(),
      })
      .where(
        and(
          eq(appointments.appointmentId, id),
          eq(appointments.createdUserId, userId),
        ),
      )
      .returning();

    return this.buildAppointmentResponse(result[0]);
  }

  /**
   * 招待トークンで予約を取得
   */
  async findByInviteToken(inviteToken: string) {
    const result = await this.databaseService.db
      .select()
      .from(appointments)
      .where(eq(appointments.inviteToken, inviteToken))
      .limit(1);

    if (!result[0]) {
      throw new NotFoundException('Appointment not found');
    }

    if (result[0].status === 'cancelled') {
      throw new NotFoundException('This appointment has been cancelled');
    }

    return result[0];
  }

  /**
   * イベントに参加（ゲストまたは登録ユーザー）
   */
  async joinAppointment(
    inviteToken: string,
    joinDto: JoinAppointmentDto,
    userId?: string,
  ) {
    // 予約の存在確認
    const appointment = await this.findByInviteToken(inviteToken);

    // すでに参加しているかチェック
    const existingParticipant = await this.databaseService.db
      .select()
      .from(participants)
      .where(
        and(
          eq(participants.appointmentId, appointment.appointmentId),
          userId
            ? eq(participants.userId, userId)
            : eq(participants.sessionId, joinDto.sessionId || ''),
        ),
      )
      .limit(1);

    if (existingParticipant.length > 0) {
      throw new ConflictException('Already joined this appointment');
    }

    // 参加者を追加
    const result = await this.databaseService.db
      .insert(participants)
      .values({
        appointmentId: appointment.appointmentId,
        userId: userId || null,
        sessionId: joinDto.sessionId || null,
        username: joinDto.username,
        isGuest: userId ? 'false' : 'true',
        userLatitude: joinDto.userLatitude.toString(),
        userLongitude: joinDto.userLongitude.toString(),
      })
      .returning();

    return {
      message: 'Successfully joined the appointment',
      participant: result[0],
      appointment: this.buildAppointmentResponse(appointment),
    };
  }

  /**
   * レスポンスオブジェクトを構築（招待URLを含む）
   */
  private buildAppointmentResponse(appointment: any) {
    const frontendUrl =
      this.configService.get<string>('FRONTEND_URL') || 'http://localhost:3001';

    return {
      ...appointment,
      inviteUrl: `${frontendUrl}/invite/${appointment.inviteToken}`,
    };
  }
}
