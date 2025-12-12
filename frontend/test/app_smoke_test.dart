import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';

void main() {
  testWidgets('Root shows List screen by default (guest)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MachiawaseApp(isGuest: true));
    await tester.pumpAndSettle();

    expect(find.text('予定一覧'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // FAB はゲストでは表示されない
    expect(find.byIcon(Icons.add_location_alt), findsNothing);

    // Home タブに切り替え
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets); // AppBarタイトル等
  });
}
