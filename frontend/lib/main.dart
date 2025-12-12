import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState; // 追加: Supabaseパッケージ
import 'app.dart';
import 'state/auth_state.dart';

// Web環境ではweb_utils.dartを、それ以外（iOS/Android）ではstub_utils.dartをインポート
import 'utils/web_utils.dart' if (dart.library.io) 'utils/stub_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 環境変数の読み込み
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('環境変数ファイルの読み込みに失敗しました: $e');
  }

  // 2. Supabaseの初期化 (追加)
  // .envから値を読み込んで初期化します。値がない場合のフォールバックも念のため空文字で設定していますが、
  // 実際には正しいキーがないとエラーになります。
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    print('Supabase initialized successfully'); // デバッグ用ログ
  } catch (e) {
    print('Supabaseの初期化に失敗しました: $e');
  }

  // 3. Google Mapsの設定 (既存コード)
  final apiKey = dotenv.env['MAP_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    print('警告: MAP_API_KEYが設定されていません');
  } else {
    addGoogleMapsScript(apiKey);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: Consumer<AuthState>(
        builder: (_, auth, __) => MachiawaseApp(isGuest: auth.isGuest),
      ),
    ),
  );
}