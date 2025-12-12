import { IsNumber, IsNotEmpty, Min, Max } from 'class-validator';

export class UpdateParticipantLocationDto {
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
}
