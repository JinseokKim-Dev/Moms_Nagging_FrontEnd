import 'package:flutter/material.dart';

import '../../alarm/alarm_logic.dart';
import '../../home/home_logic.dart';
import '../schedule_logic.dart';

class ScheduleAddScreen extends StatefulWidget {
  const ScheduleAddScreen({super.key, required this.defaultPrepTimeMinutes});

  final int defaultPrepTimeMinutes;

  @override
  State<ScheduleAddScreen> createState() => _ScheduleAddScreenState();
}

class _ScheduleAddScreenState extends State<ScheduleAddScreen> {
  static const List<(int, String)> _weekdayOptions = [
    (1, '월'),
    (2, '화'),
    (3, '수'),
    (4, '목'),
    (5, '금'),
    (6, '토'),
    (7, '일'),
  ];
  static const List<String> _originOptions = ['집', '친구집', '기숙사', '직접 입력'];
  static const List<int> _minuteOptions = [
    0,
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    60,
  ];
  static const List<int> _arrivalBufferOptions = [0, 5, 10, 15, 20];
  static const List<int> _leaveBufferOptions = [0, 5, 10, 15, 20];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _courseController;
  late final TextEditingController _destinationController;
  late final TextEditingController _originCustomController;
  late final TextEditingController _noteController;

  late Set<int> _selectedWeekdays;
  late TimeOfDay _classStartTime;
  String _selectedOrigin = '집';
  int _walkMinutes = 10;
  int _waitMinutes = 5;
  int _busRideMinutes = 25;
  int _transferMinutes = 5;
  int _arrivalBufferMinutes = 10;
  int _leaveBufferMinutes = 10;

  @override
  void initState() {
    super.initState();
    _courseController = TextEditingController();
    _destinationController = TextEditingController();
    _originCustomController = TextEditingController();
    _noteController = TextEditingController();
    _selectedWeekdays = {1, 2, 3, 4, 5};
    _classStartTime = const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  void dispose() {
    _courseController.dispose();
    _destinationController.dispose();
    _originCustomController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _originLabel {
    if (_selectedOrigin == '직접 입력') {
      return _originCustomController.text.trim();
    }

    return _selectedOrigin;
  }

  TimetableAlarmDraft _buildDraft() {
    final originLabel = _originLabel.isEmpty ? '집' : _originLabel;

    return TimetableAlarmDraft(
      courseTitle: _courseController.text.trim(),
      originLabel: originLabel,
      destinationLabel: _destinationController.text.trim(),
      classStartHour: _classStartTime.hour,
      classStartMinute: _classStartTime.minute,
      weekdays: _selectedWeekdays.toList()..sort(),
      leaveBufferMinutes: _leaveBufferMinutes,
      commute: CommuteBreakdown(
        walkMinutes: _walkMinutes,
        waitMinutes: _waitMinutes,
        busRideMinutes: _busRideMinutes,
        transferMinutes: _transferMinutes,
        arrivalBufferMinutes: _arrivalBufferMinutes,
      ),
      note: _noteController.text.trim(),
    );
  }

  Future<void> _pickClassStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _classStartTime,
      helpText: '첫 수업 시작 시간',
    );

    if (picked == null) {
      return;
    }

    setState(() => _classStartTime = picked);
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
          content: Text('수업이 있는 요일을 최소 한 개 선택해주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final draft = _buildDraft();
    final alarm = draft.toAlarmRoutine(
      prepTimeMinutes: widget.defaultPrepTimeMinutes,
    );

    Navigator.of(context).pop(alarm);
  }

  @override
  Widget build(BuildContext context) {
    final draft = _buildDraft();
    final preview = ScheduleAlarmPlanner.buildPreview(
      draft: draft,
      prepTimeMinutes: widget.defaultPrepTimeMinutes,
    );
    final canShowOriginField = _selectedOrigin == '직접 입력';
    final repeatLabel = draft.weekdays.isEmpty
        ? '요일 미선택'
        : AlarmScheduleCalculator.buildRepeatLabel(draft.weekdays);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F3EC),
        elevation: 0,
        title: const Text(
          '시간표 등록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF153A5B), Color(0xFF285780)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '첫 수업 자동 알람 미리보기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD6E4F0),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        HomeFormatters.formatClockTime(preview.alarmTime),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '첫 수업 ${HomeFormatters.formatClockTime(preview.nextClassStart)} · ${_originLabel.isEmpty ? '집' : _originLabel} 출발 · ${ScheduleAlarmPlanner.buildSlackLabel(preview.departureSlack)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFD6E4F0),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _PreviewPill(
                            label:
                                '출발 ${HomeFormatters.formatClockTime(preview.departureTime)}',
                          ),
                          _PreviewPill(
                            label: '총 이동 ${draft.commute.totalMinutes}분',
                          ),
                          _PreviewPill(label: '알람 $repeatLabel'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '기본 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _courseController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '수업 이름',
                    hintText: '예: 자료구조, 선형대수',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '수업 이름을 입력해주세요.';
                    }

                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _destinationController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '도착 위치',
                    hintText: '예: 공학관 301호, 본관 2층',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '도착 위치를 입력해주세요.';
                    }

                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                const Text(
                  '출발 위치',
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
                  children: _originOptions
                      .map((origin) {
                        return ChoiceChip(
                          label: Text(origin),
                          selected: _selectedOrigin == origin,
                          onSelected: (_) {
                            setState(() => _selectedOrigin = origin);
                          },
                        );
                      })
                      .toList(growable: false),
                ),
                if (canShowOriginField) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _originCustomController,
                    decoration: const InputDecoration(
                      labelText: '직접 입력한 출발 위치',
                      hintText: '예: 자취방, 도서관',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (!canShowOriginField) {
                        return null;
                      }

                      if (value == null || value.trim().isEmpty) {
                        return '출발 위치를 입력해주세요.';
                      }

                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  '수업 시간',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickClassStartTime,
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                '첫 수업 시작 시간',
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
                                    _classStartTime.hour,
                                    _classStartTime.minute,
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                const Text(
                  '통학 예상 시간',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '지금은 수동 입력으로 계산하고, 다음 단계에서 버스 도착 예정과 환승 API를 자동으로 연결할 수 있게 만들 거예요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                _MinuteDropdownRow(
                  label: '정류장/역까지 도보',
                  value: _walkMinutes,
                  options: _minuteOptions,
                  onChanged: (value) {
                    setState(() => _walkMinutes = value);
                  },
                ),
                const SizedBox(height: 12),
                _MinuteDropdownRow(
                  label: '버스 도착 대기',
                  value: _waitMinutes,
                  options: _minuteOptions,
                  onChanged: (value) {
                    setState(() => _waitMinutes = value);
                  },
                ),
                const SizedBox(height: 12),
                _MinuteDropdownRow(
                  label: '버스/지하철 이동',
                  value: _busRideMinutes,
                  options: _minuteOptions,
                  onChanged: (value) {
                    setState(() => _busRideMinutes = value);
                  },
                ),
                const SizedBox(height: 12),
                _MinuteDropdownRow(
                  label: '환승/하차 후 이동',
                  value: _transferMinutes,
                  options: _minuteOptions,
                  onChanged: (value) {
                    setState(() => _transferMinutes = value);
                  },
                ),
                const SizedBox(height: 12),
                _MinuteDropdownRow(
                  label: '강의실 도착 여유',
                  value: _arrivalBufferMinutes,
                  options: _arrivalBufferOptions,
                  onChanged: (value) {
                    setState(() => _arrivalBufferMinutes = value);
                  },
                ),
                const SizedBox(height: 12),
                _MinuteDropdownRow(
                  label: '출발 전 추가 여유',
                  value: _leaveBufferMinutes,
                  options: _leaveBufferOptions,
                  onChanged: (value) {
                    setState(() => _leaveBufferMinutes = value);
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Text(
                    '현재 설정 준비 시간은 ${AlarmScheduleCalculator.formatDuration(widget.defaultPrepTimeMinutes)}이에요. 이 시간을 기준으로 자동 알람을 만들고 있어요.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9A3412),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '메모',
                    hintText: '예: 비 오는 날엔 10분 더 필요, 2번 출구 이용',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text(
                      '자동 알람 만들기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MinuteDropdownRow extends StatelessWidget {
  const _MinuteDropdownRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 132,
          child: DropdownButtonFormField<int>(
            initialValue: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: options
                .map((minutes) {
                  return DropdownMenuItem<int>(
                    value: minutes,
                    child: Text('$minutes분'),
                  );
                })
                .toList(growable: false),
            onChanged: (selected) {
              if (selected != null) {
                onChanged(selected);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
