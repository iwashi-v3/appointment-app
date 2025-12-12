// import 'package:flutter/foundation.dart';

// class AuthState extends ChangeNotifier {
//   bool _isGuest = true;
//   bool get isGuest => _isGuest;

//   void login() {
//     _isGuest = false;
//     notifyListeners();
//   }

//   void logout() {
//     _isGuest = true;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState extends ChangeNotifier {
  // 初期値: Supabaseにセッションがなければ「ゲスト(true)」、あれば「会員(false)」
  bool _isGuest = Supabase.instance.client.auth.currentSession == null;

  // 外部からアクセスするためのゲッター (main.dartで使用)
  bool get isGuest => _isGuest;

  AuthState() {
    // アプリ起動中、Supabaseのログイン状態が変わったら自動検知する
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      // セッションがあればゲストじゃない(false)、なければゲスト(true)
      final isNowGuest = session == null;

      // 状態が変わった時だけ画面を更新通知
      if (_isGuest != isNowGuest) {
        _isGuest = isNowGuest;
        notifyListeners();
      }
    });
  }

  // 手動でログイン状態にするメソッド (login_screen.dartで使用)
  // ※本来はonAuthStateChangeで自動検知されますが、
  //   画面遷移のタイミング制御などで明示的に呼びたい場合に備えて残します。
  void login() {
    _isGuest = false;
    notifyListeners();
  }

  // ログアウト処理（必要に応じて使用してください）
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _isGuest = true;
    notifyListeners();
  }
}