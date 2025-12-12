import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { CreateUserDto } from '../users/dto/create-user.dto';
import { SignInDto } from '../users/dto/signin.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { CreateGuestSessionDto } from './dto/create-guest-session.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('signup')
  @HttpCode(HttpStatus.CREATED)
  async signUp(@Body() createUserDto: CreateUserDto) {
    return this.authService.signUp(createUserDto);
  }

  @Post('signin')
  @HttpCode(HttpStatus.OK)
  async signIn(@Body() signInDto: SignInDto) {
    return this.authService.signIn(signInDto);
  }

  @Post('signout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  signOut() {
    return this.authService.signOut();
  }

  @Post('guest/session')
  @HttpCode(HttpStatus.CREATED)
  createGuestSession(@Body() createGuestSessionDto: CreateGuestSessionDto) {
    return this.authService.createGuestSession(createGuestSessionDto);
  }
}
