-- 予約アプリケーション用のテーブル作成スクリプト

-- ユーザーテーブル
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- サービス/メニューテーブル
CREATE TABLE IF NOT EXISTS services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL,
    price DECIMAL(10, 2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 予約テーブル
CREATE TABLE IF NOT EXISTS appointments (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    service_id INTEGER REFERENCES services(id) ON DELETE SET NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_appointment UNIQUE (service_id, appointment_date, appointment_time)
);

-- インデックスの作成
CREATE INDEX IF NOT EXISTS idx_appointments_user_id ON appointments(user_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- サンプルデータの挿入（開発用）
INSERT INTO services (name, description, duration_minutes, price) VALUES
    ('カット', '基本的なヘアカット', 30, 3000.00),
    ('カラー', 'ヘアカラーリング', 60, 5000.00),
    ('パーマ', 'パーマネントウェーブ', 90, 7000.00)
ON CONFLICT DO NOTHING;

-- 管理者ユーザーの作成（パスワード: admin123）
INSERT INTO users (email, name, password_hash, role) VALUES
    ('admin@example.com', '管理者', '$2b$10$rKZvVqVvVqVvVqVvVqVvVeZGZGZGZGZGZGZGZGZGZGZGZGZGZGZ', 'admin')
ON CONFLICT (email) DO NOTHING;
