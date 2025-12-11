import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as usersSchema from './schema/users.schema';
import * as eventsSchema from './schema/events.schema';
import * as messagesSchema from './schema/messages.schema';

const schema = { ...usersSchema, ...eventsSchema, ...messagesSchema };

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  public db: ReturnType<typeof drizzle>;
  private client: ReturnType<typeof postgres>;

  constructor(private configService: ConfigService) {}

  onModuleInit() {
    const connectionString = this.configService.get<string>('DATABASE_URL');

    if (!connectionString) {
      throw new Error('DATABASE_URL is not defined in environment variables');
    }

    this.client = postgres(connectionString);
    this.db = drizzle(this.client, { schema });
  }

  async onModuleDestroy() {
    await this.client.end();
  }
}
