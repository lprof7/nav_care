class ApiConfig {
  final String baseUrl;
  const ApiConfig({required this.baseUrl});

  // Auth
  String get login => '$baseUrl/api/users/auth/login';
  String get register => '$baseUrl/api/users/auth/register';

  // Advertisings
  String get getAdvertisings => '$baseUrl/api/advertising';

  // Services
  String get createService => '$baseUrl/api/services';

  // Hospitals
  String get createHospital => '$baseUrl/api/hospitals';
  String createHospitalPackages(String hospitalId) =>
      '$baseUrl/api/hospitals/$hospitalId/packages';
}
