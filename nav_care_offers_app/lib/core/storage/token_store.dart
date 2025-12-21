abstract class TokenStore {
  Future<String?> getUserToken();
  Future<void> setUserToken(String token);
  Future<void> clearUserToken();
  Future<String?> getDoctorToken();
  Future<void> setDoctorToken(String token);
  Future<void> clearDoctorToken();
  Future<String?> getHospitalToken();
  Future<void> setHospitalToken(String token);
  Future<void> clearHospitalToken();
  Future<bool?> getIsDoctor();
  Future<void> setIsDoctor(bool value);
  Future<void> clearIsDoctor();
}
