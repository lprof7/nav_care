abstract class TokenStore {
  Future<String?> getToken();
  Future<void> setToken(String token);
  Future<void> clearToken();
}
