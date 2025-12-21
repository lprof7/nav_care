import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_store.dart';

class SecureTokenStore implements TokenStore {
  final _storage = const FlutterSecureStorage();
  static const _authTokenKey = 'auth_token';
  static const _doctorTokenKey = 'doctor_token';
  static const _hospitalTokenKey = 'hospital_token';
  static const _isDoctorKey = 'is_doctor';

  @override
  Future<String?> getUserToken() {
    return _storage.read(key: _authTokenKey);
  }

  @override
  Future<void> setUserToken(String token) {
    return _storage.write(key: _authTokenKey, value: token);
  }

  @override
  Future<void> clearUserToken() {
    return _storage.delete(key: _authTokenKey);
  }

  @override
  Future<String?> getDoctorToken() {
    return _storage.read(key: _doctorTokenKey);
  }

  @override
  Future<void> setDoctorToken(String token) {
    return _storage.write(key: _doctorTokenKey, value: token);
  }

  @override
  Future<void> clearDoctorToken() {
    return _storage.delete(key: _doctorTokenKey);
  }

  @override
  Future<String?> getHospitalToken() {
    return _storage.read(key: _hospitalTokenKey);
  }

  @override
  Future<void> setHospitalToken(String token) {
    return _storage.write(key: _hospitalTokenKey, value: token);
  }

  @override
  Future<void> clearHospitalToken() {
    return _storage.delete(key: _hospitalTokenKey);
  }

  @override
  Future<bool?> getIsDoctor() async {
    final raw = await _storage.read(key: _isDoctorKey);
    if (raw == null) return null;
    return raw == 'true';
  }

  @override
  Future<void> setIsDoctor(bool value) {
    return _storage.write(key: _isDoctorKey, value: value.toString());
  }

  @override
  Future<void> clearIsDoctor() {
    return _storage.delete(key: _isDoctorKey);
  }
}
