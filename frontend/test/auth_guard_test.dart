import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/auth_guard.dart';

void main() {
  testWidgets('AuthGuard overlays content for guests', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthGuard(
          isGuest: true,
          child: Scaffold(body: Center(child: Text('Protected Content'))),
        ),
      ),
    );

    // オーバーレイのメッセージが表示される
    expect(find.textContaining('この機能を利用するには'), findsOneWidget);
    // ログインボタンが表示される
    expect(find.text('ログイン / 新規登録'), findsOneWidget);

    // child 自体のテキストもレンダリングはされている（ただし操作は無効化）
    expect(find.text('Protected Content'), findsOneWidget);
  });
}
