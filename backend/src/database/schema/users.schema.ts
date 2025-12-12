import { pgTable, varchar, timestamp, index, uniqueIndex } from 'drizzle-orm/pg-core';

export const users = pgTable(
  'users',
  {
    userId: varchar('user_id', { length: 50 }).primaryKey().notNull(),
    username: varchar('username', { length: 50 }).notNull(),
    email: varchar('email', { length: 50 }).notNull(),
    password: varchar('password', { length: 255 }).notNull(),
    createdAt: timestamp('created_at').defaultNow().notNull(),
    updatedAt: timestamp('updated_at').defaultNow().notNull(),
    deletedAt: timestamp('deleted_at'),
  },
  (table) => ({
    emailIdx: uniqueIndex('users_email_idx').on(table.email),
    usernameIdx: index('users_username_idx').on(table.username),
    deletedAtIdx: index('users_deleted_at_idx').on(table.deletedAt),
  }),
);

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
