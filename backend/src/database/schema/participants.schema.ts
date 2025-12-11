import {
  pgTable,
  serial,
  integer,
  varchar,
  numeric,
  timestamp,
} from 'drizzle-orm/pg-core';
import { appointments } from './appointments.schema';
import { users } from './users.schema';

export const participants = pgTable('participants', {
  id: serial('id').primaryKey().notNull(),
  appointmentId: integer('appointment_id')
    .notNull()
    .references(() => appointments.appointmentId),
  userId: varchar('user_id', { length: 50 }).references(() => users.userId),
  sessionId: varchar('session_id', { length: 100 }),
  username: varchar('username', { length: 50 }).notNull(),
  isGuest: varchar('is_guest', { length: 10 }).notNull(),
  userLatitude: numeric('user_latitude').notNull(),
  userLongitude: numeric('user_longitude').notNull(),
  joinedAt: timestamp('joined_at').defaultNow().notNull(),
});

export type Participant = typeof participants.$inferSelect;
export type NewParticipant = typeof participants.$inferInsert;
