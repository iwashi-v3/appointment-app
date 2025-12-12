import { Test, TestingModule } from '@nestjs/testing';
import { ConflictException, NotFoundException } from '@nestjs/common';
import { UsersService } from './users.service';
import { DatabaseService } from '../database/database.service';
import { HashService } from '../common/services/hash.service';

describe('UsersService', () => {
  let service: UsersService;

  const mockUser = {
    userId: 'test-user-id',
    username: 'testuser',
    email: 'test@example.com',
    password: 'hashedPassword',
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
  };

  const mockDatabaseService = {
    db: {
      select: jest.fn().mockReturnThis(),
      from: jest.fn().mockReturnThis(),
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      values: jest.fn().mockReturnThis(),
      returning: jest.fn(),
      update: jest.fn().mockReturnThis(),
      set: jest.fn().mockReturnThis(),
    },
  };

  const mockHashService = {
    hashPassword: jest.fn(),
    comparePassword: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: DatabaseService, useValue: mockDatabaseService },
        { provide: HashService, useValue: mockHashService },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('createUser', () => {
    it('新規ユーザーを作成する', async () => {
      const createUserDto = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
      };

      // メール重複チェック
      mockDatabaseService.db.limit.mockResolvedValueOnce([]);
      // ユーザー名重複チェック
      mockDatabaseService.db.limit.mockResolvedValueOnce([]);
      // ユーザー作成
      mockDatabaseService.db.returning.mockResolvedValueOnce([mockUser]);
      mockHashService.hashPassword.mockResolvedValue('hashedPassword');

      const result = await service.createUser(createUserDto);

      expect(result).toEqual(mockUser);
      expect(mockHashService.hashPassword).toHaveBeenCalledWith(
        createUserDto.password,
      );
    });

    it('既存のメールアドレスの場合、ConflictExceptionをスローする', async () => {
      const createUserDto = {
        username: 'testuser',
        email: 'existing@example.com',
        password: 'password123',
      };

      // メール重複チェック - 既存ユーザーが見つかる
      mockDatabaseService.db.limit.mockResolvedValueOnce([mockUser]);

      await expect(service.createUser(createUserDto)).rejects.toThrow(
        ConflictException,
      );
    });

    it('既存のユーザー名の場合、ConflictExceptionをスローする', async () => {
      const createUserDto = {
        username: 'existinguser',
        email: 'test@example.com',
        password: 'password123',
      };

      // メール重複チェック - なし
      mockDatabaseService.db.limit.mockResolvedValueOnce([]);
      // ユーザー名重複チェック - 既存ユーザーが見つかる
      mockDatabaseService.db.limit.mockResolvedValueOnce([mockUser]);

      await expect(service.createUser(createUserDto)).rejects.toThrow(
        ConflictException,
      );
    });
  });

  describe('findByEmail', () => {
    it('メールアドレスでユーザーを検索する', async () => {
      mockDatabaseService.db.limit.mockResolvedValueOnce([mockUser]);

      const result = await service.findByEmail('test@example.com');

      expect(result).toEqual(mockUser);
    });

    it('ユーザーが見つからない場合、nullを返す', async () => {
      mockDatabaseService.db.limit.mockResolvedValueOnce([]);

      const result = await service.findByEmail('nonexistent@example.com');

      expect(result).toBeNull();
    });
  });

  describe('findById', () => {
    it('ユーザーIDでユーザーを検索する', async () => {
      mockDatabaseService.db.limit.mockResolvedValueOnce([mockUser]);

      const result = await service.findById('test-user-id');

      expect(result).toEqual(mockUser);
    });

    it('ユーザーが見つからない場合、NotFoundExceptionをスローする', async () => {
      mockDatabaseService.db.limit.mockResolvedValueOnce([]);

      await expect(service.findById('nonexistent-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('updateUser', () => {
    it('ユーザー情報を更新する', async () => {
      const updateUserDto = {
        username: 'updateduser',
      };

      const updatedUser = { ...mockUser, username: 'updateduser' };

      // ユーザー存在確認
      mockDatabaseService.db.limit.mockResolvedValueOnce([mockUser]);
      // 更新実行
      mockDatabaseService.db.returning.mockResolvedValueOnce([updatedUser]);

      const result = await service.updateUser('test-user-id', updateUserDto);

      expect(result).toEqual(updatedUser);
    });

    it('メールアドレスが既に使用されている場合、ConflictExceptionをスローする', async () => {
      const updateUserDto = {
        email: 'existing@example.com',
      };

      const anotherUser = { ...mockUser, userId: 'another-user-id' };

      // ユーザー存在確認
      mockDatabaseService.db.limit.mockResolvedValueOnce([mockUser]);
      // メール重複チェック - 別のユーザーが見つかる
      mockDatabaseService.db.limit.mockResolvedValueOnce([anotherUser]);

      await expect(
        service.updateUser('test-user-id', updateUserDto),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('deleteUser', () => {
    it('ユーザーを論理削除する', async () => {
      // ユーザー存在確認（findById内で呼ばれる）
      mockDatabaseService.db.limit.mockResolvedValueOnce([mockUser]);
      // 削除実行（update処理）
      mockDatabaseService.db.returning.mockResolvedValueOnce([mockUser]);

      const result = await service.deleteUser('test-user-id');

      expect(result).toHaveProperty('message', 'User deleted successfully');
    });

    it('ユーザーが存在しない場合、NotFoundExceptionをスローする', async () => {
      // ユーザー存在確認 - 見つからない
      mockDatabaseService.db.limit.mockResolvedValueOnce([]);

      await expect(service.deleteUser('nonexistent-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
