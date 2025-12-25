class ApiConfig {
  final String baseUrl;
  const ApiConfig({required this.baseUrl});

  // Translation
  String get translateText => '$baseUrl/api/backend-services/translate-text';

  // Auth
  String get login => '$baseUrl/api/users/auth/login';
  String get register => '$baseUrl/api/users/auth/register';
  String get passwordResetCode => '$baseUrl/api/users/auth/password/reset-code';
  String get passwordVerifyCode =>
      '$baseUrl/api/users/auth/password/verify-code';
  String get passwordReset => '$baseUrl/api/users/auth/password/reset';

  // Advertisings
  String get getAdvertisings => '$baseUrl/api/advertising';

  // Services
  String get createService => '$baseUrl/api/services';
  String get listServices => '$baseUrl/api/services';
  String get listServiceOfferings => '$baseUrl/api/service-offerings';
  String serviceOfferingById(String id) => '$baseUrl/api/service-offerings/$id';
  String relatedServiceOfferings(String id) =>
      '$baseUrl/api/service-offerings/$id/related';

  // Appointments
  String get createAppointment => '$baseUrl/api/appointments';
  String appointmentById(String id) => '$baseUrl/api/appointments/$id';
  String get userAppointments => '$baseUrl/api/appointments';
  String hospitalReviews(String hospitalId) =>
      '$baseUrl/api/reviews/hospitals/$hospitalId';
  String doctorReviews(String doctorId) =>
      '$baseUrl/api/reviews/doctors/$doctorId';
  String serviceOfferingReviews(String offeringId) =>
      '$baseUrl/api/reviews/service-offerings/$offeringId';
  String get faq => '$baseUrl/api/faq';

  // Hospitals
  String get createHospital => '$baseUrl/api/hospitals';
  String get listHospitals => '$baseUrl/api/hospitals';
  String get listBoostedHospitals => '$baseUrl/api/hospitals/boosted';
  String createHospitalPackages(String hospitalId) =>
      '$baseUrl/api/hospitals/$hospitalId/packages';
  String hospitalById(String id) => '$baseUrl/api/hospitals/$id';
  String hospitalClinics(String id) => '$baseUrl/api/hospitals/$id/clinics';
  String hospitalDoctors(String id) => '$baseUrl/api/hospitals/$id/doctors';
  String get myHospitalDoctors => '$baseUrl/api/hospitals/me/doctors';

  // Doctors
  String doctorById(String id) => '$baseUrl/api/doctors/$id';
  String get listDoctors => '$baseUrl/api/doctors';
  String get listBoostedDoctors => '$baseUrl/api/doctors/boosted';
  String get serviceOfferingsByProvider => '$baseUrl/api/service-offerings';

  // Feedback
  String get sendFeedback => '$baseUrl/api/feedback';
}
