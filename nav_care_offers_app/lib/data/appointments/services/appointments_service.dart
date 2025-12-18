import 'package:nav_care_offers_app/core/responses/result.dart';

abstract class AppointmentsService {
  Future<Result<Map<String, dynamic>>> getMyDoctorAppointments();
  Future<Result<Map<String, dynamic>>> getMyHospitalAppointments();
  Future<Result<Map<String, dynamic>>> updateAppointment({
    required String appointmentId,
    required Map<String, dynamic> payload,
    bool useHospitalToken = false,
  });
}
