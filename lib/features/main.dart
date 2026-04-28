import 'package:flutter/material.dart';
import './login/first_login_prep_time_page.dart';
import './login/login.dart';

// main 함수는 Flutter 앱의 시작점(entry point)이다.
// runApp이 실제로 화면에 표시할 최상위 위젯을 실행한다.
void main() {
  runApp(const MyApp());
}

// MyApp은 앱 전체 공통 설정을 담는 루트 위젯이다.
// 보통 MaterialApp, Theme, 첫 화면(home) 같은 설정이 여기 들어간다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 우측 상단 DEBUG 배너 숨김
      debugShowCheckedModeBanner: false,

      // 앱 이름. 운영체제나 일부 화면 전환 정보에 사용될 수 있다.
      title: 'Mom Nagging',

      // 앱 전체 기본 테마
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // 앱이 처음 열릴 때 보여줄 첫 화면
      // 지금은 준비 시간 설정 페이지로 연결되어 있다.
      home: const FirstLoginPrepTimePage(),
    );
  }
}
