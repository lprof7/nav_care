class ApiConfig {
  final String baseUrl;
  const ApiConfig({required this.baseUrl});

  // Auth
  String get login => '$baseUrl/api/doctors/login';
  String get userLogin => '$baseUrl/api/users/auth/login';
  String get register => '$baseUrl/api/users/auth/register';
  String get passwordResetCode => '$baseUrl/api/users/auth/password/reset-code';
  String get passwordVerifyCode =>
      '$baseUrl/api/users/auth/password/verify-code';
  String get passwordReset => '$baseUrl/api/users/auth/password/reset';
  String get becomeDoctor => '$baseUrl/api/doctors/become';

  // Doctor services
  String get doctors => '$baseUrl/api/doctors';
  String doctorById(String id) => '$baseUrl/api/doctors/$id';
  String get doctorServices => '$baseUrl/api/doctors/me/services';
  String get doctorAppointments => '$baseUrl/api/doctors/me/appointments';
  String appointmentById(String id) => '$baseUrl/api/appointments/$id';
  String get myServiceOfferings => '$baseUrl/api/service-offerings/me';
  String get serviceOfferingsBase => '$baseUrl/api/service-offerings';
  String serviceOfferingById(String id) => '$baseUrl/api/service-offerings/$id';
  String get servicesCatalog => '$baseUrl/api/services';
  String serviceOfferingReviews(String offeringId) =>
      '$baseUrl/api/reviews/service-offerings/$offeringId';

  // Hospitals
  String get hospitals => '$baseUrl/api/hospitals';
  String get userHospitals => '$baseUrl/api/hospitals/user';
  String hospitalById(String id) => '$baseUrl/api/hospitals/$id';
  String get hospitalInvitations => '$baseUrl/api/hospitals/invitations';
  String hospitalReviews(String hospitalId) =>
      '$baseUrl/api/reviews/hospitals/$hospitalId';
  String doctorReviews(String doctorId) =>
      '$baseUrl/api/reviews/doctors/$doctorId';

  String accessHospitalById(String id) => '$baseUrl/api/hospitals/access/$id';

  // Clinics
  String get clinics => '$baseUrl/api/hospitals';
  String hospitalClinics(String hospitalId) =>
      '$baseUrl/api/hospitals/$hospitalId/clinics';
  String clinicById(String id) => '$baseUrl/api/clinics/$id';

  // Feedback
  String get sendFeedback => '$baseUrl/api/feedback';
}
