import 'package:flutter/material.dart';

import '../../alarm/alarm_logic.dart';
import '../../alarm/widgets/alarm_editor_sheet.dart';
import '../../schedule/screens/schedule_add_screen.dart';
import '../home_logic.dart';
import '../home_widgets.dart';

class AlarmTab extends StatelessWidget {
  const AlarmTab({
    super.key,
    required this.alarms,
    required this.nextOccurrence,
    required this.defaultPrepTimeMinutes,
    required this.onSaveAlarm,
    required this.onDeleteAlarm,
    required this.onComingSoon,
  });

  final List<AlarmRoutine> alarms;
  final AlarmOccurrence? nextOccurrence;
  final int defaultPrepTimeMinutes;
  final ValueChanged<AlarmRoutine> onSaveAlarm;
  final ValueChanged<AlarmRoutine> onDeleteAlarm;
  final ValueChanged<String> onComingSoon;

  Future<void> _openEditor(
    BuildContext context, {
    AlarmRoutine? initialAlarm,
  }) async {
    final result = await showModalBottomSheet<AlarmRoutine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AlarmEditorSheet(
        defaultPrepTimeMinutes: defaultPrepTimeMinutes,
        initialAlarm: initialAlarm,
      ),
    );

    if (result != null) {
      onSaveAlarm(result);
    }
  }

  Future<void> _confirmDelete(BuildContext context, AlarmRoutine alarm) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('알람 삭제'),
          content: Text('"${alarm.title}" 알람을 목록에서 지울까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      onDeleteAlarm(alarm);
    }
  }

  Future<void> _openScheduleBuilder(BuildContext context) async {
    final result = await Navigator.of(context).push<AlarmRoutine>(
      MaterialPageRoute(
        builder: (_) =>
            ScheduleAddScreen(defaultPrepTimeMinutes: defaultPrepTimeMinutes),
      ),
    );

    if (result != null) {
      onSaveAlarm(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final activeCount = alarms.where((alarm) => alarm.enabled).length;
    final sortedAlarms = [...alarms]
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

    return GradientPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: SectionTitle(
                    title: '알람 관리',
                    subtitle: '반복 루틴과 특별 일정 알람을 한곳에서 볼 수 있어요.',
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _openEditor(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('추가'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF153A5B),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '다음 알람까지',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD6E4F0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (nextOccurrence != null)
                    Text(
                      HomeFormatters.formatClockTime(
                        nextOccurrence!.triggerTime,
                      ),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Text(
                      '알람 없음',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    nextOccurrence == null
                        ? '활성화된 알람이 없어요. 새 알람을 만들거나 기존 알람을 켜보세요.'
                        : '${nextOccurrence!.alarm.title} · ${AlarmScheduleCalculator.buildRepeatLabel(nextOccurrence!.alarm.weekdays)} · 외출 목표 ${HomeFormatters.formatClockTime(nextOccurrence!.departureTime)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFD6E4F0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '전체 ${alarms.length}개 중 $activeCount개가 활성화되어 있어요.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFD6E4F0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (sortedAlarms.isEmpty)
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
                      '아직 등록된 알람이 없어요',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '외출 시간과 준비 루틴만 정하면 바로 다음 알람 시간을 계산해드릴게요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _openEditor(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.add_alarm_rounded),
                      label: const Text('첫 알람 만들기'),
                    ),
                  ],
                ),
              )
            else
              ...sortedAlarms.asMap().entries.map((entry) {
                final index = entry.key;
                final alarm = entry.value;
                final tileTime =
                    AlarmScheduleCalculator.buildNextOccurrence(
                      alarm: alarm,
                      now: now,
                    )?.triggerTime ??
                    AlarmScheduleCalculator.buildPreviewTriggerTime(alarm);

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == sortedAlarms.length - 1 ? 0 : 12,
                  ),
                  child: AlarmTile(
                    accent: AlarmScheduleCalculator.buildAccent(index),
                    title: alarm.title,
                    time: HomeFormatters.formatClockTime(tileTime),
                    schedule: AlarmScheduleCalculator.buildRepeatLabel(
                      alarm.weekdays,
                    ),
                    note: AlarmScheduleCalculator.buildConfigurationLabel(
                      alarm,
                    ),
                    enabled: alarm.enabled,
                    onEnabledChanged: (value) {
                      onSaveAlarm(alarm.copyWith(enabled: value));
                    },
                    onEdit: () => _openEditor(context, initialAlarm: alarm),
                    onDelete: () => _confirmDelete(context, alarm),
                  ),
                );
              }),
            const SizedBox(height: 24),
            QuickActionCard(
              title: '시간표 등록',
              subtitle: '첫 수업 시간과 통학 시간을 넣으면 자동 알람을 만들 수 있어요.',
              icon: Icons.school_rounded,
              color: const Color(0xFF2563EB),
              onTap: () => _openScheduleBuilder(context),
            ),
            const SizedBox(height: 12),
            QuickActionCard(
              title: '실시간 버스/환승 연동',
              subtitle: '다음 단계에서 버스 도착 예정과 환승 시간 API를 붙일 수 있어요.',
              icon: Icons.directions_bus_rounded,
              color: const Color(0xFF0F766E),
              onTap: () => onComingSoon('실시간 버스/환승 연동'),
            ),
          ],
        ),
      ),
    );
  }
}
