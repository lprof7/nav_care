class ApiConfig {
  final String baseUrl;
  const ApiConfig({required this.baseUrl});

  // Auth
  String get login => '$baseUrl/api/doctors/login';
  String get register => '$baseUrl/api/users/auth/register';

  // Doctor services
  String get doctorServices => '$baseUrl/api/doctors/services';
}
