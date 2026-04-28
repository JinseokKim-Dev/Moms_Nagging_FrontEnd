import 'dart:convert';
import 'package:http/http.dart' as http;

// Service 클래스는 "서버 통신" 같은 비즈니스 로직을 분리할 때 자주 만든다.
// 화면 위젯에서 직접 http 요청을 보내면 UI 코드와 네트워크 코드가 섞이기 쉬워서
// 보통 이렇게 별도 클래스로 분리한다.
class LoginService {
  // 의존성 주입 형태의 생성자다.
  // 외부에서 client를 넘기면 그걸 쓰고, 아니면 기본 http.Client를 만든다.
  // 테스트할 때 가짜 client를 넣고 싶을 때 유용하다.
  LoginService({http.Client? client}) : _client = client ?? http.Client();

  // 변수 이름 앞에 _ 가 붙으면 Dart에서 같은 라이브러리 내부 전용(private) 의미다.
  final http.Client _client;

  // 로그인 API 주소
  static final Uri _loginUri = Uri.parse(
    'http://localhost:8080/api/v1/member/login',
  );

  // async / await를 사용한 비동기 로그인 함수다.
  // 서버 통신은 시간이 걸리므로 Future를 반환한다.
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // POST 요청으로 이메일/비밀번호를 JSON 형태로 보낸다.
      final response = await _client.post(
        _loginUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // 200이면 성공으로 간주
      if (response.statusCode == 200) {
        // body가 비어 있지 않으면 JSON을 파싱해서 data에 담는다.
        final dynamic data = response.body.isEmpty
            ? null
            : jsonDecode(response.body);

        return LoginResult.success(data: data);
      }

      // 401은 보통 인증 실패
      if (response.statusCode == 401) {
        return LoginResult.failure('이메일 또는 비밀번호가 올바르지 않습니다.');
      }

      // 그 외 status code는 서버 오류로 처리
      return LoginResult.failure(
        '서버 오류가 발생했습니다. (${response.statusCode})',
        reasonPhrase: response.reasonPhrase,
      );
    } catch (error) {
      // 네트워크 단절, 서버 연결 실패 등 예외가 발생한 경우
      return LoginResult.failure('네트워크 오류가 발생했습니다.', error: error);
    }
  }

  // 사용이 끝난 Client는 닫아서 자원을 정리한다.
  void dispose() {
    _client.close();
  }
}

// 결과를 단순 bool 하나로만 주는 대신,
// 성공 여부 + 메시지 + 서버 데이터 + 예외 정보를 함께 담는 객체다.
class LoginResult {
  // _가 붙은 private named constructor
  // 외부에서는 success / failure factory를 통해서만 생성하게 만든다.
  const LoginResult._({
    required this.isSuccess,
    required this.message,
    this.data,
    this.reasonPhrase,
    this.error,
  });

  // factory constructor는 상황에 따라 다른 형태의 객체를 만들 때 유용하다.
  factory LoginResult.success({dynamic data}) {
    return LoginResult._(isSuccess: true, message: '로그인 성공!', data: data);
  }

  factory LoginResult.failure(
    String message, {
    String? reasonPhrase,
    Object? error,
  }) {
    return LoginResult._(
      isSuccess: false,
      message: message,
      reasonPhrase: reasonPhrase,
      error: error,
    );
  }

  // final은 한 번 값이 정해지면 바뀌지 않는다는 뜻이다.
  final bool isSuccess;
  final String message;
  final dynamic data;
  final String? reasonPhrase;
  final Object? error;
}
