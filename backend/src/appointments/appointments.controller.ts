import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
  ParseIntPipe,
} from '@nestjs/common';
import { AppointmentsService } from './appointments.service';
import { ParticipantsService } from '../participants/participants.service';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';
import { JoinAppointmentDto } from './dto/join-appointment.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { OptionalJwtAuthGuard } from '../auth/guards/optional-jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CurrentUserData } from '../auth/strategies/jwt.strategy';

@Controller('appointments')
@UseGuards(JwtAuthGuard)
export class AppointmentsController {
  constructor(
    private readonly appointmentsService: AppointmentsService,
    private readonly participantsService: ParticipantsService,
  ) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(
    @CurrentUser() user: CurrentUserData,
    @Body() createAppointmentDto: CreateAppointmentDto,
  ) {
    return this.appointmentsService.create(user.userId, createAppointmentDto);
  }

  @Get()
  findAll(@CurrentUser() user: CurrentUserData) {
    return this.appointmentsService.findAll(user.userId);
  }

  @Get(':id')
  findOne(
    @CurrentUser() user: CurrentUserData,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.appointmentsService.findOne(id, user.userId);
  }

  @Put(':id')
  update(
    @CurrentUser() user: CurrentUserData,
    @Param('id', ParseIntPipe) id: number,
    @Body() updateAppointmentDto: UpdateAppointmentDto,
  ) {
    return this.appointmentsService.update(id, user.userId, updateAppointmentDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(
    @CurrentUser() user: CurrentUserData,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.appointmentsService.remove(id, user.userId);
  }

  @Post(':id/regenerate-url')
  regenerateUrl(
    @CurrentUser() user: CurrentUserData,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.appointmentsService.regenerateInviteUrl(id, user.userId);
  }

  /**
   * 招待トークンでイベントに参加（ゲストまたは登録ユーザー）
   * 認証はオプショナル
   */
  @Post('invite/:token/join')
  @UseGuards(OptionalJwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  joinByToken(
    @Param('token') token: string,
    @Body() joinDto: JoinAppointmentDto,
    @CurrentUser() user?: CurrentUserData,
  ) {
    return this.appointmentsService.joinAppointment(
      token,
      joinDto,
      user?.userId,
    );
  }

  /**
   * 予約の参加者一覧を取得
   */
  @Get(':id/participants')
  getParticipants(
    @CurrentUser() user: CurrentUserData,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.participantsService.findByAppointment(id, user.userId);
  }
}
