import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { CurrentUserData } from '../common/decorators/current-user.decorator';

describe('UsersController', () => {
  let controller: UsersController;
  let usersService: UsersService;

  const mockUser = {
    userId: 'test-user-id',
    username: 'testuser',
    email: 'test@example.com',
    password: 'hashedPassword',
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
  };

  const currentUser: CurrentUserData = {
    userId: 'test-user-id',
    email: 'test@example.com',
  };

  const mockUsersService = {
    findById: jest.fn(),
    updateUser: jest.fn(),
    deleteUser: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [{ provide: UsersService, useValue: mockUsersService }],
    }).compile();

    controller = module.get<UsersController>(UsersController);
    usersService = module.get<UsersService>(UsersService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getMe', () => {
    it('認証済みユーザーの情報を取得する', async () => {
      mockUsersService.findById.mockResolvedValue(mockUser);

      const result = await controller.getMe(currentUser);

      expect(result).not.toHaveProperty('password');
      expect(result).toHaveProperty('userId', mockUser.userId);
      expect(result).toHaveProperty('username', mockUser.username);
      expect(result).toHaveProperty('email', mockUser.email);
      expect(mockUsersService.findById).toHaveBeenCalledWith(currentUser.userId);
    });
  });

  describe('updateMe', () => {
    it('認証済みユーザーの情報を更新する', async () => {
      const updateUserDto: UpdateUserDto = {
        username: 'updateduser',
      };

      const updatedUser = { ...mockUser, username: 'updateduser' };
      mockUsersService.updateUser.mockResolvedValue(updatedUser);

      const result = await controller.updateMe(currentUser, updateUserDto);

      expect(result).not.toHaveProperty('password');
      expect(result).toHaveProperty('username', 'updateduser');
      expect(mockUsersService.updateUser).toHaveBeenCalledWith(
        currentUser.userId,
        updateUserDto,
      );
    });
  });

  describe('deleteMe', () => {
    it('認証済みユーザーを削除する', async () => {
      const expectedResult = { message: 'User deleted successfully' };
      mockUsersService.deleteUser.mockResolvedValue(expectedResult);

      const result = await controller.deleteMe(currentUser);

      expect(result).toEqual(expectedResult);
      expect(mockUsersService.deleteUser).toHaveBeenCalledWith(
        currentUser.userId,
      );
    });
  });
});
