import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AlarmRoutineSource { manual, classSchedule }

class AlarmRoutine {
  const AlarmRoutine({
    required this.id,
    required this.title,
    required this.departureHour,
    required this.departureMinute,
    required this.prepTimeMinutes,
    required this.bufferMinutes,
    required this.weekdays,
    required this.note,
    required this.enabled,
    this.source = AlarmRoutineSource.manual,
  });

  final String id;
  final String title;
  final int departureHour;
  final int departureMinute;
  final int prepTimeMinutes;
  final int bufferMinutes;
  final List<int> weekdays;
  final String note;
  final bool enabled;
  final AlarmRoutineSource source;

  bool get isClassSchedule => source == AlarmRoutineSource.classSchedule;

  AlarmRoutine copyWith({
    String? id,
    String? title,
    int? departureHour,
    int? departureMinute,
    int? prepTimeMinutes,
    int? bufferMinutes,
    List<int>? weekdays,
    String? note,
    bool? enabled,
    AlarmRoutineSource? source,
  }) {
    return AlarmRoutine(
      id: id ?? this.id,
      title: title ?? this.title,
      departureHour: departureHour ?? this.departureHour,
      departureMinute: departureMinute ?? this.departureMinute,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      bufferMinutes: bufferMinutes ?? this.bufferMinutes,
      weekdays: weekdays ?? this.weekdays,
      note: note ?? this.note,
      enabled: enabled ?? this.enabled,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'departureHour': departureHour,
      'departureMinute': departureMinute,
      'prepTimeMinutes': prepTimeMinutes,
      'bufferMinutes': bufferMinutes,
      'weekdays': weekdays,
      'note': note,
      'enabled': enabled,
      'source': source.name,
    };
  }

  factory AlarmRoutine.fromJson(Map<String, dynamic> json) {
    return AlarmRoutine(
      id: (json['id'] as String?)?.trim().isNotEmpty == true
          ? json['id'] as String
          : 'alarm_${DateTime.now().microsecondsSinceEpoch}',
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : '새 알람',
      departureHour: _readInt(json['departureHour'], fallback: 8).clamp(0, 23),
      departureMinute: _readInt(
        json['departureMinute'],
        fallback: 30,
      ).clamp(0, 59),
      prepTimeMinutes: _readInt(
        json['prepTimeMinutes'],
        fallback: 35,
      ).clamp(0, 180),
      bufferMinutes: _readInt(json['bufferMinutes'], fallback: 20).clamp(0, 90),
      weekdays: _readWeekdays(json['weekdays']),
      note: (json['note'] as String? ?? '').trim(),
      enabled: json['enabled'] is bool ? json['enabled'] as bool : true,
      source: _readSource(json['source']),
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
      return const [1, 2, 3, 4, 5];
    }

    final parsedWeekdays =
        rawValue
            .map((item) => _readInt(item, fallback: 0))
            .where((weekday) => weekday >= 1 && weekday <= 7)
            .toSet()
            .toList()
          ..sort();

    if (parsedWeekdays.isEmpty) {
      return const [1, 2, 3, 4, 5];
    }

    return parsedWeekdays;
  }

  static AlarmRoutineSource _readSource(Object? rawValue) {
    if (rawValue is! String) {
      return AlarmRoutineSource.manual;
    }

    switch (rawValue.trim()) {
      case 'classSchedule':
        return AlarmRoutineSource.classSchedule;
      case 'manual':
      default:
        return AlarmRoutineSource.manual;
    }
  }
}

class AlarmOccurrence {
  const AlarmOccurrence({
    required this.alarm,
    required this.departureTime,
    required this.triggerTime,
  });

  final AlarmRoutine alarm;
  final DateTime departureTime;
  final DateTime triggerTime;
}

class AlarmScheduleCalculator {
  const AlarmScheduleCalculator._();

  static const List<int> weekdaySchoolDays = [1, 2, 3, 4, 5];
  static const List<Color> _accentPalette = [
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFEA580C),
    Color(0xFF7C3AED),
    Color(0xFF0F766E),
  ];

  static AlarmRoutine buildDefault({required int prepTimeMinutes}) {
    return AlarmRoutine(
      id: 'weekday_school_alarm',
      title: '평일 등교 알람',
      departureHour: 8,
      departureMinute: 30,
      prepTimeMinutes: prepTimeMinutes,
      bufferMinutes: 20,
      weekdays: weekdaySchoolDays,
      note: '학교 가는 날 기준 기본 루틴',
      enabled: true,
    );
  }

  static AlarmOccurrence? findNextOccurrence({
    required List<AlarmRoutine> alarms,
    required DateTime now,
  }) {
    AlarmOccurrence? nextOccurrence;

    for (final alarm in alarms) {
      final candidate = buildNextOccurrence(alarm: alarm, now: now);

      if (candidate == null) {
        continue;
      }

      if (nextOccurrence == null ||
          candidate.triggerTime.isBefore(nextOccurrence.triggerTime)) {
        nextOccurrence = candidate;
      }
    }

    return nextOccurrence;
  }

  static AlarmOccurrence? buildNextOccurrence({
    required AlarmRoutine alarm,
    required DateTime now,
  }) {
    if (!alarm.enabled || alarm.weekdays.isEmpty) {
      return null;
    }

    final today = DateTime(now.year, now.month, now.day);

    for (var offset = 0; offset < 8; offset += 1) {
      final date = today.add(Duration(days: offset));

      if (!alarm.weekdays.contains(date.weekday)) {
        continue;
      }

      final departureTime = buildDepartureDateTime(date: date, alarm: alarm);
      final triggerTime = buildTriggerDateTime(
        departureTime: departureTime,
        alarm: alarm,
      );

      if (triggerTime.isAfter(now)) {
        return AlarmOccurrence(
          alarm: alarm,
          departureTime: departureTime,
          triggerTime: triggerTime,
        );
      }
    }

    return null;
  }

  static DateTime buildDepartureDateTime({
    required DateTime date,
    required AlarmRoutine alarm,
  }) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      alarm.departureHour,
      alarm.departureMinute,
    );
  }

  static DateTime buildTriggerDateTime({
    required DateTime departureTime,
    required AlarmRoutine alarm,
  }) {
    return departureTime.subtract(
      Duration(minutes: alarm.prepTimeMinutes + alarm.bufferMinutes),
    );
  }

  static DateTime buildPreviewTriggerTime(AlarmRoutine alarm) {
    final departureTime = DateTime(
      2024,
      1,
      2,
      alarm.departureHour,
      alarm.departureMinute,
    );
    return buildTriggerDateTime(departureTime: departureTime, alarm: alarm);
  }

  static String buildRepeatLabel(List<int> weekdays) {
    final normalizedWeekdays = weekdays.toSet().toList()..sort();

    if (listEquals(normalizedWeekdays, const [1, 2, 3, 4, 5, 6, 7])) {
      return '매일';
    }

    if (listEquals(normalizedWeekdays, weekdaySchoolDays)) {
      return '주중';
    }

    if (listEquals(normalizedWeekdays, const [6, 7])) {
      return '주말';
    }

    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    return normalizedWeekdays.map((day) => labels[day - 1]).join(' · ');
  }

  static String buildConfigurationLabel(AlarmRoutine alarm) {
    final parts = <String>[
      if (alarm.isClassSchedule) '시간표 자동 생성',
      '${formatDuration(alarm.prepTimeMinutes)} 준비',
      if (alarm.bufferMinutes > 0) '${formatDuration(alarm.bufferMinutes)} 여유',
      if (alarm.note.trim().isNotEmpty) alarm.note.trim(),
    ];

    return parts.join(' · ');
  }

  static String buildTargetLabel(AlarmRoutine alarm) {
    if (alarm.isClassSchedule) {
      return '수업 시작';
    }

    return '외출 목표';
  }

  static Color buildAccent(int index) {
    return _accentPalette[index % _accentPalette.length];
  }

  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return '$hours시간 $remainingMinutes분';
    }

    if (hours > 0) {
      return '$hours시간';
    }

    return '$minutes분';
  }
}
