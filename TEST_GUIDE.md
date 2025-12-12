# イベント状態管理機能テスト実行ガイド

## 🧪 テストの実行方法

### 1. ユニットテスト
```bash
# 個別のサービステスト
npm test events.service.spec.ts

# 個別のコントローラーテスト  
npm test events.controller.spec.ts

# 全てのユニットテスト
npm test
```

### 2. E2Eテスト
```bash
# イベントAPI E2Eテスト
npm run test:e2e events.e2e-spec.ts

# WebSocket E2Eテスト
npm run test:e2e events-websocket.e2e-spec.ts

# 全てのE2Eテスト
npm run test:e2e
```

### 3. 手動機能テスト
```bash
# アプリケーション起動
docker-compose up --build

# テストシナリオ実行
./test-scenario.sh
```

## ✅ 正解となる状態

### 🎯 基本機能が正常動作
1. **イベント作成**: POST /events でイベント作成可能
2. **イベント一覧**: GET /events で作成したイベント一覧取得
3. **イベント詳細**: GET /events/:id で個別イベント詳細取得
4. **イベント更新**: PUT /events/:id でイベント情報更新
5. **イベント削除**: DELETE /events/:id で論理削除実行

### 🔔 通知機能が正常動作
1. **イベント開始通知**: 
   - POST /events/:id/start でisActive=trueに変更
   - WebSocketで接続中の参加者に「開始」通知送信
   - 通知履歴にevent_start記録

2. **イベント終了通知**:
   - POST /events/:id/end でisActive=falseに変更
   - WebSocketで接続中の参加者に「終了」通知送信
   - 通知履歴にevent_end記録

3. **集合場所変更通知**:
   - PUT /events/:id でlocation更新時
   - WebSocketで接続中の参加者に「場所変更」通知送信
   - 通知履歴にlocation_change記録

4. **参加者入退室通知**:
   - POST /events/:id/join で参加時
   - POST /events/:id/leave で離脱時
   - WebSocketで他の参加者に入退室通知送信
   - 通知履歴にparticipant_join/leave記録

### 📡 WebSocket機能が正常動作
1. **接続管理**:
   - クライアント接続/切断が正常処理される
   - 接続エラーが適切にハンドリングされる

2. **ルーム管理**:
   - join_eventでイベントルームに参加
   - leave_eventでイベントルームから離脱
   - 切断時に自動的に全ルームから離脱

3. **通知配信**:
   - イベントルーム内の参加者のみに通知配信
   - 通知タイプ別に適切なメッセージ送信
   - リアルタイムでの通知受信

### 🗃️ データベースが正常動作
1. **テーブル作成**: 3つのテーブル(events, event_participants, event_notifications)
2. **外部キー制約**: users ↔ events, events ↔ participants/notifications
3. **インデックス**: 検索用インデックスが適切に設定
4. **データ整合性**: 論理削除、参加状態管理が正常

## 🚨 確認すべきエラーケース

### 認証エラー
- [ ] JWT未提供時に401エラー
- [ ] 無効なJWTで401エラー
- [ ] 他人のイベント操作時に403エラー

### バリデーションエラー  
- [ ] 必須フィールド未入力時にバリデーションエラー
- [ ] 不正な日時形式でバリデーションエラー
- [ ] 終了時刻が開始時刻より前の場合にエラー

### リソース不存在エラー
- [ ] 存在しないイベントID指定時に404エラー
- [ ] 削除済みイベントアクセス時に404エラー

### WebSocketエラー
- [ ] 存在しないイベントへの参加時にエラー
- [ ] 既に参加済みイベントへの重複参加処理
- [ ] 切断時の適切なクリーンアップ

## 📊 パフォーマンス要件

### レスポンス時間
- [ ] API応答時間 < 200ms (通常時)
- [ ] WebSocket通知配信 < 100ms
- [ ] 同時接続 100ユーザーまで対応

### スケーラビリティ
- [ ] イベント数 1000件まで快適動作
- [ ] 参加者数 イベント当たり50名まで
- [ ] 通知履歴 イベント当たり500件まで

## 🎯 最終確認チェックリスト

実装完了後、以下を全てクリアすれば正解：

- [ ] 全ユニットテストがPass (緑色)
- [ ] 全E2EテストがPass (緑色)
- [ ] 手動テストシナリオが全て成功
- [ ] WebSocket接続・通知が正常動作
- [ ] エラーケースが適切にハンドリング
- [ ] データベース制約が正常動作
- [ ] Docker Composeで正常起動
- [ ] パフォーマンス要件クリア

### 💡 動作確認の推奨手順

1. `docker-compose up --build` でアプリ起動
2. `npm test` でユニットテスト実行  
3. `npm run test:e2e` でE2Eテスト実行
4. `./test-scenario.sh` で手動シナリオテスト
5. ブラウザで複数タブ開いてWebSocket通知確認
6. 各エラーケースの動作確認

全て正常動作すれば ✅ **実装完了** です！
