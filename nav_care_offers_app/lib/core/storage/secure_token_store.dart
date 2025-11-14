import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_store.dart';

class SecureTokenStore implements TokenStore {
  final _storage = const FlutterSecureStorage();
  static const _authTokenKey = 'auth_token';
  static const _hospitalTokenKey = 'hospital_token';

  @override
  Future<String?> getToken() {
    return _storage.read(key: _authTokenKey);
  }

  @override
  Future<void> setToken(String token) {
    return _storage.write(key: _authTokenKey, value: token);
  }

  @override
  Future<void> clearToken() {
    return _storage.delete(key: _authTokenKey);
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
}
