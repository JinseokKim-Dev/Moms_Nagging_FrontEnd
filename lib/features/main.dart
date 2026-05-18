import 'package:flutter/material.dart';
import 'core/auth/auth_token_storage.dart';
import './home.dart';
import './login/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
} // 앱 시작 부분

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
      home: AuthGate(tokenStorage: AuthTokenStorage()),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.tokenStorage});

  final AuthTokenStorage tokenStorage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: tokenStorage.hasActiveSession(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}

//API 테스트 실행 방법 -> 아래 명령어 터미널로 실행
//flutter run -d chrome \--dart-define=API_BASE_URL=http://127.0.0.1:3658/m1/1278134-1276435-default

//회원 가입 후 첫 로그인 페이지를 확인하고 싶으면 아래 import 추가 하고

//import './login/first_login_prep_time_page.dart';
