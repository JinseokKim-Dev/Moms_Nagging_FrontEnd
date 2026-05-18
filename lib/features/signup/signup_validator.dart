// 회원가입 검증에서 나올 수 있는 오류 종류들
enum SignUpValidationError {
  emptyFields,
  invalidEmail,
  invalidPassword,
  passwordMismatch,
}

class SignUpValidator {
  // 이메일 형식을 검사할 정규표현식
  static final RegExp _emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*[^A-Za-z0-9]).{8,}$',
  );

  static const String passwordGuideText = '비밀번호는 8자 이상, 영문과 특수문자를 포함해주세요.';

  static String? passwordErrorText(
    String password, {
    bool showEmptyMessage = false,
  }) {
    if (password.isEmpty) {
      return showEmptyMessage ? '비밀번호를 입력하세요.' : null;
    }

    if (!_passwordRegex.hasMatch(password)) {
      return passwordGuideText;
    }

    return null;
  }

  // 회원가입 입력 전체를 한 번에 검사하는 함수
  // null이면 통과, enum이면 해당 오류 상태를 의미한다.
  static SignUpValidationError? validate({
    required String name,
    required String nickname,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    // 하나라도 비어 있으면 실패
    if (name.isEmpty ||
        nickname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return SignUpValidationError.emptyFields;
    }

    // 이메일 형식 검사
    if (!_emailRegex.hasMatch(email)) {
      return SignUpValidationError.invalidEmail;
    }

    // 비밀번호 규칙 검사
    if (passwordErrorText(password, showEmptyMessage: true) != null) {
      return SignUpValidationError.invalidPassword;
    }

    // 비밀번호 확인 값이 다르면 실패
    if (password != confirmPassword) {
      return SignUpValidationError.passwordMismatch;
    }

    return null;
  }

  // enum 상태를 실제 문구로 바꿔 준다.
  static String message(SignUpValidationError error) {
    switch (error) {
      case SignUpValidationError.emptyFields:
        return '모든 항목을 입력하세요.';
      case SignUpValidationError.invalidEmail:
        return '올바른 이메일 형식을 입력하세요.';
      case SignUpValidationError.invalidPassword:
        return passwordGuideText;
      case SignUpValidationError.passwordMismatch:
        return '비밀번호가 일치하지 않습니다.';
    }
  }
}
