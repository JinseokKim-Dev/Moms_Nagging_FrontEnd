import 'package:flutter/material.dart';

import 'alarm/alarm_logic.dart';
import 'alarm/alarm_storage.dart';
import 'core/auth/auth_token_storage.dart';
import 'home/home_logic.dart';
import 'home/home_tabs.dart';
import 'home/home_widgets.dart';
import 'login/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.prepTimeMinutes});

  final int? prepTimeMinutes;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AlarmStorage _alarmStorage = AlarmStorage();
  final AuthTokenStorage _tokenStorage = AuthTokenStorage();

  int _currentIndex = 0;
  List<AlarmRoutine> _alarms = const [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label 기능은 다음 단계에서 연결할 수 있어요.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadAlarms() async {
    final storedAlarms = await _alarmStorage.readAlarms();
    final initialPrepTimeMinutes = widget.prepTimeMinutes ?? 35;
    final alarms =
        storedAlarms ??
        [
          AlarmScheduleCalculator.buildDefault(
            prepTimeMinutes: initialPrepTimeMinutes,
          ),
        ];

    if (storedAlarms == null) {
      await _alarmStorage.saveAlarms(alarms);
    }

    if (!mounted) {
      return;
    }

    setState(() => _alarms = alarms);
  }

  Future<void> _saveAlarms(
    List<AlarmRoutine> alarms, {
    String? snackBarMessage,
  }) async {
    setState(() => _alarms = alarms);
    await _alarmStorage.saveAlarms(alarms);

    if (!mounted || snackBarMessage == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackBarMessage),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _upsertAlarm(AlarmRoutine alarm) async {
    debugPrint('[HomePage] Upsert alarm: ${alarm.toJson()}');

    final nextAlarms = [..._alarms];
    final existingIndex = nextAlarms.indexWhere((item) => item.id == alarm.id);

    if (existingIndex == -1) {
      nextAlarms.add(alarm);
      await _saveAlarms(
        nextAlarms,
        snackBarMessage: alarm.isClassSchedule
            ? '"${alarm.title}" 수업 알람을 저장했어요.'
            : '새 알람을 저장했어요.',
      );
      return;
    }

    nextAlarms[existingIndex] = alarm;
    await _saveAlarms(
      nextAlarms,
      snackBarMessage: '"${alarm.title}" 알람을 업데이트했어요.',
    );
  }

  Future<void> _deleteAlarm(AlarmRoutine alarm) async {
    debugPrint('[HomePage] Delete alarm: ${alarm.toJson()}');

    final nextAlarms = _alarms
        .where((item) => item.id != alarm.id)
        .toList(growable: false);

    await _saveAlarms(
      nextAlarms,
      snackBarMessage: '"${alarm.title}" 알람을 삭제했어요.',
    );
  }

  Future<void> _logout() async {
    await _tokenStorage.clearTokens();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fallbackPrepTimeMinutes = widget.prepTimeMinutes ?? 35;
    final nextOccurrence = AlarmScheduleCalculator.findNextOccurrence(
      alarms: _alarms,
      now: now,
    );
    final hasActiveAlarm = nextOccurrence != null;
    final targetLabel = nextOccurrence == null
        ? '외출 목표'
        : AlarmScheduleCalculator.buildTargetLabel(nextOccurrence.alarm);
    final prepTimeMinutes =
        nextOccurrence?.alarm.prepTimeMinutes ?? fallbackPrepTimeMinutes;
    final bufferMinutes = nextOccurrence?.alarm.bufferMinutes ?? 20;
    final departureTime =
        nextOccurrence?.departureTime ??
        HomeScheduleCalculator.buildNextDepartureTime(now);
    final alarmTime =
        nextOccurrence?.triggerTime ??
        HomeScheduleCalculator.buildAlarmTime(
          departureTime: departureTime,
          prepTimeMinutes: prepTimeMinutes,
          bufferMinutes: bufferMinutes,
        );
    final nextAlarmLabel = hasActiveAlarm
        ? HomeScheduleCalculator.buildNextAlarmLabel(
            now: now,
            alarmTime: alarmTime,
          )
        : '활성화된 알람이 없어요. 알람 탭에서 다시 켜거나 새로 추가해보세요.';
    final nextAlarmTitle = hasActiveAlarm
        ? '${nextOccurrence.alarm.title} · ${AlarmScheduleCalculator.buildRepeatLabel(nextOccurrence.alarm.weekdays)}'
        : _alarms.isEmpty
        ? '아직 등록된 알람이 없어요'
        : '모든 알람이 비활성화되어 있어요';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EC),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(
            now: now,
            prepTimeMinutes: prepTimeMinutes,
            departureTime: departureTime,
            targetLabel: targetLabel,
            alarmTime: alarmTime,
            nextAlarmLabel: nextAlarmLabel,
            nextAlarmTitle: nextAlarmTitle,
            hasActiveAlarm: hasActiveAlarm,
            bufferMinutes: bufferMinutes,
            alarms: _alarms,
            originalPrepTimeMinutes: widget.prepTimeMinutes,
            onOpenAlarmTab: () => setState(() => _currentIndex = 1),
            onToggleAlarm: (alarm) {
              _upsertAlarm(alarm);
            },
            onOpenSettingsTab: () => setState(() => _currentIndex = 2),
            onComingSoon: _showComingSoon,
          ),
          AlarmTab(
            alarms: _alarms,
            nextOccurrence: nextOccurrence,
            defaultPrepTimeMinutes: fallbackPrepTimeMinutes,
            onSaveAlarm: (alarm) {
              _upsertAlarm(alarm);
            },
            onDeleteAlarm: (alarm) {
              _deleteAlarm(alarm);
            },
            onComingSoon: _showComingSoon,
          ),
          SettingsTab(
            prepTimeMinutes: prepTimeMinutes,
            onLogout: _logout,
            onComingSoon: _showComingSoon,
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
