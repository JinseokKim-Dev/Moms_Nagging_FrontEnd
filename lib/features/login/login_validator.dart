// enum은 "정해진 몇 가지 상태 중 하나"를 표현할 때 쓴다.
// 문자열보다 오타에 강하고, switch 문과 함께 쓰기 좋다.
enum LoginValidationError { emptyFields, invalidEmail }

class LoginValidator {
  // RegExp는 정규표현식 객체다.
  // 이메일 모양이 맞는지 검사할 때 사용한다.
  static final RegExp _emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');

  // static 메서드는 객체를 생성하지 않아도
  // LoginValidator.validate(...) 형태로 바로 호출할 수 있다.
  //
  // 반환값:
  // - null: 유효성 검사 통과
  // - enum 값: 어떤 종류의 오류인지 알려줌
  static LoginValidationError? validate({
    required String email,
    required String password,
  }) {
    // 둘 중 하나라도 비어 있으면 emptyFields 상태를 반환
    if (email.isEmpty || password.isEmpty) {
      return LoginValidationError.emptyFields;
    }

    // 이메일 형식 검사
    if (!_emailRegex.hasMatch(email)) {
      return LoginValidationError.invalidEmail;
    }

    // 모든 검사를 통과하면 null
    return null;
  }

  // enum 상태를 실제 사용자에게 보여줄 문구로 바꿔 주는 함수다.
  static String message(LoginValidationError error) {
    switch (error) {
      case LoginValidationError.emptyFields:
        return '이메일과 비밀번호를 모두 입력하세요.';
      case LoginValidationError.invalidEmail:
        return '올바른 이메일 형식을 입력하세요.';
    }
  }
}
