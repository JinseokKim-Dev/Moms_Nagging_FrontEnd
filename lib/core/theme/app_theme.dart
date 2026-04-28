import 'package:flutter/material.dart';

// 앱 전체의 디자인 통일감을 주는 테마 설정 클래스입니다.
class AppTheme {
  // 엄마의 따뜻함을 상징하는 메인 오렌지색입니다.
  static const Color primaryColor = Colors.orange;

  // 앱 전체에 적용될 밝은 테마 데이터입니다.
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.orange,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // 버튼들의 기본 스타일을 미리 정의하여 팀원들이 공통으로 쓰게 합니다.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}