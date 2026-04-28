import 'package:flutter/material.dart';
import 'first_login_prep_time_page.dart';
import '../home.dart';
import 'login_service.dart';
import 'login_validator.dart';
import '../signup/signup.dart';

// 로그인 화면은 입력값, 로딩 상태, 비밀번호 표시 여부가 계속 바뀌므로
// StatefulWidget으로 만드는 것이 자연스럽다.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 각 입력창과 연결된 컨트롤러
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 서버 통신 전용 서비스 객체
  final LoginService loginService = LoginService();

  // 비밀번호 글자를 가릴지 여부
  bool isPasswordHidden = true;

  // 로그인 요청 중인지 여부
  bool isLoading = false;

  @override
  void dispose() {
    // 화면이 사라질 때 controller / service 자원을 정리한다.
    emailController.dispose();
    passwordController.dispose();
    loginService.dispose();
    super.dispose();
  }

  // Snackbar는 화면 하단에 잠깐 뜨는 메시지다.
  // 같은 형태를 여러 군데서 쓰므로 helper 메서드로 분리해 두었다.
  void showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 실제 로그인 처리 흐름
  Future<void> login() async {
    // trim()은 앞뒤 공백 제거
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 서버 요청 전에 로컬에서 먼저 유효성 검사
    final validationError = LoginValidator.validate(
      email: email,
      password: password,
    );

    if (validationError != null) {
      showSnackBar(
        LoginValidator.message(validationError),
        backgroundColor: validationError == LoginValidationError.invalidEmail
            ? Colors.orange
            : Colors.red,
      );
      return;
    }

    // setState를 호출하면 버튼이 비활성화되고 로딩 UI가 다시 그려진다.
    setState(() => isLoading = true);

    try {
      // await는 Future가 끝날 때까지 기다린다.
      final result = await loginService.login(email: email, password: password);

      // 비동기 작업 중 화면이 사라졌을 수 있으므로 mounted 체크를 한다.
      if (!mounted) return;

      if (result.isSuccess) {
        debugPrint('로그인 성공: ${result.data}');
        showSnackBar(result.message, backgroundColor: Colors.green);

        // 서버 응답을 보고 첫 로그인인지 판단해서
        // 준비 시간 설정 화면 또는 홈 화면으로 분기한다.
        final nextPage = _shouldShowPrepTimeSetup(result.data)
            ? const FirstLoginPrepTimePage()
            : const HomePage();

        // 로그인 화면을 다음 화면으로 교체
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
      // try 안에서 성공/실패/예외가 어떻게 끝나든 마지막에 실행된다.
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // 아직 기능이 없는 버튼이므로 안내 메시지만 띄운다.
  void findId() {
    showSnackBar('이메일 찾기 페이지로 이동...', backgroundColor: Colors.grey);
  }

  void findPassword() {
    showSnackBar('PW 찾기 페이지로 이동...', backgroundColor: Colors.grey);
  }

  // 회원가입 화면으로 이동
  void signUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  // 서버에서 내려준 로그인 결과를 보고
  // 준비 시간 설정을 먼저 해야 하는지 판단하는 helper다.
  //
  // dynamic / Map / bool / String 등 여러 타입이 섞여 들어올 수 있어서
  // 타입을 하나씩 확인하면서 안전하게 처리한다.
  bool _shouldShowPrepTimeSetup(dynamic data) {
    if (data is! Map) return false;

    final map = Map<String, dynamic>.from(data);
    final firstLoginValue = map['firstLogin'] ?? map['isFirstLogin'];

    // 서버가 bool로 내려준 경우
    if (firstLoginValue is bool) {
      return firstLoginValue;
    }

    // 서버가 문자열 "true"/"false"로 내려준 경우도 대응
    if (firstLoginValue is String) {
      final normalized = firstLoginValue.toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }

    final prepTimeValue =
        map['prepTime'] ?? map['preparationTime'] ?? map['readyTime'];

    if (prepTimeValue == null) return false;

    // 준비 시간이 0 이하라면 아직 설정하지 않은 것으로 판단
    if (prepTimeValue is num) {
      return prepTimeValue <= 0;
    }

    // 빈 문자열도 아직 설정 안 한 것으로 본다.
    if (prepTimeValue is String) {
      return prepTimeValue.trim().isEmpty;
    }

    return false;
  }

  @override
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
