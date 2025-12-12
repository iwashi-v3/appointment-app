import { Injectable } from '@nestjs/common';

export interface LocationData {
  userId?: string;
  sessionId?: string;
  username?: string;
  isGuest: boolean;
  latitude: number;
  longitude: number;
  appointmentId: number;
  timestamp: Date;
}

@Injectable()
export class LocationService {
  // clientId -> LocationData のマップ
  private locations = new Map<string, LocationData>();

  // appointmentId -> Set<clientId> のマップ
  private appointmentParticipants = new Map<number, Set<string>>();

  /**
   * 位置情報を更新
   */
  async updateLocation(
    clientId: string,
    locationData: LocationData,
  ): Promise<void> {
    const { appointmentId } = locationData;

    // 位置情報を保存
    this.locations.set(clientId, locationData);

    // 予約の参加者リストに追加
    if (!this.appointmentParticipants.has(appointmentId)) {
      this.appointmentParticipants.set(appointmentId, new Set());
    }
    this.appointmentParticipants.get(appointmentId).add(clientId);
  }

  /**
   * 位置情報を削除
   */
  async removeLocation(clientId: string): Promise<void> {
    const locationData = this.locations.get(clientId);

    if (locationData) {
      const { appointmentId } = locationData;

      // 予約の参加者リストから削除
      const participants = this.appointmentParticipants.get(appointmentId);
      if (participants) {
        participants.delete(clientId);

        // 参加者がいなくなったら予約エントリも削除
        if (participants.size === 0) {
          this.appointmentParticipants.delete(appointmentId);
        }
      }
    }

    // 位置情報を削除
    this.locations.delete(clientId);
  }

  /**
   * 特定の予約の全参加者の位置情報を取得
   */
  async getLocationsByAppointment(
    appointmentId: number,
  ): Promise<LocationData[]> {
    const participants = this.appointmentParticipants.get(appointmentId);

    if (!participants) {
      return [];
    }

    const locations: LocationData[] = [];

    for (const clientId of participants) {
      const location = this.locations.get(clientId);
      if (location) {
        locations.push(location);
      }
    }

    return locations;
  }

  /**
   * 古い位置情報をクリーンアップ（5分以上更新されていないもの）
   */
  cleanupOldLocations(): number {
    const now = new Date();
    const expiryTime = 5 * 60 * 1000; // 5分
    let deletedCount = 0;

    for (const [clientId, location] of this.locations.entries()) {
      const timeDiff = now.getTime() - location.timestamp.getTime();

      if (timeDiff > expiryTime) {
        this.removeLocation(clientId);
        deletedCount++;
      }
    }

    return deletedCount;
  }

  /**
   * アクティブな位置情報の数を取得
   */
  getActiveLocationCount(): number {
    return this.locations.size;
  }

  /**
   * アクティブな予約の数を取得
   */
  getActiveAppointmentCount(): number {
    return this.appointmentParticipants.size;
  }
}
