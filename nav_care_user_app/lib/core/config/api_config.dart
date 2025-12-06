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
  String get listServices => '$baseUrl/api/services';
  String get listServiceOfferings => '$baseUrl/api/service-offerings';
  String serviceOfferingById(String id) => '$baseUrl/api/service-offerings/$id';

  // Appointments
  String get createAppointment => '$baseUrl/api/appointments';
  String appointmentById(String id) => '$baseUrl/api/appointments/$id';
  String get userAppointments => '$baseUrl/api/appointments';
  String hospitalReviews(String hospitalId) =>
      '$baseUrl/api/reviews/hospitals/$hospitalId';
  String doctorReviews(String doctorId) =>
      '$baseUrl/api/reviews/doctors/$doctorId';

  // Hospitals
  String get createHospital => '$baseUrl/api/hospitals';
  String createHospitalPackages(String hospitalId) =>
      '$baseUrl/api/hospitals/$hospitalId/packages';
  String hospitalById(String id) => '$baseUrl/api/hospitals/$id';
  String hospitalClinics(String id) => '$baseUrl/api/hospitals/$id/clinics';
  String hospitalDoctors(String id) => '$baseUrl/api/hospitals/$id/doctors';
  String get myHospitalDoctors => '$baseUrl/api/hospitals/me/doctors';

  // Doctors
  String doctorById(String id) => '$baseUrl/api/doctors/$id';
  String get serviceOfferingsByProvider => '$baseUrl/api/service-offerings';
}
