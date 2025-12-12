import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/list/meeting_detail_map_screen.dart';

void main() {
  testWidgets('MeetingDetailMapScreen shows title and pin label', (
    WidgetTester tester,
  ) async {
    final meeting = <String, dynamic>{
      'id': '1',
      'title': 'テスト待ち合わせ',
      'location': 'どこか',
      'datetime': DateTime.now(),
      'members': ['A', 'B'],
    };

    await tester.pumpWidget(
      MaterialApp(home: MeetingDetailMapScreen(meetingData: meeting)),
    );

    await tester.pumpAndSettle();

    // AppBar タイトル
    expect(find.text('テスト待ち合わせ'), findsOneWidget);
    // 中央ピンのラベル
    expect(find.text('集合場所'), findsOneWidget);
  });
}
