import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { HashService } from '../common/services/hash.service';
import { SessionService } from './services/session.service';

describe('AuthService', () => {
  let service: AuthService;

  const mockUser = {
    userId: 'test-user-id',
    username: 'testuser',
    email: 'test@example.com',
    password: 'hashedPassword',
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
  };

  const mockUsersService = {
    createUser: jest.fn(),
    findByEmail: jest.fn(),
  };

  const mockJwtService = {
    sign: jest.fn(),
  };

  const mockHashService = {
    hashPassword: jest.fn(),
    comparePassword: jest.fn(),
  };

  const mockSessionService = {
    createSession: jest.fn(),
    getSession: jest.fn(),
    deleteSession: jest.fn(),
    cleanupExpiredSessions: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UsersService, useValue: mockUsersService },
        { provide: JwtService, useValue: mockJwtService },
        { provide: HashService, useValue: mockHashService },
        { provide: SessionService, useValue: mockSessionService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('signUp', () => {
    it('新規ユーザーを作成し、JWTトークンを返す', async () => {
      const createUserDto = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
      };

      mockUsersService.createUser.mockResolvedValue(mockUser);
      mockJwtService.sign.mockReturnValue('jwt-token');

      const result = await service.signUp(createUserDto);

      expect(result).toHaveProperty('accessToken', 'jwt-token');
      expect(result).toHaveProperty('user');
      expect(result.user).not.toHaveProperty('password');
      expect(mockUsersService.createUser).toHaveBeenCalledWith(createUserDto);
      expect(mockJwtService.sign).toHaveBeenCalledWith({
        sub: mockUser.userId,
        email: mockUser.email,
      });
    });
  });

  describe('signIn', () => {
    it('正しい認証情報でJWTトークンを返す', async () => {
      const signInDto = {
        email: 'test@example.com',
        password: 'password123',
      };

      mockUsersService.findByEmail.mockResolvedValue(mockUser);
      mockHashService.comparePassword.mockResolvedValue(true);
      mockJwtService.sign.mockReturnValue('jwt-token');

      const result = await service.signIn(signInDto);

      expect(result).toHaveProperty('accessToken', 'jwt-token');
      expect(result).toHaveProperty('user');
      expect(result.user).not.toHaveProperty('password');
      expect(mockUsersService.findByEmail).toHaveBeenCalledWith(
        signInDto.email,
      );
      expect(mockHashService.comparePassword).toHaveBeenCalledWith(
        signInDto.password,
        mockUser.password,
      );
    });

    it('存在しないユーザーの場合、UnauthorizedExceptionをスローする', async () => {
      const signInDto = {
        email: 'nonexistent@example.com',
        password: 'password123',
      };

      mockUsersService.findByEmail.mockResolvedValue(null);

      await expect(service.signIn(signInDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('パスワードが間違っている場合、UnauthorizedExceptionをスローする', async () => {
      const signInDto = {
        email: 'test@example.com',
        password: 'wrongpassword',
      };

      mockUsersService.findByEmail.mockResolvedValue(mockUser);
      mockHashService.comparePassword.mockResolvedValue(false);

      await expect(service.signIn(signInDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('signOut', () => {
    it('サインアウト成功メッセージを返す', () => {
      const result = service.signOut();

      expect(result).toHaveProperty('message', 'Signed out successfully');
    });
  });
});
