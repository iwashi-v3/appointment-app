import {
  Injectable,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { users } from '../database/schema/users.schema';
import { eq, and, isNull } from 'drizzle-orm';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { HashService } from '../common/services/hash.service';
import { randomUUID } from 'crypto';

@Injectable()
export class UsersService {
  constructor(
    private readonly databaseService: DatabaseService,
    private readonly hashService: HashService,
  ) {}

  async createUser(createUserDto: CreateUserDto) {
    const { username, email, password } = createUserDto;

    // メールアドレスの重複チェック
    const existingUserByEmail = await this.databaseService.db
      .select()
      .from(users)
      .where(and(eq(users.email, email), isNull(users.deletedAt)))
      .limit(1);

    if (existingUserByEmail.length > 0) {
      throw new ConflictException('Email already exists');
    }

    // ユーザー名の重複チェック
    const existingUserByUsername = await this.databaseService.db
      .select()
      .from(users)
      .where(and(eq(users.username, username), isNull(users.deletedAt)))
      .limit(1);

    if (existingUserByUsername.length > 0) {
      throw new ConflictException('Username already exists');
    }

    // パスワードのハッシュ化
    const hashedPassword = await this.hashService.hashPassword(password);

    // ユーザーIDの生成
    const userId = randomUUID();

    // ユーザーの作成
    const newUser = await this.databaseService.db
      .insert(users)
      .values({
        userId,
        username,
        email,
        password: hashedPassword,
      })
      .returning();

    return newUser[0];
  }

  async findByEmail(email: string) {
    const user = await this.databaseService.db
      .select()
      .from(users)
      .where(and(eq(users.email, email), isNull(users.deletedAt)))
      .limit(1);

    return user[0] || null;
  }

  async findById(userId: string) {
    const user = await this.databaseService.db
      .select()
      .from(users)
      .where(and(eq(users.userId, userId), isNull(users.deletedAt)))
      .limit(1);

    if (!user[0]) {
      throw new NotFoundException('User not found');
    }

    return user[0];
  }

  async updateUser(userId: string, updateUserDto: UpdateUserDto) {
    // ユーザーの存在確認
    await this.findById(userId);

    // メールアドレスが変更される場合、重複チェック
    if (updateUserDto.email) {
      const existingUser = await this.databaseService.db
        .select()
        .from(users)
        .where(
          and(
            eq(users.email, updateUserDto.email),
            isNull(users.deletedAt),
            // 自分以外のユーザーをチェック
          ),
        )
        .limit(1);

      if (existingUser[0] && existingUser[0].userId !== userId) {
        throw new ConflictException('Email already exists');
      }
    }

    // ユーザー名が変更される場合、重複チェック
    if (updateUserDto.username) {
      const existingUser = await this.databaseService.db
        .select()
        .from(users)
        .where(
          and(
            eq(users.username, updateUserDto.username),
            isNull(users.deletedAt),
          ),
        )
        .limit(1);

      if (existingUser[0] && existingUser[0].userId !== userId) {
        throw new ConflictException('Username already exists');
      }
    }

    // ユーザー情報の更新
    const updatedUser = await this.databaseService.db
      .update(users)
      .set({
        ...updateUserDto,
        updatedAt: new Date(),
      })
      .where(eq(users.userId, userId))
      .returning();

    return updatedUser[0];
  }

  async deleteUser(userId: string) {
    // ユーザーの存在確認
    await this.findById(userId);

    // 論理削除
    await this.databaseService.db
      .update(users)
      .set({
        deletedAt: new Date(),
      })
      .where(eq(users.userId, userId));

    return { message: 'User deleted successfully' };
  }
}
