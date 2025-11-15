abstract class TokenStore {
  Future<String?> getUserToken();
  Future<void> setUserToken(String token);
  Future<void> clearUserToken();
  Future<String?> getHospitalToken();
  Future<void> setHospitalToken(String token);
  Future<void> clearHospitalToken();
}
