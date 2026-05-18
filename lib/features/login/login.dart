import 'package:flutter/material.dart';
import 'first_login_prep_time_page.dart';
import 'login_service.dart';
import 'login_validator_definition.dart';
import '../home.dart';
import '../signup/signup.dart';

/*
======================
**로그인 페이지 Class**
======================
*/
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/*
======================
**   로그인 Class   **
======================
*/
class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginService loginService = LoginService();
  bool isPasswordHidden = true;
  bool isLoading = false;
  // 이메일, 비밀번호 입력할 때 받아주는 역할을 하는 컨테이너 설정
  // 위젯에서 사용할 bool 변수이고 패스워드를 가릴지 말지와 로딩 표시 할지 말지 설정

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    loginService.dispose();
    super.dispose();
  } // 위젯이 새로고침이나 다른 페이지 이동으로 인해 사라질 때 위젯 내의 값들 전부 반환

  void showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  } // 스낵바에 대한 설정이고 스낵바는 아래 하단에 나오는 바

  /*
    =======================================
    **        Future<void> login()       **
    **login_validator_definition 코드 참고**
    **          59 ~ 75 라인              **
    =======================================
    */
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final validationError = LoginValidator.validate(
      email: email,
      password: password,
    );
    // 벨리데이션 에러 통과 못한다면 스낵바 띄워서 경고 표시
    if (validationError != null) {
      showSnackBar(
        LoginValidator.message(validationError),
        backgroundColor: validationError == LoginValidationError.invalidEmail
            ? Colors.orange
            : Colors.red,
      );
      return;
    }
    /*
    =======================================
    **        Future<void> login()       **
    **login_validator_definition 코드 참고**
    =======================================
    */
    /*
    ===================================
    **    login_service 코드 참고    **
    ===================================
    */
    setState(() => isLoading = true);
    try {
      final result = await loginService.login(
        email: email,
        password: password,
      ); // 로그인 서비스 호출하고 결과 받아올 때 까지 대기
      if (!mounted) return;
      if (result.isSuccess) {
        debugPrint('로그인 성공');
        debugPrint('GrantType: ${result.grantType}');
        debugPrint('AccessTokenExpiresIn: ${result.accessTokenExpiresIn}');

        showSnackBar(result.message, backgroundColor: Colors.green);

        final nextPage = result.isFirstLogin
            ? const FirstLoginPrepTimePage()
            : const HomePage();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextPage),
        );

        return;
      }

      showSnackBar(result.message);

      if (result.reasonPhrase != null) {
        debugPrint('Error: ${result.reasonPhrase}');
      }

      if (result.error != null) {
        debugPrint('Exception: ${result.error}');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  } // 로그인 버튼을 눌렀을 때 실행되는 함수, 입력값 검증, 로그인 요청, 결과 처리, 다음 화면 이동 등을 담당

  void findId() {
    showSnackBar('이메일 찾기 페이지로 이동...', backgroundColor: Colors.grey);
  }

  void findPassword() {
    showSnackBar('PW 찾기 페이지로 이동...', backgroundColor: Colors.grey);
  }

  void signUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  @override // 신경 안써도 됨 그냥 위젯들
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        // Center + SingleChildScrollView 조합은
        // 작은 화면에서도 스크롤 가능하면서 내용을 가운데 정렬하기 좋다.
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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

                // Column은 아이콘, 텍스트, 입력창, 버튼을 세로로 쌓는다.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 72,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '이메일과 비밀번호를 입력하세요',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: emailController,

                      // 이메일 입력에 맞는 키보드를 요청
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,

                      // obscureText가 true면 비밀번호 문자가 가려진다.
                      obscureText: isPasswordHidden,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            // 눈 아이콘을 누르면 비밀번호 표시 여부를 토글
                            setState(
                              () => isPasswordHidden = !isPasswordHidden,
                            );
                          },
                          icon: Icon(
                            isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: findId,
                          child: const Text('이메일 찾기'),
                        ),
                        const Text('|'),
                        TextButton(
                          onPressed: findPassword,
                          child: const Text('PW 찾기'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        // 로딩 중에는 중복 요청 방지를 위해 버튼을 비활성화한다.
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                '로그인',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('계정이 없으신가요?'),

                        // TextButton은 강조가 약한 텍스트형 버튼이다.
                        TextButton(
                          onPressed: signUp,
                          child: const Text('회원가입'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
