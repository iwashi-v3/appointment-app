import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { HashService } from '../common/services/hash.service';
import { CreateUserDto } from '../users/dto/create-user.dto';
import { SignInDto } from '../users/dto/signin.dto';
import { CreateGuestSessionDto } from './dto/create-guest-session.dto';
import { SessionService } from './services/session.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly hashService: HashService,
    private readonly sessionService: SessionService,
  ) {}

  async signUp(createUserDto: CreateUserDto) {
    const user = await this.usersService.createUser(createUserDto);

    const payload = { sub: user.userId, email: user.email };
    const accessToken = this.jwtService.sign(payload);

    return {
      accessToken,
      user: {
        userId: user.userId,
        username: user.username,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
    };
  }

  async signIn(signInDto: SignInDto) {
    const { email, password } = signInDto;

    const user = await this.usersService.findByEmail(email);

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await this.hashService.comparePassword(
      password,
      user.password,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = { sub: user.userId, email: user.email };
    const accessToken = this.jwtService.sign(payload);

    return {
      accessToken,
      user: {
        userId: user.userId,
        username: user.username,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
    };
  }

  signOut() {
    // JWTはステートレスなので、クライアント側でトークンを破棄する
    return { message: 'Signed out successfully' };
  }

  createGuestSession(createGuestSessionDto: CreateGuestSessionDto) {
    const { username } = createGuestSessionDto;
    const session = this.sessionService.createGuestSession(username);

    return {
      sessionId: session.sessionId,
      username: session.username,
      expiresAt: session.expiresAt,
    };
  }
}
