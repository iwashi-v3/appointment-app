import {
  pgTable,
  serial,
  varchar,
  numeric,
  date,
  time,
  timestamp,
} from 'drizzle-orm/pg-core';
import { users } from './users.schema';

export const appointments = pgTable('appointments', {
  appointmentId: serial('appointment_id').primaryKey().notNull(),
  createdUserId: varchar('created_user_id', { length: 50 })
    .notNull()
    .references(() => users.userId),
  title: varchar('title', { length: 100 }).notNull(),
  latitude: numeric('latitude').notNull(),
  longitude: numeric('longitude').notNull(),
  appointmentDate: date('appointment_date').notNull(),
  appointmentTime: time('appointment_time').notNull(),
  status: varchar('status', { length: 20 }).notNull(),
  inviteToken: varchar('invite_token', { length: 100 }).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

export type Appointment = typeof appointments.$inferSelect;
export type NewAppointment = typeof appointments.$inferInsert;
