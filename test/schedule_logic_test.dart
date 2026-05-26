import 'package:flutter_test/flutter_test.dart';
import 'package:mom_nagging/features/alarm/alarm_logic.dart';
import 'package:mom_nagging/features/schedule/schedule_logic.dart';

void main() {
  group('ScheduleAlarmPlanner', () {
    const mondayClass = ClassScheduleEntry(
      id: 'data_structures',
      className: '자료구조',
      classStartHour: 9,
      classStartMinute: 0,
      weekdays: [1],
      prepTimeMinutes: 30,
      note: '1교시',
      enabled: true,
    );

    test('builds an alarm 30 minutes before class start', () {
      final preview = ScheduleAlarmPlanner.buildPreview(
        entry: mondayClass,
        now: DateTime(2026, 5, 25, 7, 45),
      );

      expect(preview.nextClassStart, DateTime(2026, 5, 25, 9, 0));
      expect(preview.alarmTime, DateTime(2026, 5, 25, 8, 30));
      expect(preview.timeUntilAlarm, const Duration(minutes: 45));
    });

    test('rolls over to the next matching weekday when today class passed', () {
      final preview = ScheduleAlarmPlanner.buildPreview(
        entry: mondayClass,
        now: DateTime(2026, 5, 25, 10, 0),
      );

      expect(preview.nextClassStart, DateTime(2026, 6, 1, 9, 0));
      expect(preview.alarmTime, DateTime(2026, 6, 1, 8, 30));
    });

    test('converts a class entry into a schedule-based alarm routine', () {
      final alarm = mondayClass.toAlarmRoutine();

      expect(alarm.title, '자료구조');
      expect(alarm.departureHour, 9);
      expect(alarm.departureMinute, 0);
      expect(alarm.prepTimeMinutes, 30);
      expect(alarm.bufferMinutes, 0);
      expect(alarm.weekdays, [1]);
      expect(alarm.note, '1교시');
      expect(alarm.source, AlarmRoutineSource.classSchedule);
    });
  });
}
