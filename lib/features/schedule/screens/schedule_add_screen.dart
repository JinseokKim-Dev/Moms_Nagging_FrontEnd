import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../alarm/alarm_logic.dart';
import '../../home/home_logic.dart';
import '../../login/first_login_prep_time_logic.dart';
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _classNameController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _noteController;
  late final String _scheduleId;

  late Set<int> _selectedWeekdays;
  late TimeOfDay _classStartTime;

  String? _prepTimeError;
  bool _hasEditedPrepTime = false;

  @override
  void initState() {
    super.initState();
    _scheduleId = 'schedule_${DateTime.now().microsecondsSinceEpoch}';
    _classNameController = TextEditingController();
    _prepTimeController = TextEditingController(
      text: '${widget.defaultPrepTimeMinutes}',
    );
    _noteController = TextEditingController();
    _selectedWeekdays = {1, 2, 3, 4, 5};
    _classStartTime = const TimeOfDay(hour: 9, minute: 0);
    _prepTimeController.addListener(_handlePrepTimeChanged);
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _prepTimeController.removeListener(_handlePrepTimeChanged);
    _prepTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handlePrepTimeChanged() {
    final input = _prepTimeController.text.trim();
    final nextError = FirstLoginPrepTimeLogic.validatePrepTime(
      input,
      showEmptyMessage: _hasEditedPrepTime,
    );

    if (_prepTimeError == nextError) {
      return;
    }

    setState(() => _prepTimeError = nextError);
  }

  bool get _isPrepTimeValid {
    return FirstLoginPrepTimeLogic.isValidPrepTime(
      _prepTimeController.text.trim(),
    );
  }

  int get _resolvedPrepTimeMinutes {
    return FirstLoginPrepTimeLogic.parsePrepTime(
          _prepTimeController.text.trim(),
        ) ??
        widget.defaultPrepTimeMinutes;
  }

  ClassScheduleEntry _buildEntry() {
    return ClassScheduleEntry(
      id: _scheduleId,
      className: _classNameController.text.trim(),
      classStartHour: _classStartTime.hour,
      classStartMinute: _classStartTime.minute,
      weekdays: _selectedWeekdays.toList()..sort(),
      prepTimeMinutes: _resolvedPrepTimeMinutes,
      note: _noteController.text.trim(),
      enabled: true,
    );
  }

  Future<void> _pickClassStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _classStartTime,
      helpText: '수업 시작 시간',
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
    FocusScope.of(context).unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final prepTimeInput = _prepTimeController.text.trim();
    final prepTimeError = FirstLoginPrepTimeLogic.validatePrepTime(
      prepTimeInput,
      showEmptyMessage: true,
    );
    final prepTimeMinutes = FirstLoginPrepTimeLogic.parsePrepTime(
      prepTimeInput,
    );

    if (!isFormValid || prepTimeError != null || prepTimeMinutes == null) {
      setState(() {
        _hasEditedPrepTime = true;
        _prepTimeError = prepTimeError;
      });
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

    final entry = _buildEntry().copyWith(prepTimeMinutes: prepTimeMinutes);
    final preview = ScheduleAlarmPlanner.buildPreview(entry: entry);
    final alarm = entry.toAlarmRoutine();

    debugPrint('[ScheduleAddScreen] Save class schedule: ${entry.toJson()}');
    debugPrint(
      '[ScheduleAddScreen] Auto alarm created: '
      '${HomeFormatters.formatClockTime(preview.alarmTime)}',
    );

    Navigator.of(context).pop(alarm);
  }

  @override
  Widget build(BuildContext context) {
    final entry = _buildEntry();
    final preview = ScheduleAlarmPlanner.buildPreview(entry: entry);
    final exampleAlarmTime = HomeFormatters.formatClockTime(
      DateTime(2024, 1, 1, 9).subtract(const Duration(minutes: 30)),
    );
    final repeatLabel = entry.weekdays.isEmpty
        ? '요일 미선택'
        : AlarmScheduleCalculator.buildRepeatLabel(entry.weekdays);
    final previewTitle = entry.className.trim().isEmpty
        ? '수업 자동 알람'
        : entry.className.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text(
          '시간표 등록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.08),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.school_rounded,
                          size: 68,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          '수업 자동 알람 설정',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          '요일, 수업명, 시작 시간, 준비 시간을 입력하면 알람을 자동으로 계산해드려요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '자동 생성 알람 미리보기',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              HomeFormatters.formatClockTime(preview.alarmTime),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$previewTitle · $repeatLabel · 수업 시작 ${HomeFormatters.formatClockTime(preview.nextClassStart)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4B5563),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'prepTime ${AlarmScheduleCalculator.formatDuration(entry.prepTimeMinutes)} 기준으로 ${ScheduleAlarmPlanner.buildTimeUntilLabel(preview.timeUntilAlarm)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _classNameController,
                        textInputAction: TextInputAction.next,
                        decoration: _buildInputDecoration(
                          hintText: '수업명',
                          prefixIcon: Icons.menu_book_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '수업명을 입력해주세요.';
                          }

                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickClassStartTime,
                        borderRadius: BorderRadius.circular(14),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule_rounded),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '수업 시작 시간',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 13,
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
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '수업 요일',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
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
                              final selected = _selectedWeekdays.contains(
                                weekday,
                              );

                              return FilterChip(
                                label: Text(label),
                                selected: selected,
                                onSelected: (_) => _toggleWeekday(weekday),
                                selectedColor: const Color(0xFFE0E7FF),
                                checkmarkColor: Colors.deepPurple,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? Colors.deepPurple
                                      : const Color(0xFF374151),
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '준비 시간',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _prepTimeController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                const MaxPrepTimeInputFormatter(),
                              ],
                              decoration: _buildInputDecoration(
                                hintText: '준비 시간',
                                prefixIcon: Icons.alarm_rounded,
                                errorText: _prepTimeError,
                              ),
                              onChanged: (_) {
                                if (_hasEditedPrepTime) {
                                  setState(() {});
                                  return;
                                }

                                setState(() {
                                  _hasEditedPrepTime = true;
                                });
                              },
                              onFieldSubmitted: (_) {
                                if (_isPrepTimeValid) {
                                  _save();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text(
                              '분',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: FirstLoginPrepTimeLogic.quickSelectMinutes
                            .map((minutes) {
                              final isSelected =
                                  _prepTimeController.text.trim() == '$minutes';

                              return OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _hasEditedPrepTime = true;
                                    _prepTimeController.text = '$minutes';
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? const Color(0xFFE0E7FF)
                                      : Colors.white,
                                  foregroundColor: isSelected
                                      ? Colors.deepPurple
                                      : const Color(0xFF374151),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.deepPurple
                                        : const Color(0xFFD1D5DB),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text('$minutes분'),
                              );
                            })
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: _buildInputDecoration(
                          hintText: '메모 (선택)',
                          prefixIcon: Icons.edit_note_rounded,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '예시: 월요일 / 자료구조 / 09:00 / prepTime 30분이면 월요일 $exampleAlarmTime 알람이 생성돼요.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF92400E),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isPrepTimeValid ? _save : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '자동 알람 생성',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      prefixIcon: Icon(prefixIcon),
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
    );
  }
}
