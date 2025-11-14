abstract class TokenStore {
  Future<String?> getToken();
  Future<void> setToken(String token);
  Future<void> clearToken();
  Future<String?> getHospitalToken();
  Future<void> setHospitalToken(String token);
  Future<void> clearHospitalToken();
}
