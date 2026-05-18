import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/auth/auth_token_storage.dart';
import '../core/network/api_constants.dart';

class LoginRequestDto {
  final String email;
  final String password;

  LoginRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class SetPrepTimeRequestDto {
  final int prepTimeMinutes;

  SetPrepTimeRequestDto({required this.prepTimeMinutes});

  Map<String, dynamic> toJson() => {'prepTimeMinutes': prepTimeMinutes};
}

class LoginService {
  final http.Client _client;
  final AuthTokenStorage _tokenStorage;

  LoginService({http.Client? client, AuthTokenStorage? tokenStorage})
    : _client = client ?? http.Client(),
      _tokenStorage = tokenStorage ?? AuthTokenStorage();

  Uri get _loginUri => ApiConstants.uri(ApiConstants.login);
  Uri get _setPrepTimeUri => ApiConstants.uri(ApiConstants.setPrepTime);

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = LoginRequestDto(email: email, password: password);
      final headers = await _jsonHeaders();

      debugPrint('LOGIN URI: $_loginUri');

      final response = await _client
          .post(_loginUri, headers: headers, body: jsonEncode(dto.toJson()))
          .timeout(const Duration(seconds: 10));

      debugPrint('LOGIN status: ${response.statusCode}');
      debugPrint('LOGIN body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = response.body.isEmpty
            ? {}
            : jsonDecode(response.body) as Map<String, dynamic>;

        if (body.isEmpty) {
          return LoginResult.success(data: body);
        }

        if (body.containsKey('success')) {
          if (body['success'] == true) {
            await _persistAuthSession(body);
            return LoginResult.success(
              message: body['message']?.toString() ?? '로그인 성공!',
              data: body,
            );
          }

          return LoginResult.failure(
            body['message']?.toString() ?? '로그인에 실패했습니다.',
          );
        }

        if (body['message']?.toString().isNotEmpty == true ||
            body.containsKey('data') ||
            body.containsKey('firstLogin') ||
            body.containsKey('prepTime')) {
          await _persistAuthSession(body);
          return LoginResult.success(
            message: body['message']?.toString() ?? '로그인 성공!',
            data: body,
          );
        }

        return LoginResult.success(data: body);
      }

      if (response.statusCode == 401) {
        return LoginResult.failure('이메일 또는 비밀번호가 올바르지 않습니다.');
      }

      return LoginResult.failure(
        '서버 오류가 발생했습니다. (${response.statusCode})',
        reasonPhrase: response.reasonPhrase,
      );
    } on TimeoutException catch (error) {
      return LoginResult.failure(_buildNetworkFailureMessage(), error: error);
    } catch (error) {
      return LoginResult.failure(_buildNetworkFailureMessage(), error: error);
    }
  }

  Future<LoginResult> setPrepTime({required int minutes}) async {
    try {
      final dto = SetPrepTimeRequestDto(prepTimeMinutes: minutes);
      final headers = await _jsonHeaders(withAuthorization: true);

      debugPrint('SET PREP TIME URI: $_setPrepTimeUri');

      final response = await _client
          .post(
            _setPrepTimeUri,
            headers: headers,
            body: jsonEncode(dto.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('SET PREP TIME status: ${response.statusCode}');
      debugPrint('SET PREP TIME body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = response.body.isEmpty
            ? {}
            : jsonDecode(response.body) as Map<String, dynamic>;

        if (body.isEmpty) {
          return LoginResult.success(message: '준비 시간 설정 성공!', data: body);
        }

        if (body.containsKey('success')) {
          if (body['success'] == true) {
            return LoginResult.success(
              message: body['message']?.toString() ?? '준비 시간 설정 성공!',
              data: body,
            );
          }

          return LoginResult.failure(
            body['message']?.toString() ?? '준비 시간 설정에 실패했습니다.',
          );
        }

        if (body['message']?.toString().isNotEmpty == true ||
            body.containsKey('data') ||
            body.containsKey('prepTimeMinutes')) {
          return LoginResult.success(
            message: body['message']?.toString() ?? '준비 시간 설정 성공!',
            data: body,
          );
        }

        return LoginResult.success(message: '준비 시간 설정 성공!', data: body);
      }

      if (response.statusCode == 401) {
        await _tokenStorage.clearTokens();
        return LoginResult.failure('로그인이 만료되었습니다. 다시 로그인해주세요.');
      }

      return LoginResult.failure(
        '서버 오류가 발생했습니다. (${response.statusCode})',
        reasonPhrase: response.reasonPhrase,
      );
    } on TimeoutException catch (error) {
      return LoginResult.failure(_buildNetworkFailureMessage(), error: error);
    } catch (error) {
      return LoginResult.failure(_buildNetworkFailureMessage(), error: error);
    }
  }

  void dispose() {
    _client.close();
  }

  Future<Map<String, String>> _jsonHeaders({
    bool withAuthorization = false,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (!withAuthorization) {
      return headers;
    }

    final authorizationValue = await _tokenStorage
        .readAuthorizationHeaderValue();

    if (authorizationValue != null) {
      headers['Authorization'] = authorizationValue;
    }

    return headers;
  }

  Future<void> _persistAuthSession(Map<String, dynamic> body) async {
    final grantType = _readStringValue(body, 'grantType');
    final accessToken = _readToken(body, 'accessToken');
    final refreshToken = _readToken(body, 'refreshToken');
    final accessTokenExpiresAt = _readIntValue(body, 'accessTokenExpiresIn');

    if (grantType == null &&
        accessToken == null &&
        refreshToken == null &&
        accessTokenExpiresAt == null) {
      return;
    }

    try {
      await _tokenStorage.saveTokens(
        grantType: grantType,
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresAt: accessTokenExpiresAt,
      );
    } catch (error) {
      debugPrint('TOKEN SAVE error: $error');
    }
  }

  String _buildNetworkFailureMessage() {
    if (ApiConstants.isUsingDefaultMockServer &&
        ApiConstants.baseUrl.contains('10.0.2.2')) {
      return '네트워크 오류가 발생했습니다. Android 에뮬레이터라면 PC에서 mock 서버가 실행 중인지 확인해주세요. 실제 기기라면 --dart-define=API_BASE_URL=http://<PC_LAN_IP>:3658/m1/1278134-1276435-default 로 실행해야 해요.';
    }

    if (ApiConstants.isUsingDefaultMockServer) {
      return '네트워크 오류가 발생했습니다. 기본 mock 서버(${ApiConstants.baseUrl}) 연결을 확인해주세요. 로컬 개발 서버를 쓰는 중이면 플랫폼별 개발용 네트워크 허용 설정도 필요할 수 있어요.';
    }

    return '네트워크 오류가 발생했습니다. 서버 주소를 확인해주세요. (${ApiConstants.baseUrl})';
  }

  String? _readToken(Map<String, dynamic> body, String key) {
    final nestedData = body['data'];

    if (nestedData is Map) {
      final nestedValue = nestedData[key];
      if (nestedValue is String && nestedValue.isNotEmpty) {
        return nestedValue;
      }
    }

    final rootValue = body[key];
    if (rootValue is String && rootValue.isNotEmpty) {
      return rootValue;
    }

    return null;
  }

  String? _readStringValue(Map<String, dynamic> body, String key) {
    final nestedData = body['data'];

    if (nestedData is Map) {
      final nestedValue = nestedData[key];
      if (nestedValue is String && nestedValue.isNotEmpty) {
        return nestedValue;
      }
    }

    final rootValue = body[key];
    if (rootValue is String && rootValue.isNotEmpty) {
      return rootValue;
    }

    return null;
  }

  int? _readIntValue(Map<String, dynamic> body, String key) {
    final nestedData = body['data'];

    if (nestedData is Map) {
      final nestedValue = nestedData[key];
      if (nestedValue is int) {
        return nestedValue;
      }

      if (nestedValue is num) {
        return nestedValue.toInt();
      }

      if (nestedValue is String) {
        return int.tryParse(nestedValue);
      }
    }

    final rootValue = body[key];

    if (rootValue is int) {
      return rootValue;
    }

    if (rootValue is num) {
      return rootValue.toInt();
    }

    if (rootValue is String) {
      return int.tryParse(rootValue);
    }

    return null;
  }
}

class LoginResult {
  const LoginResult._({
    required this.isSuccess,
    required this.message,
    this.data,
    this.reasonPhrase,
    this.error,
  });

  factory LoginResult.success({String message = '로그인 성공!', dynamic data}) {
    return LoginResult._(isSuccess: true, message: message, data: data);
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

  final bool isSuccess;
  final String message;
  final dynamic data;
  final String? reasonPhrase;
  final Object? error;

  dynamic _readValue(String key) {
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final rootMap = data as Map<String, dynamic>;
    final nestedData = rootMap['data'];

    if (nestedData is Map && nestedData.containsKey(key)) {
      return nestedData[key];
    }

    return rootMap[key];
  }

  String? get accessToken {
    final value = _readValue('accessToken');
    return value?.toString();
  }

  String? get refreshToken {
    final value = _readValue('refreshToken');
    return value?.toString();
  }

  String? get grantType {
    final value = _readValue('grantType');
    return value?.toString();
  }

  int? get accessTokenExpiresIn {
    final value = _readValue('accessTokenExpiresIn');

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  bool get isFirstLogin {
    final value = _readValue('firstLogin');

    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return false;
  }
}
