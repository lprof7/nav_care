import '../../core/responses/result.dart';
import 'models/appointment_model.dart';
import 'remote_appointment_service.dart';

class AppointmentRepository {
  final RemoteAppointmentService _remoteService;

  AppointmentRepository({required RemoteAppointmentService remoteService})
      : _remoteService = remoteService;

  Future<Result<AppointmentModel>> createAppointment(AppointmentModel appointment) async {
    return await _remoteService.createAppointment(appointment);
  }
}