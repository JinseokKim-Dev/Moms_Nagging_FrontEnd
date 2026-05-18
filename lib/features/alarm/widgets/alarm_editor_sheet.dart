import 'package:flutter/material.dart';

import '../../home/home_logic.dart';
import '../alarm_logic.dart';

class AlarmEditorSheet extends StatefulWidget {
  const AlarmEditorSheet({
    super.key,
    required this.defaultPrepTimeMinutes,
    this.initialAlarm,
  });

  final int defaultPrepTimeMinutes;
  final AlarmRoutine? initialAlarm;

  @override
  State<AlarmEditorSheet> createState() => _AlarmEditorSheetState();
}

class _AlarmEditorSheetState extends State<AlarmEditorSheet> {
  static const List<int> _prepTimeOptions = [10, 20, 30, 35, 45, 60, 75, 90];
  static const List<int> _bufferOptions = [0, 10, 15, 20, 30];
  static const List<(int, String)> _weekdayOptions = [
    (1, '월'),
    (2, '화'),
    (3, '수'),
    (4, '목'),
    (5, '금'),
    (6, '토'),
    (7, '일'),
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late TimeOfDay _departureTime;
  late int _prepTimeMinutes;
  late int _bufferMinutes;
  late Set<int> _selectedWeekdays;
  late bool _enabled;

  bool get _isEditing => widget.initialAlarm != null;

  @override
  void initState() {
    super.initState();
    final initialAlarm = widget.initialAlarm;

    _titleController = TextEditingController(text: initialAlarm?.title ?? '');
    _noteController = TextEditingController(text: initialAlarm?.note ?? '');
    _departureTime = TimeOfDay(
      hour: initialAlarm?.departureHour ?? 8,
      minute: initialAlarm?.departureMinute ?? 30,
    );
    _prepTimeMinutes =
        initialAlarm?.prepTimeMinutes ?? widget.defaultPrepTimeMinutes;
    _bufferMinutes = initialAlarm?.bufferMinutes ?? 20;
    _selectedWeekdays = {
      ...(initialAlarm?.weekdays ?? AlarmScheduleCalculator.weekdaySchoolDays),
    };
    _enabled = initialAlarm?.enabled ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDepartureTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _departureTime,
      helpText: '외출 목표 시간',
    );

    if (picked == null) {
      return;
    }

    setState(() => _departureTime = picked);
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_selectedWeekdays.contains(weekday)) {
        _selectedWeekdays.remove(weekday);
      } else {
        _selectedWeekdays.add(weekday);
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('반복할 요일을 최소 한 개 선택해주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final normalizedWeekdays = _selectedWeekdays.toList()..sort();

    Navigator.of(context).pop(
      AlarmRoutine(
        id:
            widget.initialAlarm?.id ??
            'alarm_${DateTime.now().microsecondsSinceEpoch}',
        title: _titleController.text.trim(),
        departureHour: _departureTime.hour,
        departureMinute: _departureTime.minute,
        prepTimeMinutes: _prepTimeMinutes,
        bufferMinutes: _bufferMinutes,
        weekdays: normalizedWeekdays,
        note: _noteController.text.trim(),
        enabled: _enabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final departurePreview = DateTime(
      2024,
      1,
      2,
      _departureTime.hour,
      _departureTime.minute,
    );
    final alarmPreview = departurePreview.subtract(
      Duration(minutes: _prepTimeMinutes + _bufferMinutes),
    );
    final opensPreviousDay = alarmPreview.day != departurePreview.day;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEditing ? '알람 수정' : '알람 추가',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '외출 목표 시간과 준비 루틴을 기준으로 알람을 계산해요.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF153A5B),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '예상 기상 알람',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD6E4F0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          HomeFormatters.formatClockTime(alarmPreview),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${HomeFormatters.formatClockTime(departurePreview)} 외출 목표 · ${AlarmScheduleCalculator.formatDuration(_prepTimeMinutes)} 준비 · ${AlarmScheduleCalculator.formatDuration(_bufferMinutes)} 여유${opensPreviousDay ? ' · 전날 알람' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFD6E4F0),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: '알람 이름',
                      hintText: '예: 평일 등교 알람',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '알람 이름을 입력해주세요.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDepartureTime,
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '외출 목표 시간',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  HomeFormatters.formatClockTime(
                                    DateTime(
                                      2024,
                                      1,
                                      2,
                                      _departureTime.hour,
                                      _departureTime.minute,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '준비 시간',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _prepTimeOptions
                        .map((minutes) {
                          return ChoiceChip(
                            label: Text(
                              AlarmScheduleCalculator.formatDuration(minutes),
                            ),
                            selected: _prepTimeMinutes == minutes,
                            onSelected: (_) {
                              setState(() => _prepTimeMinutes = minutes);
                            },
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '여유 시간',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bufferOptions
                        .map((minutes) {
                          final label = minutes == 0
                              ? '바로 출발'
                              : '${AlarmScheduleCalculator.formatDuration(minutes)} 여유';

                          return ChoiceChip(
                            label: Text(label),
                            selected: _bufferMinutes == minutes,
                            onSelected: (_) {
                              setState(() => _bufferMinutes = minutes);
                            },
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '반복 요일',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _weekdayOptions
                        .map((option) {
                          final weekday = option.$1;
                          final label = option.$2;

                          return FilterChip(
                            label: Text(label),
                            selected: _selectedWeekdays.contains(weekday),
                            onSelected: (_) => _toggleWeekday(weekday),
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '메모',
                      hintText: '예: 체육복 챙기기, 발표 자료 확인',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _enabled,
                    onChanged: (value) => setState(() => _enabled = value),
                    title: const Text(
                      '저장 후 바로 활성화',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('끄면 목록에는 남고 다음 알람 계산에서는 제외돼요.'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFEA580C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(_isEditing ? '수정 완료' : '알람 저장'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
