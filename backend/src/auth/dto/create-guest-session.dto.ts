import { IsString, IsNotEmpty, MinLength, MaxLength } from 'class-validator';

export class CreateGuestSessionDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(1)
  @MaxLength(50)
  username: string;
}
