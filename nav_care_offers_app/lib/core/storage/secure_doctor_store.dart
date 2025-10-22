import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'doctor_store.dart';

class SecureDoctorStore implements DoctorStore {
  SecureDoctorStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'auth_doctor';

  @override
  Future<Map<String, dynamic>?> getDoctor() async {
    final value = await _storage.read(key: _key);
    if (value == null || value.isEmpty) return null;
    try {
      final decoded = jsonDecode(value);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setDoctor(Map<String, dynamic> doctor) {
    return _storage.write(key: _key, value: jsonEncode(doctor));
  }

  @override
  Future<void> clearDoctor() {
    return _storage.delete(key: _key);
  }
}
