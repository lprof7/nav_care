import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:nav_care_offers_app/core/config/api_config.dart';
import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';
import 'package:get_it/get_it.dart';

import 'package:nav_care_offers_app/data/appointments/services/appointments_service.dart';

class RemoteAppointmentsService implements AppointmentsService {
  RemoteAppointmentsService(this._apiClient);

  final ApiClient _apiClient;
  final TokenStore _tokenStore = GetIt.I<TokenStore>();

  @override
  Future<Result<Map<String, dynamic>>> getMyDoctorAppointments() async {
    final token = await _tokenStore.getDoctorToken();
    if (token == null || token.isEmpty) {
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.get(
      _apiClient.apiConfig.doctorAppointments,
      parser: (data) => data as Map<String, dynamic>,
      useDoctorToken: true,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> getMyHospitalAppointments() async {
    var token = await _tokenStore.getHospitalToken();
    if (token == null || token.isEmpty) {
      token = await _tokenStore.getClinicToken();
    }
    if (token == null || token.isEmpty) {
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.get(
      _apiClient.apiConfig.hospitalAppointments,
      parser: (data) => data as Map<String, dynamic>,
      useHospitalToken: true,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> updateAppointment({
    required String appointmentId,
    required Map<String, dynamic> payload,
    bool useHospitalToken = false,
  }) async {
    String? token;
    if (useHospitalToken) {
      token = await _tokenStore.getHospitalToken();
      if (token == null || token.isEmpty) {
        token = await _tokenStore.getClinicToken();
      }
    } else {
      token = await _tokenStore.getDoctorToken();
    }
    if (token == null || token.isEmpty) {
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.patch(
      _apiClient.apiConfig.appointmentById(appointmentId),
      body: payload,
      parser: (data) {
        return data as Map<String, dynamic>;
      },
      useHospitalToken: useHospitalToken,
      useDoctorToken: !useHospitalToken,
    );
  }
}
