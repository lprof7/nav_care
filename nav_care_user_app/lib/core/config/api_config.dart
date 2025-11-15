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

  // Appointments
  String get createAppointment => '$baseUrl/api/appointments';
  String appointmentById(String id) => '$baseUrl/api/appointments/$id';
  String get userAppointments => '$baseUrl/api/appointments';

  // Hospitals
  String get createHospital => '$baseUrl/api/hospitals';
  String createHospitalPackages(String hospitalId) =>
      '$baseUrl/api/hospitals/$hospitalId/packages';
}
