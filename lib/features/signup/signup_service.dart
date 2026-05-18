import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/network/api_constants.dart';

// 회원가입 API 요청을 담당하는 서비스 클래스
class SignUpService {
  // 외부에서 client를 주입할 수 있게 해서 테스트와 재사용성을 높인다.
  SignUpService({http.Client? client}) : _client = client ?? http.Client();
  // 네트워크 요청을 실제로 보내는 객체
  final http.Client _client;

  // 회원가입 API 주소
  static final Uri _signUpUri = ApiConstants.uri(ApiConstants.signUp);

  // 회원가입 요청 함수
  Future<SignUpResult> signUp({
    required String name,
    required String nickname,
    required String email,
    required String password,
  }) async {
    try {
      // 서버에서 요구하는 형태에 맞게 JSON body를 만든다.
      final response = await _client.post(
        _signUpUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'realname': name,
          'nickname': nickname,
        }),
      );

      // 200 응답이면 가입 성공으로 처리
      if (response.statusCode == 200) {
        final dynamic data = response.body.isEmpty
            ? null
            : jsonDecode(response.body);

        return SignUpResult.success(data: data);
      }

      // 409는 보통 중복 데이터 충돌
      if (response.statusCode == 409) {
        return SignUpResult.failure('이미 사용 중인 이메일입니다.');
      }

      // 나머지는 서버 오류 메시지로 처리
      return SignUpResult.failure(
        '서버 오류가 발생했습니다. (${response.statusCode})',
        reasonPhrase: response.reasonPhrase,
      );
    } on TimeoutException catch (error) {
      return SignUpResult.failure(
        '네트워크 오류가 발생했습니다. 서버 주소를 확인해주세요. (${ApiConstants.baseUrl})',
        error: error,
      );
    } catch (error) {
      // 연결 실패나 파싱 문제 등 예외 발생 시
      return SignUpResult.failure(
        '네트워크 오류가 발생했습니다. 서버 주소를 확인해주세요. (${ApiConstants.baseUrl})',
        error: error,
      );
    }
  }

  // Client 종료
  void dispose() {
    _client.close();
  }
}

// 회원가입 결과를 담는 데이터 객체
class SignUpResult {
  const SignUpResult._({
    required this.isSuccess,
    required this.message,
    this.data,
    this.reasonPhrase,
    this.error,
  });

  factory SignUpResult.success({dynamic data}) {
    return SignUpResult._(
      isSuccess: true,
      message: '회원가입이 완료되었습니다!',
      data: data,
    );
  }

  factory SignUpResult.failure(
    String message, {
    String? reasonPhrase,
    Object? error,
  }) {
    return SignUpResult._(
      isSuccess: false,
      message: message,
      reasonPhrase: reasonPhrase,
      error: error,
    );
  }

  final bool isSuccess;
  final String message;
  final dynamic data;
  final String? reasonPhrase;
  final Object? error;
}
