-- Chat機能のためのテーブルを作成

-- メッセージテーブル
CREATE TABLE IF NOT EXISTS messages (
    message_id VARCHAR(50) PRIMARY KEY NOT NULL,
    event_id VARCHAR(50) NOT NULL REFERENCES events(event_id),
    sender_id VARCHAR(50) NOT NULL REFERENCES users(user_id),
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' NOT NULL,
    is_edited BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP
);

-- 入力中状態テーブル
CREATE TABLE IF NOT EXISTS typing_status (
    id VARCHAR(50) PRIMARY KEY NOT NULL,
    event_id VARCHAR(50) NOT NULL REFERENCES events(event_id),
    user_id VARCHAR(50) NOT NULL REFERENCES users(user_id),
    is_typing BOOLEAN DEFAULT FALSE NOT NULL,
    last_typing_at TIMESTAMP DEFAULT NOW() NOT NULL,
    UNIQUE(event_id, user_id)
);

-- インデックスを作成してクエリパフォーマンスを向上
CREATE INDEX IF NOT EXISTS idx_messages_event_id ON messages(event_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_typing_status_event_id ON typing_status(event_id);
CREATE INDEX IF NOT EXISTS idx_typing_status_user_id ON typing_status(user_id);
CREATE INDEX IF NOT EXISTS idx_typing_status_last_typing_at ON typing_status(last_typing_at);
