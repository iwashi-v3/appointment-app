import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class AppointmentResponseDto {
  @Expose()
  appointmentId: number;

  @Expose()
  createdUserId: string;

  @Expose()
  title: string;

  @Expose()
  latitude: string;

  @Expose()
  longitude: string;

  @Expose()
  appointmentDate: string;

  @Expose()
  appointmentTime: string;

  @Expose()
  status: string;

  @Expose()
  inviteUrl: string;

  @Expose()
  createdAt: Date;

  @Expose()
  updatedAt: Date;
}
