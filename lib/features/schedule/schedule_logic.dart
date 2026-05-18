import '../alarm/alarm_logic.dart';

class CommuteBreakdown {
  const CommuteBreakdown({
    required this.walkMinutes,
    required this.waitMinutes,
    required this.busRideMinutes,
    required this.transferMinutes,
    required this.arrivalBufferMinutes,
  });

  final int walkMinutes;
  final int waitMinutes;
  final int busRideMinutes;
  final int transferMinutes;
  final int arrivalBufferMinutes;

  int get totalMinutes =>
      walkMinutes +
      waitMinutes +
      busRideMinutes +
      transferMinutes +
      arrivalBufferMinutes;

  String buildSummary() {
    return [
      '도보 $walkMinutes분',
      '대기 $waitMinutes분',
      '탑승 $busRideMinutes분',
      '환승 $transferMinutes분',
      '도착 여유 $arrivalBufferMinutes분',
    ].join(' · ');
  }
}

class TimetableAlarmDraft {
  const TimetableAlarmDraft({
    required this.courseTitle,
    required this.originLabel,
    required this.destinationLabel,
    required this.classStartHour,
    required this.classStartMinute,
    required this.weekdays,
    required this.leaveBufferMinutes,
    required this.commute,
    required this.note,
  });

  final String courseTitle;
  final String originLabel;
  final String destinationLabel;
  final int classStartHour;
  final int classStartMinute;
  final List<int> weekdays;
  final int leaveBufferMinutes;
  final CommuteBreakdown commute;
  final String note;

  DateTime buildClassStart(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      classStartHour,
      classStartMinute,
    );
  }

  DateTime buildDepartureTime(DateTime classStart) {
    return classStart.subtract(Duration(minutes: commute.totalMinutes));
  }

  AlarmRoutine toAlarmRoutine({required int prepTimeMinutes}) {
    final previewDate = DateTime(2024, 1, 2);
    final departureTime = buildDepartureTime(buildClassStart(previewDate));
    final summary = [
      '$originLabel -> $destinationLabel',
      commute.buildSummary(),
      if (note.trim().isNotEmpty) note.trim(),
    ].join(' · ');

    return AlarmRoutine(
      id: 'schedule_${DateTime.now().microsecondsSinceEpoch}',
      title: courseTitle.trim().isEmpty ? '첫 수업 자동 알람' : courseTitle.trim(),
      departureHour: departureTime.hour,
      departureMinute: departureTime.minute,
      prepTimeMinutes: prepTimeMinutes,
      bufferMinutes: leaveBufferMinutes,
      weekdays: [...weekdays]..sort(),
      note: summary,
      enabled: true,
    );
  }
}

class TimetableAlarmPreview {
  const TimetableAlarmPreview({
    required this.nextClassStart,
    required this.departureTime,
    required this.alarmTime,
    required this.departureSlack,
  });

  final DateTime nextClassStart;
  final DateTime departureTime;
  final DateTime alarmTime;
  final Duration departureSlack;
}

class ScheduleAlarmPlanner {
  const ScheduleAlarmPlanner._();

  static TimetableAlarmPreview buildPreview({
    required TimetableAlarmDraft draft,
    required int prepTimeMinutes,
    DateTime? now,
  }) {
    final referenceNow = now ?? DateTime.now();
    final nextClassStart = _resolveNextClassStart(
      now: referenceNow,
      hour: draft.classStartHour,
      minute: draft.classStartMinute,
      weekdays: draft.weekdays,
    );
    final departureTime = draft.buildDepartureTime(nextClassStart);
    final alarmTime = departureTime.subtract(
      Duration(minutes: prepTimeMinutes + draft.leaveBufferMinutes),
    );

    return TimetableAlarmPreview(
      nextClassStart: nextClassStart,
      departureTime: departureTime,
      alarmTime: alarmTime,
      departureSlack: departureTime.difference(referenceNow),
    );
  }

  static DateTime _resolveNextClassStart({
    required DateTime now,
    required int hour,
    required int minute,
    required List<int> weekdays,
  }) {
    final normalizedWeekdays = weekdays.toSet().toList()..sort();
    final today = DateTime(now.year, now.month, now.day);

    for (var offset = 0; offset < 8; offset += 1) {
      final date = today.add(Duration(days: offset));

      if (!normalizedWeekdays.contains(date.weekday)) {
        continue;
      }

      final classStart = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );

      if (classStart.isAfter(now)) {
        return classStart;
      }
    }

    final fallbackDate = today.add(const Duration(days: 7));
    return DateTime(
      fallbackDate.year,
      fallbackDate.month,
      fallbackDate.day,
      hour,
      minute,
    );
  }

  static String buildSlackLabel(Duration duration) {
    if (duration.isNegative) {
      return '${duration.abs().inMinutes}분 늦어요';
    }

    final minutes = duration.inMinutes;

    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes == 0
          ? '$hours시간 여유'
          : '$hours시간 $remainingMinutes분 여유';
    }

    return '$minutes분 여유';
  }
}
