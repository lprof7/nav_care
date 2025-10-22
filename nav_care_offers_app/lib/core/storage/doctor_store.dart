abstract class DoctorStore {
  Future<Map<String, dynamic>?> getDoctor();
  Future<void> setDoctor(Map<String, dynamic> doctor);
  Future<void> clearDoctor();
}
