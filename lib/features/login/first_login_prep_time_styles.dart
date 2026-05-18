import 'package:flutter/material.dart';

/*
==================================
**FirstLoginPrepTimeStyles Class**
==================================
*/
// static const Color abc 이게 -> static const int a 이런 느낌
class FirstLoginPrepTimeStyles {
  // 화면 전체 배경색
  static const Color pageBackgroundColor = Color(0xFF080808);

  // 카드 컨테이너 배경색
  static const Color cardBackgroundColor = Color(0xFF101010);

  // 에러 메시지와 에러 테두리에 쓰는 색
  static const Color errorColor = Color(0xFFFF8A80);

  // 화면 가장 바깥 여백
  static const EdgeInsets pagePadding = EdgeInsets.all(20);

  // 카드 안쪽 여백
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 28,
  );

  // 상단 배지("첫 로그인 설정") 내부 여백
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  // 입력창 내부 글자 여백
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 20,
  );

  // 빠른 선택 버튼 내부 여백
  static const EdgeInsets quickSelectPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  // 배지 텍스트 스타일
  static const TextStyle badgeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // 큰 제목 텍스트 스타일
  static const TextStyle titleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  // 입력창 안의 숫자 텍스트 스타일
  static const TextStyle inputTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  // "분" 단위 텍스트 스타일
  static const TextStyle unitTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  // 에러 메시지 텍스트 스타일
  static const TextStyle errorTextStyle = TextStyle(
    color: errorColor,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // 다음 버튼 안의 글자 스타일
  static const TextStyle nextButtonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  // 카드 전체에 적용되는 큰 박스 장식
  // borderRadius는 모서리 둥글기, border는 테두리다.
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackgroundColor,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
  );

  // 상단 배지 장식
  static final BoxDecoration badgeDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(999),
    color: Colors.white.withValues(alpha: 0.08),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
  );

  // 설명 문구 스타일은 withValues를 써서 투명도를 적용해야 하므로
  // const 대신 메서드로 만들어 필요할 때 생성한다.
  static TextStyle descriptionTextStyle() {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.72),
      fontSize: 15,
      height: 1.5,
    );
  }

  // 입력창 placeholder(hint) 글자 스타일
  static TextStyle hintTextStyle() {
    return TextStyle(color: Colors.white.withValues(alpha: 0.32));
  }

  // 다음 버튼이 아직 안 보일 때 대신 보여주는 안내 문구 스타일
  static TextStyle nextHintTextStyle() {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.56),
      fontSize: 14,
      height: 1.5,
    );
  }

  // InputDecoration은 TextField의 외형 설정 묶음이다.
  // hintText, 테두리, 에러 메시지 스타일 등을 한 번에 관리할 수 있다.
  //
  // errorText는 상황에 따라 달라지는 값이라 파라미터로 받고,
  // 나머지 공통 스타일은 여기서 고정해 재사용한다.
  static InputDecoration prepTimeInputDecoration({String? errorText}) {
    return InputDecoration(
      hintText: '예: 30',
      hintStyle: hintTextStyle(),
      errorText: errorText,
      errorStyle: errorTextStyle,
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: inputContentPadding,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.65),
          width: 1.4,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: errorColor, width: 1.6),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: errorColor, width: 1.8),
      ),
    );
  }

  // 빠른 선택용 OutlinedButton 스타일
  static ButtonStyle quickSelectButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      padding: quickSelectPadding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  // 하단 "다음" 버튼용 ElevatedButton 스타일
  static ButtonStyle nextButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}
