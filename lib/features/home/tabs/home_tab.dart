import 'package:flutter/material.dart';

import '../../alarm/alarm_logic.dart';
import '../home_logic.dart';
import '../home_widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.now,
    required this.prepTimeMinutes,
    required this.departureTime,
    required this.alarmTime,
    required this.nextAlarmLabel,
    required this.nextAlarmTitle,
    required this.hasActiveAlarm,
    required this.bufferMinutes,
    required this.alarms,
    required this.originalPrepTimeMinutes,
    required this.onOpenAlarmTab,
    required this.onToggleAlarm,
    required this.onOpenSettingsTab,
    required this.onComingSoon,
  });

  final DateTime now;
  final int prepTimeMinutes;
  final DateTime departureTime;
  final DateTime alarmTime;
  final String nextAlarmLabel;
  final String nextAlarmTitle;
  final bool hasActiveAlarm;
  final int bufferMinutes;
  final List<AlarmRoutine> alarms;
  final int? originalPrepTimeMinutes;
  final VoidCallback onOpenAlarmTab;
  final ValueChanged<AlarmRoutine> onToggleAlarm;
  final VoidCallback onOpenSettingsTab;
  final ValueChanged<String> onComingSoon;

  @override
  Widget build(BuildContext context) {
    final momMood = MomMoodCalculator.build(
      now: now,
      departureTime: departureTime,
      prepTimeMinutes: prepTimeMinutes,
    );
    final visibleAlarms = [...alarms]
      ..sort((left, right) {
        final leftNext = AlarmScheduleCalculator.buildNextOccurrence(
          alarm: left,
          now: now,
        );
        final rightNext = AlarmScheduleCalculator.buildNextOccurrence(
          alarm: right,
          now: now,
        );

        if (leftNext == null && rightNext == null) {
          return left.title.compareTo(right.title);
        }

        if (leftNext == null) {
          return 1;
        }

        if (rightNext == null) {
          return -1;
        }

        return leftNext.triggerTime.compareTo(rightNext.triggerTime);
      });
    final previewAlarms = visibleAlarms.take(2).toList(growable: false);

    return GradientPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE2B8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.alarm_rounded,
                    color: Color(0xFF9A3412),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        HomeFormatters.buildGreeting(now),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        HomeFormatters.formatKoreanDate(now),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF153A5B), Color(0xFF285780)],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(21, 58, 91, 0.18),
                    blurRadius: 28,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -18,
                    right: -12,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.09),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -52,
                    left: -12,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'NEXT ALARM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        hasActiveAlarm
                            ? HomeFormatters.formatClockTime(alarmTime)
                            : '설정 필요',
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        nextAlarmLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFFD6E4F0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nextAlarmTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '외출 목표',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFD6E4F0),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    HomeFormatters.formatClockTime(
                                      departureTime,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 42,
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '준비 시간',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFD6E4F0),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      HomeFormatters.formatPrepTime(
                                        prepTimeMinutes,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const SectionTitle(
              title: '엄마 캐릭터 상태',
              subtitle: '지각 위험이 높아질수록 엄마의 반응이 점점 더 매서워져요.',
            ),
            const SizedBox(height: 16),
            MomMoodCard(
              mood: momMood,
              prepTimeMinutes: prepTimeMinutes,
              departureTime: departureTime,
            ),
            const SizedBox(height: 28),
            const SectionTitle(
              title: '오늘의 준비 플랜',
              subtitle: '설정된 준비 시간과 다음 외출 기준으로 아침 루틴을 정리했어요.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                MetricCard(
                  label: '기상 알람',
                  value: hasActiveAlarm
                      ? HomeFormatters.formatClockTime(alarmTime)
                      : '미설정',
                  icon: Icons.bedtime_rounded,
                  tint: const Color(0xFF0F766E),
                ),
                const SizedBox(width: 12),
                MetricCard(
                  label: '준비 완료',
                  value: hasActiveAlarm
                      ? HomeFormatters.formatClockTime(
                          alarmTime.add(Duration(minutes: prepTimeMinutes)),
                        )
                      : '설정 필요',
                  icon: Icons.check_circle_outline_rounded,
                  tint: const Color(0xFF2563EB),
                ),
                const SizedBox(width: 12),
                MetricCard(
                  label: '여유 시간',
                  value: '$bufferMinutes분',
                  icon: Icons.coffee_rounded,
                  tint: const Color(0xFFEA580C),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const SectionTitle(
              title: '빠른 실행',
              subtitle: '하단 탭과 함께 자주 쓰는 화면으로도 빠르게 이동할 수 있어요.',
            ),
            const SizedBox(height: 16),
            QuickActionCard(
              title: '알람 탭 열기',
              subtitle: '등록된 알람과 반복 루틴을 한 번에 확인해보세요.',
              icon: Icons.add_alarm_rounded,
              color: const Color(0xFF2563EB),
              onTap: onOpenAlarmTab,
            ),
            const SizedBox(height: 12),
            QuickActionCard(
              title: '설정 탭 열기',
              subtitle: '준비 시간, 알림, 계정 관련 화면으로 이동해요.',
              icon: Icons.settings_suggest_rounded,
              color: const Color(0xFF0F766E),
              onTap: onOpenSettingsTab,
            ),
            const SizedBox(height: 12),
            QuickActionCard(
              title: '나가기 전 체크리스트',
              subtitle: '지갑, 이어폰, 과제까지 한 번에 확인해요.',
              icon: Icons.fact_check_outlined,
              color: const Color(0xFFEA580C),
              onTap: () => onComingSoon('나가기 전 체크리스트'),
            ),
            const SizedBox(height: 28),
            const SectionTitle(
              title: '등록된 알람',
              subtitle: '반복 루틴과 특별 일정용 알람을 한눈에 볼 수 있어요.',
            ),
            const SizedBox(height: 16),
            if (visibleAlarms.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '알람을 아직 추가하지 않았어요',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '알람 탭에서 학교, 운동, 주말 외출 루틴을 각각 만들어둘 수 있어요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...previewAlarms.asMap().entries.map((entry) {
                final index = entry.key;
                final alarm = entry.value;
                final nextOccurrence =
                    AlarmScheduleCalculator.buildNextOccurrence(
                      alarm: alarm,
                      now: now,
                    );
                final displayTime =
                    nextOccurrence?.triggerTime ??
                    AlarmScheduleCalculator.buildPreviewTriggerTime(alarm);

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == previewAlarms.length - 1 ? 0 : 12,
                  ),
                  child: AlarmTile(
                    accent: AlarmScheduleCalculator.buildAccent(index),
                    title: alarm.title,
                    time: HomeFormatters.formatClockTime(displayTime),
                    schedule: AlarmScheduleCalculator.buildRepeatLabel(
                      alarm.weekdays,
                    ),
                    note: AlarmScheduleCalculator.buildConfigurationLabel(
                      alarm,
                    ),
                    enabled: alarm.enabled,
                    onEnabledChanged: (value) {
                      onToggleAlarm(alarm.copyWith(enabled: value));
                    },
                  ),
                );
              }),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘의 한마디',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    originalPrepTimeMinutes == null
                        ? '아직 준비 시간이 확정되지 않았어요. 첫 설정만 마치면 더 정확한 알람을 맞춰드릴게요.'
                        : '${HomeFormatters.formatPrepTime(originalPrepTimeMinutes!)} 준비 루틴이면 충분히 여유 있게 나갈 수 있어요. 오늘도 차분하게 시작해봐요.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                      color: Color(0xFF7C2D12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onOpenAlarmTab,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        '알람 탭으로 이동',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
