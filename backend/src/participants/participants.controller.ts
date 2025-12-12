import {
  Controller,
  Get,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
  ParseIntPipe,
} from '@nestjs/common';
import { ParticipantsService } from './participants.service';
import { UpdateParticipantLocationDto } from './dto/update-participant-location.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { OptionalJwtAuthGuard } from '../auth/guards/optional-jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CurrentUserData } from '../auth/strategies/jwt.strategy';

@Controller('participants')
export class ParticipantsController {
  constructor(private readonly participantsService: ParticipantsService) {}

  /**
   * 参加者の位置情報を更新（ゲストまたは登録ユーザー）
   */
  @Put(':id/location')
  @UseGuards(OptionalJwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  updateLocation(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateLocationDto: UpdateParticipantLocationDto,
    @CurrentUser() user?: CurrentUserData,
  ) {
    // セッションIDはリクエストボディやクエリから取得する必要がある
    // ここでは簡略化のため、ユーザーIDのみで判定
    return this.participantsService.updateLocation(
      id,
      updateLocationDto.userLatitude,
      updateLocationDto.userLongitude,
      user?.userId,
    );
  }

  /**
   * 参加者を削除（予約の作成者または参加者本人のみ）
   */
  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: CurrentUserData,
  ) {
    return this.participantsService.remove(id, user.userId);
  }
}
