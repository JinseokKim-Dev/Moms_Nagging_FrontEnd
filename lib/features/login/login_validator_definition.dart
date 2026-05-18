/*
===============================================================
해당 코드는 login.dart 49번 라인 Future<void> login() 에서 사용됨 
===============================================================
*/
enum LoginValidationError { emptyFields, invalidEmail }

/*
========================
**LoginValidator Class**
========================
*/
class LoginValidator {
  static final RegExp _emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
  static LoginValidationError? validate({
    required String email,
    required String password,
  }) {
    if (email.isEmpty || password.isEmpty) {
      return LoginValidationError.emptyFields;
    }
    if (!_emailRegex.hasMatch(email)) {
      return LoginValidationError.invalidEmail;
    }
    return null;
  }
  // ?는 리턴값이 null일 수 있다 라는 의미 -> null 처리를 해주기 위한 기호다.

  static String message(LoginValidationError error) {
    switch (error) {
      case LoginValidationError.emptyFields:
        return '이메일과 비밀번호를 모두 입력하세요.';
      case LoginValidationError.invalidEmail:
        return '올바른 이메일 형식을 입력하세요.';
    }
  }
} // null이 아니라 값이 존재한다면 해당 값 리턴
