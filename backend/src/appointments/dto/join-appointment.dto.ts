import {
  IsString,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  Min,
  Max,
  MaxLength,
} from 'class-validator';

export class JoinAppointmentDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  username: string;

  @IsNumber()
  @IsNotEmpty()
  @Min(-90)
  @Max(90)
  userLatitude: number;

  @IsNumber()
  @IsNotEmpty()
  @Min(-180)
  @Max(180)
  userLongitude: number;

  @IsOptional()
  @IsString()
  sessionId?: string;
}
