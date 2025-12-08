-- Supabase Auth初期化スクリプト
-- auth.factor_type型を作成（Supabase Authのマイグレーションに必要）

-- authスキーマが既に存在する場合のみ実行
DO $$
BEGIN
    -- auth.factor_type型が存在しない場合のみ作成
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'factor_type' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'auth')) THEN
        CREATE TYPE auth.factor_type AS ENUM ('totp', 'webauthn');
        RAISE NOTICE 'auth.factor_type型を作成しました';
    ELSE
        RAISE NOTICE 'auth.factor_type型は既に存在します';
    END IF;
EXCEPTION
    WHEN undefined_object THEN
        RAISE NOTICE 'authスキーマが存在しないため、auth.factor_type型の作成をスキップしました';
    WHEN OTHERS THEN
        RAISE NOTICE 'エラーが発生しましたが、処理を続行します: %', SQLERRM;
END $$;
