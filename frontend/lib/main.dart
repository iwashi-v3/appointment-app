import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

// Web環境ではweb_utils.dartを、それ以外（iOS/Android）ではstub_utils.dartをインポート
import 'utils/web_utils.dart'
  if (dart.library.io) 'utils/stub_utils.dart';

void main() async {
  // Flutterのバインディングを初期化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 環境変数を読み込み
  await dotenv.load(fileName: ".env");
  
  // Web環境の場合のみGoogle Mapsスクリプトを追加
  final apiKey = dotenv.env['MAP_API_KEY'] ?? '';
  if (apiKey.isNotEmpty) {
    addGoogleMapsScript(apiKey);
  }
  
  // アプリを起動
  runApp(const MachiawaseApp(isGuest: true));
}