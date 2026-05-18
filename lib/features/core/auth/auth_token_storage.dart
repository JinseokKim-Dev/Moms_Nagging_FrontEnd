import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_constants.dart';

class AuthTokenStorage {
  AuthTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _grantTypeKey = 'auth_grant_type';
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _accessTokenExpiresAtKey = 'auth_access_token_expires_at';

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    String? grantType,
    String? accessToken,
    String? refreshToken,
    int? accessTokenExpiresAt,
  }) async {
    if (grantType != null && grantType.isNotEmpty) {
      await _storage.write(key: _grantTypeKey, value: grantType);
    }

    if (accessToken != null && accessToken.isNotEmpty) {
      await _storage.write(key: _accessTokenKey, value: accessToken);
    }

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }

    if (accessTokenExpiresAt != null && accessTokenExpiresAt > 0) {
      await _storage.write(
        key: _accessTokenExpiresAtKey,
        value: accessTokenExpiresAt.toString(),
      );
    }
  }

  Future<String?> readGrantType() {
    return _storage.read(key: _grantTypeKey);
  }

  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<int?> readAccessTokenExpiresAt() async {
    final rawValue = await _storage.read(key: _accessTokenExpiresAtKey);

    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return int.tryParse(rawValue);
  }

  Future<bool> hasAccessToken() async {
    return hasActiveSession();
  }

  Future<bool> hasValidAccessToken() async {
    final accessToken = await readAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    if (ApiConstants.shouldBypassTokenExpiryCheck) {
      return true;
    }

    final expiresAt = await _resolveAccessTokenExpiresAt(accessToken);

    if (expiresAt != null &&
        expiresAt <= DateTime.now().millisecondsSinceEpoch) {
      return false;
    }

    return true;
  }

  Future<bool> hasActiveSession() async {
    if (await hasValidAccessToken()) {
      return true;
    }

    final refreshToken = await readRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await clearTokens();
      return false;
    }

    if (ApiConstants.shouldBypassTokenExpiryCheck) {
      return true;
    }

    final refreshExpiresAt = _extractJwtExpiresAt(refreshToken);

    if (refreshExpiresAt == null ||
        refreshExpiresAt > DateTime.now().millisecondsSinceEpoch) {
      return true;
    }

    await clearTokens();
    return false;
  }

  Future<String?> readAuthorizationHeaderValue() async {
    final accessToken = await readAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    final grantType = await readGrantType();
    final normalizedGrantType = (grantType == null || grantType.isEmpty)
        ? 'Bearer'
        : grantType;

    return '$normalizedGrantType $accessToken';
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _grantTypeKey);
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accessTokenExpiresAtKey);
  }

  Future<int?> _resolveAccessTokenExpiresAt(String accessToken) async {
    final storedExpiresAt = await readAccessTokenExpiresAt();
    final jwtExpiresAt = _extractJwtExpiresAt(accessToken);

    if (storedExpiresAt == null) {
      return jwtExpiresAt;
    }

    if (jwtExpiresAt == null) {
      return storedExpiresAt;
    }

    return storedExpiresAt > jwtExpiresAt ? storedExpiresAt : jwtExpiresAt;
  }

  int? _extractJwtExpiresAt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final normalizedPayload = base64Url.normalize(parts[1]);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
      final payloadMap = jsonDecode(decodedPayload);

      if (payloadMap is! Map<String, dynamic>) {
        return null;
      }

      final exp = payloadMap['exp'];

      if (exp is int) {
        return exp * 1000;
      }

      if (exp is num) {
        return exp.toInt() * 1000;
      }

      if (exp is String) {
        final parsedExp = int.tryParse(exp);
        if (parsedExp != null) {
          return parsedExp * 1000;
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
