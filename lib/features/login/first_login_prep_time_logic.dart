import 'package:flutter/services.dart';

// 이 파일은 준비 시간 입력과 관련된 "기능 규칙"을 모아둔 파일이다.
// 화면(UI) 코드에서 규칙을 직접 들고 있으면 build 메서드가 길어지고,
// 다른 화면에서 같은 규칙을 재사용하기도 어려워진다.
//
// 그래서 이 파일에는
// 1. 최소/최대 시간 같은 상수
// 2. 입력값 검증 함수
// 3. 문자열 -> 숫자 변환 함수
// 4. 입력 순간 값을 보정하는 formatter
// 를 모아 두었다.
class FirstLoginPrepTimeLogic {
  // 준비 시간의 최소 허용값
  static const int minMinutes = 1;

  // 준비 시간의 최대 허용값
  static const int maxMinutes = 180;

  // 사용자가 자주 누를 수 있는 빠른 선택 버튼 값들
  static const List<int> quickSelectMinutes = [10, 20, 30, 40, 60, 90];

  // String 형태의 입력값이 규칙에 맞는지 검사한다.
  //
  // 반환값 규칙:
  // - null: 유효한 값
  // - 문자열: 사용자에게 보여줄 에러 메시지
  //
  // showEmptyMessage는 빈 값일 때 바로 에러를 보여줄지 결정한다.
  // 첫 진입 직후에는 빈 값 경고를 숨기고 싶을 때 false로 둘 수 있다.
  static String? validatePrepTime(
    String input, {
    bool showEmptyMessage = true,
  }) {
    // 아직 아무것도 입력되지 않은 경우
    if (input.isEmpty) {
      return showEmptyMessage ? '준비 시간을 입력해주세요.' : null;
    }

    // 숫자로 바꿀 수 없는 문자열이면 null이 나온다.
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

  // 화면 코드에서는 "일단 파싱하고 또 검증하고..."를 반복하기 쉽다.
  // 이 helper는 검증을 먼저 통과한 값만 int로 바꿔서 넘겨준다.
  //
  // 즉, 이 함수가 null을 반환하면:
  // - 비어 있거나
  // - 숫자가 아니거나
  // - 범위를 벗어난 값이라는 뜻이다.
  static int? parsePrepTime(String input) {
    if (validatePrepTime(input, showEmptyMessage: true) != null) {
      return null;
    }

    return int.tryParse(input);
  }
}

// TextInputFormatter는 TextField에 값이 실제로 반영되기 "직전"에 개입하는 도구다.
// 사용자가 타이핑하거나 붙여넣는 새 값을 검사해서,
// 허용할지 / 수정할지 / 이전 값으로 되돌릴지를 결정할 수 있다.
//
// 여기서는 180을 넘는 숫자가 들어오면 아예 거부하지 않고
// 자동으로 180으로 보정하는 역할을 한다.
class MaxPrepTimeInputFormatter extends TextInputFormatter {
  const MaxPrepTimeInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    // oldValue: 변경 전 텍스트 상태
    TextEditingValue oldValue,
    // newValue: 사용자가 지금 입력해서 들어오려는 새 텍스트 상태
    TextEditingValue newValue,
  ) {
    final input = newValue.text;

    // 입력을 모두 지우는 동작은 허용한다.
    if (input.isEmpty) {
      return newValue;
    }

    final minutes = int.tryParse(input);

    // 최대값 이하면 사용자가 입력한 값을 그대로 통과시킨다.
    if (minutes != null && minutes <= FirstLoginPrepTimeLogic.maxMinutes) {
      return newValue;
    }

    // 180을 초과하면 텍스트를 강제로 180으로 바꾼다.
    // text만 바꾸면 커서 위치가 어색해질 수 있어서 selection도 함께 지정한다.
    // offset: 3 은 "180" 문자열 끝 위치를 의미한다.
    return const TextEditingValue(
      text: '180',
      selection: TextSelection.collapsed(offset: 3),
      composing: TextRange.empty,
    );
  }
}
