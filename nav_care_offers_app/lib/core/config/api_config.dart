class ApiConfig {
  final String baseUrl;
  const ApiConfig({required this.baseUrl});

  // Auth
  String get login => '$baseUrl/api/doctors/login';
  String get userLogin => '$baseUrl/api/users/auth/login';
  String get register => '$baseUrl/api/users/auth/register';

  // Doctor services
  String get doctorServices => '$baseUrl/api/doctors/me/services';

  // Hospitals
  String get hospitals => '$baseUrl/api/hospitals';
  String get userHospitals => '$baseUrl/api/hospitals/user';
  String hospitalById(String id) => '$baseUrl/api/hospitals/access/$id';
}
