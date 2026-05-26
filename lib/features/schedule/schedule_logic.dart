import 'package:flutter/foundation.dart';

import '../alarm/alarm_logic.dart';

class ClassScheduleEntry {
  const ClassScheduleEntry({
    required this.id,
    required this.className,
    required this.classStartHour,
    required this.classStartMinute,
    required this.weekdays,
    required this.prepTimeMinutes,
    required this.note,
    required this.enabled,
  });

  final String id;
  final String className;
  final int classStartHour;
  final int classStartMinute;
  final List<int> weekdays;
  final int prepTimeMinutes;
  final String note;
  final bool enabled;

  ClassScheduleEntry copyWith({
    String? id,
    String? className,
    int? classStartHour,
    int? classStartMinute,
    List<int>? weekdays,
    int? prepTimeMinutes,
    String? note,
    bool? enabled,
  }) {
    return ClassScheduleEntry(
      id: id ?? this.id,
      className: className ?? this.className,
      classStartHour: classStartHour ?? this.classStartHour,
      classStartMinute: classStartMinute ?? this.classStartMinute,
      weekdays: weekdays ?? this.weekdays,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      note: note ?? this.note,
      enabled: enabled ?? this.enabled,
    );
  }

  DateTime buildClassStart(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      classStartHour,
      classStartMinute,
    );
  }

  AlarmRoutine toAlarmRoutine() {
    final normalizedWeekdays = [...weekdays]..sort();

    debugPrint(
      '[ClassScheduleEntry] Generate alarm: '
      'class=$className '
      'weekdays=$normalizedWeekdays '
      'start=${classStartHour.toString().padLeft(2, '0')}:${classStartMinute.toString().padLeft(2, '0')} '
      'prep=$prepTimeMinutes',
    );

    return AlarmRoutine(
      id: 'schedule_alarm_$id',
      title: className.trim().isEmpty ? '수업 자동 알람' : className.trim(),
      departureHour: classStartHour,
      departureMinute: classStartMinute,
      prepTimeMinutes: prepTimeMinutes,
      bufferMinutes: 0,
      weekdays: normalizedWeekdays,
      note: note.trim(),
      enabled: enabled,
      source: AlarmRoutineSource.classSchedule,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'className': className,
      'classStartHour': classStartHour,
      'classStartMinute': classStartMinute,
      'weekdays': weekdays,
      'prepTimeMinutes': prepTimeMinutes,
      'note': note,
      'enabled': enabled,
    };
  }

  factory ClassScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ClassScheduleEntry(
      id: (json['id'] as String?)?.trim().isNotEmpty == true
          ? (json['id'] as String).trim()
          : 'schedule_${DateTime.now().microsecondsSinceEpoch}',
      className: (json['className'] as String?)?.trim().isNotEmpty == true
          ? (json['className'] as String).trim()
          : '새 수업',
      classStartHour: _readInt(
        json['classStartHour'],
        fallback: 9,
      ).clamp(0, 23),
      classStartMinute: _readInt(
        json['classStartMinute'],
        fallback: 0,
      ).clamp(0, 59),
      weekdays: _readWeekdays(json['weekdays']),
      prepTimeMinutes: _readInt(
        json['prepTimeMinutes'],
        fallback: 30,
      ).clamp(1, 180),
      note: (json['note'] as String? ?? '').trim(),
      enabled: json['enabled'] is bool ? json['enabled'] as bool : true,
    );
  }

  static int _readInt(Object? rawValue, {required int fallback}) {
    if (rawValue is int) {
      return rawValue;
    }

    if (rawValue is num) {
      return rawValue.toInt();
    }

    if (rawValue is String) {
      return int.tryParse(rawValue) ?? fallback;
    }

    return fallback;
  }

  static List<int> _readWeekdays(Object? rawValue) {
    if (rawValue is! List) {
      return AlarmScheduleCalculator.weekdaySchoolDays;
    }

    final parsedWeekdays =
        rawValue
            .map((item) => _readInt(item, fallback: 0))
            .where((weekday) => weekday >= 1 && weekday <= 7)
            .toSet()
            .toList()
          ..sort();

    if (parsedWeekdays.isEmpty) {
      return AlarmScheduleCalculator.weekdaySchoolDays;
    }

    return parsedWeekdays;
  }
}

class ClassSchedulePreview {
  const ClassSchedulePreview({
    required this.nextClassStart,
    required this.alarmTime,
    required this.timeUntilAlarm,
  });

  final DateTime nextClassStart;
  final DateTime alarmTime;
  final Duration timeUntilAlarm;
}

class ScheduleAlarmPlanner {
  const ScheduleAlarmPlanner._();

  static DateTime buildAlarmTime({
    required DateTime classStart,
    required int prepTimeMinutes,
  }) {
    return classStart.subtract(Duration(minutes: prepTimeMinutes));
  }

  static ClassSchedulePreview buildPreview({
    required ClassScheduleEntry entry,
    DateTime? now,
  }) {
    final referenceNow = now ?? DateTime.now();
    final nextClassStart = resolveNextClassStart(
      now: referenceNow,
      weekdays: entry.weekdays,
      hour: entry.classStartHour,
      minute: entry.classStartMinute,
    );
    final alarmTime = buildAlarmTime(
      classStart: nextClassStart,
      prepTimeMinutes: entry.prepTimeMinutes,
    );

    return ClassSchedulePreview(
      nextClassStart: nextClassStart,
      alarmTime: alarmTime,
      timeUntilAlarm: alarmTime.difference(referenceNow),
    );
  }

  static DateTime resolveNextClassStart({
    required DateTime now,
    required List<int> weekdays,
    required int hour,
    required int minute,
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

  static String buildTimeUntilLabel(Duration duration) {
    if (duration.isNegative) {
      return '${duration.abs().inMinutes}분 전 시간이에요';
    }

    final minutes = duration.inMinutes;

    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (remainingMinutes == 0) {
        return '$hours시간 뒤 알람';
      }

      return '$hours시간 $remainingMinutes분 뒤 알람';
    }

    return '$minutes분 뒤 알람';
  }
}
