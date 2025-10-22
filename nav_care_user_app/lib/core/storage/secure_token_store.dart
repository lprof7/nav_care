import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_store.dart';

class SecureTokenStore implements TokenStore {
  final _storage = const FlutterSecureStorage();
  static const _key = 'auth_token';

  @override
  Future<String?> getToken() {
    return _storage.read(key: _key);
  }

  @override
  Future<void> setToken(String token) {
    return _storage.write(key: _key, value: token);
  }

  @override
  Future<void> clearToken() {
    return _storage.delete(key: _key);
  }
}
