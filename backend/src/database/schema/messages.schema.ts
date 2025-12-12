import { pgTable, varchar, timestamp, text, boolean } from 'drizzle-orm/pg-core';
import { users } from './users.schema';
import { events } from './events.schema';

export const messages = pgTable('messages', {
  messageId: varchar('message_id', { length: 50 }).primaryKey().notNull(),
  eventId: varchar('event_id', { length: 50 }).references(() => events.eventId).notNull(),
  senderId: varchar('sender_id', { length: 50 }).references(() => users.userId).notNull(),
  content: text('content').notNull(),
  messageType: varchar('message_type', { length: 20 }).default('text').notNull(), // 'text', 'system', 'image', etc.
  isEdited: boolean('is_edited').default(false).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
  deletedAt: timestamp('deleted_at'),
});

export const typingStatus = pgTable('typing_status', {
  id: varchar('id', { length: 50 }).primaryKey().notNull(),
  eventId: varchar('event_id', { length: 50 }).references(() => events.eventId).notNull(),
  userId: varchar('user_id', { length: 50 }).references(() => users.userId).notNull(),
  isTyping: boolean('is_typing').default(false).notNull(),
  lastTypingAt: timestamp('last_typing_at').defaultNow().notNull(),
});

export type Message = typeof messages.$inferSelect;
export type NewMessage = typeof messages.$inferInsert;
export type TypingStatus = typeof typingStatus.$inferSelect;
export type NewTypingStatus = typeof typingStatus.$inferInsert;
