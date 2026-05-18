import 'package:flutter_test/flutter_test.dart';
import 'package:mom_nagging/features/alarm/alarm_logic.dart';

void main() {
  group('AlarmScheduleCalculator', () {
    const weekdayAlarm = AlarmRoutine(
      id: 'weekday_alarm',
      title: '평일 등교 알람',
      departureHour: 8,
      departureMinute: 30,
      prepTimeMinutes: 35,
      bufferMinutes: 20,
      weekdays: [1, 2, 3, 4, 5],
      note: '',
      enabled: true,
    );

    test('returns same-day occurrence when trigger time is still ahead', () {
      final now = DateTime(2026, 5, 11, 7, 0);

      final occurrence = AlarmScheduleCalculator.findNextOccurrence(
        alarms: const [weekdayAlarm],
        now: now,
      );

      expect(occurrence, isNotNull);
      expect(occurrence!.triggerTime, DateTime(2026, 5, 11, 7, 35));
      expect(occurrence.departureTime, DateTime(2026, 5, 11, 8, 30));
    });

    test(
      'rolls over to the next matching weekday after trigger time passes',
      () {
        final now = DateTime(2026, 5, 11, 8, 0);

        final occurrence = AlarmScheduleCalculator.findNextOccurrence(
          alarms: const [weekdayAlarm],
          now: now,
        );

        expect(occurrence, isNotNull);
        expect(occurrence!.triggerTime, DateTime(2026, 5, 12, 7, 35));
        expect(occurrence.departureTime, DateTime(2026, 5, 12, 8, 30));
      },
    );
  });
}
