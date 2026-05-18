import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mom_nagging/features/home/widgets/alarm_tile.dart';

void main() {
  testWidgets('AlarmTile renders schedule and state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlarmTile(
            accent: Colors.blue,
            title: '평일 등교 알람',
            time: 'AM 7:35',
            schedule: '주중',
            note: '35분 준비 · 20분 여유',
            enabled: true,
          ),
        ),
      ),
    );

    expect(find.text('평일 등교 알람'), findsOneWidget);
    expect(find.text('AM 7:35'), findsOneWidget);
    expect(find.text('주중'), findsOneWidget);
    expect(find.text('활성화'), findsOneWidget);
  });
}
