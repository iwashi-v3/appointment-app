import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'state/auth_state.dart';

// Web環境ではweb_utils.dartを、それ以外（iOS/Android）ではstub_utils.dartをインポート
import 'utils/web_utils.dart' if (dart.library.io) 'utils/stub_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('環境変数ファイルの読み込みに失敗しました: $e');
  }

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
