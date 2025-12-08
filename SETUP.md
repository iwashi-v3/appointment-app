# Supabase + Docker セットアップガイド

## 初回セットアップ手順

### 1. 環境変数の設定

`.env`ファイルの以下の値を**必ず変更**してください：

```bash
POSTGRES_PASSWORD=your-super-secret-and-long-postgres-password  # 変更必須
JWT_SECRET=your-super-secret-jwt-token-with-at-least-32-characters-long  # 変更必須
```

### 2. クリーンな状態からの起動

初めて起動する場合、または完全にリセットする場合：

```bash
# 既存のコンテナとボリュームを削除（データも削除されます）
docker-compose down -v

# ボリュームディレクトリをクリーンアップ（オプション）
Remove-Item -Recurse -Force .\volumes\db\data\*

# コンテナを起動
docker-compose up -d
```

### 3. サービスの確認

起動後、以下のサービスが利用可能になります：

- **Supabase Studio**: http://localhost:8081
- **PostgREST API**: http://localhost:3000
- **Supabase Auth**: http://localhost:9999
- **PostgreSQL Meta API**: http://localhost:8080
- **Backend API**: http://localhost:4000
- **Frontend**: http://localhost:61805

### 4. サービスの状態確認

```bash
docker ps --filter "name=supabase"
```

すべてのコンテナが`Up`または`healthy`状態になっていることを確認してください。

## トラブルシューティング

### コンテナが再起動を繰り返す場合

1. ログを確認：
```bash
docker logs supabase-auth
docker logs supabase-rest
```

2. データベース接続を確認：
```bash
docker exec supabase-db psql -U postgres -c "SELECT version();"
```

### データベースをリセットする場合

```bash
# コンテナを停止
docker-compose down

# データボリュームを削除
Remove-Item -Recurse -Force .\volumes\db\data\*

# 再起動
docker-compose up -d
```

## 重要な注意事項

- `POSTGRES_PASSWORD`と`JWT_SECRET`は本番環境では必ず強力なパスワードに変更してください
- データベースボリュームを削除すると**すべてのデータが失われます**
- 初回起動時、データベース初期化スクリプト（`database/init.sql`と`database/init-auth.sql`）が自動的に実行されます
- これらの初期化スクリプトは、既存のデータベースがある場合は実行されません（`docker-entrypoint-initdb.d`の仕様）

## データベース初期化スクリプト

### init.sql
アプリケーション固有のテーブル（users, services, appointments）を作成します。

### init-auth.sql
Supabase Authに必要な`auth.factor_type`型を作成します。この型はGoTrueのマイグレーションで必要です。

## アーキテクチャ

```
Frontend (Flutter) :61805
    ↓
Backend (NestJS) :4000
    ↓
Database (PostgreSQL) :5432
    ├── PostgREST API :3000
    ├── Supabase Auth :9999
    ├── Postgres Meta :8080
    └── Supabase Studio :8081
```
