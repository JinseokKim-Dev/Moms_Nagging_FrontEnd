import 'package:flutter/material.dart';

class HomeFormatters {
  const HomeFormatters._();

  static String formatPrepTime(int minutes) {
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

  static String formatClockTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$period $hour:$minute';
  }

  static String formatKoreanDate(DateTime dateTime) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${dateTime.month}월 ${dateTime.day}일 ${weekdays[dateTime.weekday - 1]}요일';
  }

  static String buildGreeting(DateTime now) {
    if (now.hour < 12) {
      return '좋은 아침이에요';
    }

    if (now.hour < 18) {
      return '하루를 잘 이어가고 있네요';
    }

    return '내일 아침도 미리 준비해볼까요';
  }

  static String formatRemaining(Duration duration) {
    final totalMinutes = duration.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours <= 0) {
      return '$minutes분 남음';
    }

    return '$hours시간 $minutes분 남음';
  }
}

class HomeScheduleCalculator {
  const HomeScheduleCalculator._();

  static DateTime buildNextDepartureTime(DateTime now) {
    final todayDeparture = DateTime(now.year, now.month, now.day, 8, 30);
    if (todayDeparture.isAfter(now)) {
      return todayDeparture;
    }

    return todayDeparture.add(const Duration(days: 1));
  }

  static DateTime buildAlarmTime({
    required DateTime departureTime,
    required int prepTimeMinutes,
    int bufferMinutes = 20,
  }) {
    return departureTime.subtract(
      Duration(minutes: prepTimeMinutes + bufferMinutes),
    );
  }

  static String buildNextAlarmLabel({
    required DateTime now,
    required DateTime alarmTime,
  }) {
    final timeUntilAlarm = alarmTime.difference(now);
    if (timeUntilAlarm.isNegative) {
      return '곧 알람이 울릴 예정이에요';
    }

    return HomeFormatters.formatRemaining(timeUntilAlarm);
  }
}

class MomMoodData {
  const MomMoodData({
    required this.title,
    required this.message,
    required this.stageLabel,
    required this.icon,
    required this.primaryColor,
    required this.surfaceColor,
    required this.gaugeValue,
  });

  final String title;
  final String message;
  final String stageLabel;
  final IconData icon;
  final Color primaryColor;
  final Color surfaceColor;
  final double gaugeValue;
}

class MomMoodCalculator {
  const MomMoodCalculator._();

  static MomMoodData build({
    required DateTime now,
    required DateTime departureTime,
    required int prepTimeMinutes,
  }) {
    final bufferMinutes =
        departureTime.difference(now).inMinutes - prepTimeMinutes;

    if (bufferMinutes >= 45) {
      return const MomMoodData(
        title: '엄마가 아직은 여유로워요',
        message: '지금 흐름이면 잔소리 없이도 충분히 제시간에 나갈 수 있어요.',
        stageLabel: '평온',
        icon: Icons.sentiment_very_satisfied_rounded,
        primaryColor: Color(0xFF15803D),
        surfaceColor: Color(0xFFF0FDF4),
        gaugeValue: 0.18,
      );
    }

    if (bufferMinutes >= 20) {
      return const MomMoodData(
        title: '엄마가 슬슬 체크하기 시작했어요',
        message: '조금만 늦어져도 잔소리가 시작될 수 있으니 준비를 서두르는 게 좋아요.',
        stageLabel: '주시',
        icon: Icons.sentiment_neutral_rounded,
        primaryColor: Color(0xFFCA8A04),
        surfaceColor: Color(0xFFFEFCE8),
        gaugeValue: 0.42,
      );
    }

    if (bufferMinutes >= 0) {
      return const MomMoodData(
        title: '엄마가 눈치 주는 단계예요',
        message: '이제는 정말 움직여야 해요. 한 번만 더 미루면 바로 화낼 수 있어요.',
        stageLabel: '경고',
        icon: Icons.sentiment_dissatisfied_rounded,
        primaryColor: Color(0xFFEA580C),
        surfaceColor: Color(0xFFFFF7ED),
        gaugeValue: 0.72,
      );
    }

    if (bufferMinutes >= -15) {
      return const MomMoodData(
        title: '엄마가 화나기 시작했어요',
        message: '준비 시간이 이미 부족해졌어요. 지금은 지각 가능성이 꽤 높아요.',
        stageLabel: '분노 직전',
        icon: Icons.mood_bad_rounded,
        primaryColor: Color(0xFFDC2626),
        surfaceColor: Color(0xFFFEF2F2),
        gaugeValue: 0.9,
      );
    }

    return const MomMoodData(
      title: '엄마가 완전히 화났어요',
      message: '이미 지각 위험 구간이에요. 다음엔 알람을 더 일찍 맞추는 게 좋겠어요.',
      stageLabel: '폭발',
      icon: Icons.sms_failed_rounded,
      primaryColor: Color(0xFF991B1B),
      surfaceColor: Color(0xFFFEF2F2),
      gaugeValue: 1,
    );
  }
}
