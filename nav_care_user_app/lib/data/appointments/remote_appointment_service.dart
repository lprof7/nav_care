import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/responses/result.dart';
import 'models/appointment_model.dart';

import 'package:nav_care_user_app/core/responses/failure.dart';

class RemoteAppointmentService {
  final ApiClient _apiClient;

  RemoteAppointmentService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Result<AppointmentModel>> createAppointment(AppointmentModel appointment) async {
    try {
      final response = await _apiClient.post<AppointmentModel>(
        '/api/appointments',
        body: appointment.toJson(),
        parser: (json)  {
          return AppointmentModel.fromJson(json['data']);} // Assuming API returns { "data": { ... appointment data ... } }
      );
      print(response.data);
      return response; // ApiClient.post already returns Result<T>
    } on DioException catch (e) {

      return Result.failure(Failure.server(message: e.message ?? 'Server Error'));
    } catch (e) {
       print({"serverrr $e"});
      return Result.failure(const Failure.unknown());
    }
  }
}
