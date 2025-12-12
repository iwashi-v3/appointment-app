import {
  IsString,
  IsNotEmpty,
  IsNumber,
  IsDateString,
  IsOptional,
  IsIn,
  MaxLength,
  Min,
  Max,
  Matches,
} from 'class-validator';

export class CreateAppointmentDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  title: string;

  @IsNumber()
  @IsNotEmpty()
  @Min(-90)
  @Max(90)
  latitude: number;

  @IsNumber()
  @IsNotEmpty()
  @Min(-180)
  @Max(180)
  longitude: number;

  @IsDateString()
  @IsNotEmpty()
  appointmentDate: string;

  @IsString()
  @IsNotEmpty()
  @Matches(/^([0-1][0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$/, {
    message: 'appointmentTime must be in HH:MM or HH:MM:SS format',
  })
  appointmentTime: string;

  @IsOptional()
  @IsString()
  @IsIn(['active', 'cancelled', 'completed'])
  status?: string;
}
