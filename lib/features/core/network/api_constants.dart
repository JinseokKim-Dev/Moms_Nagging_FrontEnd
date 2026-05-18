import 'package:flutter/foundation.dart';

/// Shared API configuration for the app.
///
/// Override `API_BASE_URL` at run time to switch between real and mock servers:
/// `flutter run -t features/main.dart --dart-define=API_BASE_URL=https://...`
abstract final class ApiConstants {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:3658/m1/1278134-1276435-default';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator cannot reach the host machine via 127.0.0.1.
      return 'http://10.0.2.2:3658/m1/1278134-1276435-default';
    }

    return 'http://127.0.0.1:3658/m1/1278134-1276435-default';
  }

  static bool get shouldBypassTokenExpiryCheck =>
      baseUrl.contains('/m1/') ||
      baseUrl.contains('127.0.0.1:3658') ||
      baseUrl.contains('10.0.2.2:3658');

  static bool get isUsingDefaultMockServer =>
      _configuredBaseUrl.isEmpty && baseUrl.contains(':3658');

  static const String login = '/api/v1/member/login';
  static const String signUp = '/api/v1/member/join';
  static const String setPrepTime = '/api/v1/member/set-prep-time';

  static Uri uri(String path) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$normalizedBaseUrl$normalizedPath');
  }
}
