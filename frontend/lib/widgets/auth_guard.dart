import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/auth/login_screen.dart'; // ログイン画面への遷移用

class AuthGuard extends StatelessWidget {
  final Widget child;
  final bool isGuest; // ゲストかどうか

  const AuthGuard({
    super.key,
    required this.child,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    // ゲストでなければ、そのまま中身を表示
    if (!isGuest) {
      return child;
    }

    // ゲストの場合は、中身の上にモザイクとボタンを重ねる
    return Stack(
      children: [
        // 1. 本来のコンテンツ（操作無効化のためにIgnorePointerで囲むことも可能だが、
        // 見せたいだけならそのままでもOK。今回は操作させないようにIgnorePointerを入れる）
        IgnorePointer(
          ignoring: true,
          child: child,
        ),

        // 2. モザイクフィルター (Blur効果)
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // ぼかしの強さ
              child: Container(
                color: Colors.black.withOpacity(0.1), // 少し暗くする
              ),
            ),
          ),
        ),

        // 3. ログイン誘導メッセージとボタン
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48, color: AppColors.textBody),
                const SizedBox(height: 16),
                const Text(
                  'この機能を利用するには\nログインまたは登録が必要です',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBody,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // ログイン画面へ遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'ログイン / 新規登録',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}