import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/responses/result.dart';
import 'models/appointment_model.dart';

import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/storage/token_store.dart';

class RemoteAppointmentService {
  final ApiClient _apiClient;
  final TokenStore _tokenStore;

  RemoteAppointmentService({
    required ApiClient apiClient,
    required TokenStore tokenStore,
  })  : _apiClient = apiClient,
        _tokenStore = tokenStore;

  Future<Result<Map<String, dynamic>>> createAppointment(
      AppointmentModel appointment) async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      return Result.failure(const Failure.unauthorized());
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _apiClient.apiConfig.createAppointment,
        body: appointment.toJson(),
        headers: {'Authorization': 'Bearer $token'},
        parser: (json) => json as Map<String, dynamic>,
      );
      return response; // ApiClient.post already returns Result<T>
    } on DioException catch (e) {
      return Result.failure(
          Failure.server(message: e.message ?? 'Server Error'));
    } catch (e) {
      return Result.failure(const Failure.unknown());
    }
  }

  Future<Result<Map<String, dynamic>>> getMyAppointments({
    int? page,
    int? limit,
  }) async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      return Result.failure(const Failure.unauthorized());
    }

    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;

    return _apiClient.get(
      _apiClient.apiConfig.userAppointments,
      query: query.isEmpty ? null : query,
      parser: (json) {
        print("getMyAppointments response: $json");
        return json as Map<String, dynamic>;
      },
      headers: {'Authorization': 'Bearer ' + token},
    );
  }

  Future<Result<Map<String, dynamic>>> updateAppointment({
    required String appointmentId,
    required Map<String, dynamic> payload,
  }) {
    return _apiClient.patch(
      _apiClient.apiConfig.appointmentById(appointmentId),
      body: payload,
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}
