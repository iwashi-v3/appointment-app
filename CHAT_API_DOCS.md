# Chat機能 API ドキュメント

## 概要
このチャット機能は、リアルタイムメッセージング、入力中表示、メッセージ履歴保存機能を提供します。

## 機能
- ✅ リアルタイムメッセージ送受信
- ✅ 入力中（typing）状態表示
- ✅ メッセージ履歴保存・取得
- ✅ WebSocket認証
- ✅ イベント単位でのチャットルーム

## API エンドポイント

### REST API

#### メッセージ作成
```
POST /chat/messages
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "eventId": "string",
  "content": "string", 
  "messageType": "text" | "system" | "image"
}
```

#### メッセージ履歴取得
```
GET /chat/messages/:eventId?limit=50&offset=0
Authorization: Bearer <JWT_TOKEN>
```

#### 入力中ユーザー取得
```
GET /chat/typing/:eventId
Authorization: Bearer <JWT_TOKEN>
```

### WebSocket API

#### 接続
```javascript
import { io } from 'socket.io-client';

const socket = io('http://localhost:3000/chat', {
  auth: { token: 'your-jwt-token' }
});
```

#### イベント

**送信イベント:**
- `joinRoom` - ルームに参加
- `leaveRoom` - ルームから退出
- `sendMessage` - メッセージ送信
- `startTyping` - 入力開始
- `stopTyping` - 入力停止
- `getMessageHistory` - 履歴取得

**受信イベント:**
- `newMessage` - 新しいメッセージ
- `messageHistory` - メッセージ履歴
- `userStartedTyping` - ユーザー入力開始
- `userStoppedTyping` - ユーザー入力停止
- `error` - エラー

## データベーススキーマ

### messages テーブル
```sql
CREATE TABLE messages (
    message_id VARCHAR(50) PRIMARY KEY,
    event_id VARCHAR(50) REFERENCES events(event_id),
    sender_id VARCHAR(50) REFERENCES users(user_id), 
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text',
    is_edited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP
);
```

### typing_status テーブル
```sql
CREATE TABLE typing_status (
    id VARCHAR(50) PRIMARY KEY,
    event_id VARCHAR(50) REFERENCES events(event_id),
    user_id VARCHAR(50) REFERENCES users(user_id),
    is_typing BOOLEAN DEFAULT FALSE,
    last_typing_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(event_id, user_id)
);
```

## 使用例

### フロントエンド実装例
```typescript
import { ChatClient } from './frontend-chat-example';

const chat = new ChatClient('http://localhost:3000', authToken);

// イベントハンドラー設定
chat.onNewMessage = (message) => {
  displayMessage(message);
};

chat.onUserStartedTyping = (data) => {
  showTypingIndicator(data.username);
};

// 接続とルーム参加
await chat.connect();
chat.joinRoom(eventId);

// メッセージ送信
chat.sendMessage('Hello!');
```

## セットアップ

1. **データベースマイグレーション実行:**
```bash
# 新しいチャットテーブルを作成
psql -d your_database -f database/init-chat.sql
```

2. **バックエンド起動:**
```bash
cd backend
npm run start:dev
```

3. **フロントエンド側で必要なパッケージインストール:**
```bash
npm install socket.io-client
```

## テスト

### ユニットテスト
```bash
cd backend
npm run test -- chat.service.spec.ts
```

### E2Eテスト  
```bash
cd backend
npm run test:e2e -- chat.e2e-spec.ts
```

## パフォーマンス最適化

- メッセージ取得時のページネーション対応
- 入力中状態の自動クリーンアップ（30秒後）
- データベースインデックス最適化
- WebSocket接続数制限とレート制限（今後実装予定）

## セキュリティ

- JWT認証によるWebSocket接続保護
- イベント参加権限チェック（今後実装予定）
- メッセージ内容のサニタイゼーション（今後実装予定）
