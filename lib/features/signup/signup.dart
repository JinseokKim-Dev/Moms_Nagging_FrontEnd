import 'package:flutter/material.dart';
import 'signup_service.dart';
import 'signup_validator.dart';

// 회원가입 화면도 입력값과 로딩 상태가 바뀌므로 StatefulWidget으로 작성한다.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 입력창별 컨트롤러
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // 회원가입 요청 전용 서비스
  final SignUpService signUpService = SignUpService();

  // 비밀번호 / 비밀번호 확인 표시 여부
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  // 회원가입 요청 진행 중 여부
  bool isLoading = false;

  @override
  void dispose() {
    // 사용한 컨트롤러와 서비스 정리
    nameController.dispose();
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    signUpService.dispose();
    super.dispose();
  }

  // 하단 알림 메시지 helper
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

  // 회원가입 처리 흐름
  Future<void> signUp() async {
    final name = nameController.text.trim();
    final nickname = nicknameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // 서버 요청 전 유효성 검사
    final validationError = SignUpValidator.validate(
      name: name,
      nickname: nickname,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (validationError != null) {
      showSnackBar(
        SignUpValidator.message(validationError),
        backgroundColor: validationError == SignUpValidationError.emptyFields
            ? Colors.red
            : Colors.orange,
      );
      return;
    }

    // 로딩 상태 반영
    setState(() => isLoading = true);

    try {
      final result = await signUpService.signUp(
        name: name,
        nickname: nickname,
        email: email,
        password: password,
      );

      // 비동기 요청 중 화면이 닫혔을 수 있으므로 체크
      if (!mounted) return;

      if (result.isSuccess) {
        debugPrint('회원가입 성공: ${result.data}');
        showSnackBar(result.message, backgroundColor: Colors.green);

        // 가입 완료 후 로그인 페이지로 이동
        Navigator.pop(context);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(

        // AppBar는 상단 제목 영역
        title: const Text('회원가입'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(

        // SingleChildScrollView를 써서 키보드가 올라오거나 작은 화면에서도 안 잘리게 한다.
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

                // 입력 요소들을 세로로 쌓는 영역
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 72,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '회원정보를 입력해주세요',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 32),

                    // 이름 (realname)
                    TextField(
                      controller: nameController,

                      // InputDecoration은 hint, icon, border 같은 입력창 모양을 담당한다.
                      decoration: InputDecoration(
                        hintText: '이름',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 닉네임 (nickname)
                    TextField(
                      controller: nicknameController,
                      decoration: InputDecoration(
                        hintText: '닉네임',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 이메일 (email)
                    TextField(
                      controller: emailController,

                      // 이메일 입력에 적합한 키보드
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: '이메일',
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

                    // 비밀번호 (password)
                    TextField(
                      controller: passwordController,
                      obscureText: isPasswordHidden,
                      decoration: InputDecoration(
                        hintText: '비밀번호',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            // 현재 값의 반대로 바꿔서 보이기 / 숨기기 전환
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
                    const SizedBox(height: 16),

                    // 비밀번호 확인
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: isConfirmPasswordHidden,
                      decoration: InputDecoration(
                        hintText: '비밀번호 확인',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(
                              () => isConfirmPasswordHidden =
                                  !isConfirmPasswordHidden,
                            );
                          },
                          icon: Icon(
                            isConfirmPasswordHidden
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
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(

                        // 요청 중에는 버튼 비활성화
                        onPressed: isLoading ? null : signUp,
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
                                '회원가입',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ),
                    ),
                    const SizedBox(height: 16),

                    // 이전 화면(로그인 화면)으로 돌아감
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('로그인 페이지로 돌아가기'),
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
