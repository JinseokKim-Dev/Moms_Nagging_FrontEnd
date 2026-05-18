import 'package:flutter/services.dart';

/*
=================================
**FirstLoginPrepTimeLogic Class**
=================================
*/
class FirstLoginPrepTimeLogic {
  static const int minMinutes = 1;
  static const int maxMinutes = 180;
  static const List<int> quickSelectMinutes = [10, 20, 30, 40, 60, 90];
  static String? validatePrepTime(
    String input, {
    bool showEmptyMessage = true,
  }) {
    if (input.isEmpty) {
      return showEmptyMessage ? '준비 시간을 입력해주세요.' : null;
    }

    final minutes = int.tryParse(input);

    if (minutes == null) {
      return '숫자만 입력해주세요.';
    }

    // 최소값 검사
    if (minutes < minMinutes) {
      return '1분 이상 입력해주세요.';
    }

    // 최대값 검사
    if (minutes > maxMinutes) {
      return '180분 이하로 입력해주세요.';
    }

    // 모든 규칙을 통과하면 에러 없음
    return null;
  }

  // 버튼 노출 여부처럼 true / false만 필요할 때 읽기 쉽게 만든 helper다.
  // 내부적으로는 validatePrepTime을 재사용한다.
  static bool isValidPrepTime(String input) {
    return input.isNotEmpty && validatePrepTime(input) == null;
  }

  static int? parsePrepTime(String input) {
    if (validatePrepTime(input, showEmptyMessage: true) != null) {
      return null;
    }

    return int.tryParse(input);
  }
}

/*
=================================
**MaxPrepTimeInputFormatter Class**
=================================
*/
class MaxPrepTimeInputFormatter extends TextInputFormatter {
  const MaxPrepTimeInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final input = newValue.text;

    if (input.isEmpty) {
      return newValue;
    }

    final minutes = int.tryParse(input);

    // 최대값 이하면 사용자가 입력한 값을 그대로 통과시킨다.
    if (minutes != null && minutes <= FirstLoginPrepTimeLogic.maxMinutes) {
      return newValue;
    }

    return const TextEditingValue(
      text: '180',
      selection: TextSelection.collapsed(offset: 3),
      composing: TextRange.empty,
    );
  }
}
