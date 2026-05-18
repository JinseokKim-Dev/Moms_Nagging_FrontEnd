import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'alarm_logic.dart';

class AlarmStorage {
  AlarmStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _alarmsKey = 'alarm_routines';

  final FlutterSecureStorage _storage;

  Future<List<AlarmRoutine>?> readAlarms() async {
    final rawValue = await _storage.read(key: _alarmsKey);

    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);

      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map((item) => AlarmRoutine.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveAlarms(List<AlarmRoutine> alarms) async {
    final encoded = jsonEncode(
      alarms.map((alarm) => alarm.toJson()).toList(growable: false),
    );

    await _storage.write(key: _alarmsKey, value: encoded);
  }
}
