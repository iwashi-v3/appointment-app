import { pgTable, varchar, timestamp, text, boolean } from 'drizzle-orm/pg-core';
import { users } from './users.schema';

export const events = pgTable('events', {
  eventId: varchar('event_id', { length: 50 }).primaryKey().notNull(),
  title: varchar('title', { length: 255 }).notNull(),
  description: text('description'),
  location: varchar('location', { length: 255 }),
  startTime: timestamp('start_time').notNull(),
  endTime: timestamp('end_time').notNull(),
  creatorId: varchar('creator_id', { length: 50 }).references(() => users.userId).notNull(),
  isActive: boolean('is_active').default(false).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
  deletedAt: timestamp('deleted_at'),
});

export const eventParticipants = pgTable('event_participants', {
  id: varchar('id', { length: 50 }).primaryKey().notNull(),
  eventId: varchar('event_id', { length: 50 }).references(() => events.eventId).notNull(),
  userId: varchar('user_id', { length: 50 }).references(() => users.userId).notNull(),
  joinedAt: timestamp('joined_at').defaultNow().notNull(),
  leftAt: timestamp('left_at'),
  isCurrentlyInRoom: boolean('is_currently_in_room').default(false).notNull(),
});

export const eventNotifications = pgTable('event_notifications', {
  id: varchar('id', { length: 50 }).primaryKey().notNull(),
  eventId: varchar('event_id', { length: 50 }).references(() => events.eventId).notNull(),
  type: varchar('type', { length: 50 }).notNull(), // 'event_start', 'event_end', 'location_change', 'participant_join', 'participant_leave'
  message: text('message').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export type Event = typeof events.$inferSelect;
export type NewEvent = typeof events.$inferInsert;
export type EventParticipant = typeof eventParticipants.$inferSelect;
export type NewEventParticipant = typeof eventParticipants.$inferInsert;
export type EventNotification = typeof eventNotifications.$inferSelect;
export type NewEventNotification = typeof eventNotifications.$inferInsert;
