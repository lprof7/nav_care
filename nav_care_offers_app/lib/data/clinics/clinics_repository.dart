import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart'
    as core_pagination;

import 'models/clinic_model.dart';
import 'package:nav_care_offers_app/data/clinics/services/clinics_service.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart';

class ClinicsRepository {
  ClinicsRepository(this._service);

  final ClinicsService _service;
  List<ClinicModel> _cache = const [];
  core_pagination.Pagination? _lastPagination;

  List<ClinicModel> get cachedClinics => List.unmodifiable(_cache);
  core_pagination.Pagination? get lastPagination => _lastPagination;

  Future<Result<ClinicListModel>> getHospitalClinics(String hospitalId) async {
    final response = await _service.getHospitalClinics(hospitalId);
    print("data from repository is ${response.data}");

    return response.fold(
      onSuccess: (data) {
        final clinicListData = data['data']
            ['data']; // Access the 'data' field inside the 'data' map
        final paginationData = data['data'][
            'pagination']; // Access the 'pagination' field inside the 'data' map

        final List<ClinicModel> clinics = (clinicListData as List)
            .map((clinicJson) => ClinicModel.fromJson(clinicJson))
            .toList();

        final pagination = core_pagination.Pagination.fromJson(paginationData);

        _cache = clinics;
        _lastPagination = pagination;

        return Result.success(ClinicListModel(
          data: clinics,
          pagination: pagination,
        ));
      },
      onFailure: (failure) {
        return Result.failure(failure);
      },
    );
  }

  Future<Result<ClinicModel>> createClinic(HospitalPayload payload) async {
    try {
      final response = await _service.createClinic(payload);

      if (!response.isSuccess || response.data == null) {
        return Result.failure(response.error ?? const Failure.unknown());
      }

      final data = response.data;
      final rawClinic =
          data?['hospital'] ?? data?['clinic'] ?? data?['data'] ?? data;
      final clinic = ClinicModel.fromJson(
          rawClinic is Map<String, dynamic> ? rawClinic : {});

      _cache = _upsert(_cache, clinic);
      return Result.success(clinic);
    } catch (e) {
      return Result.failure(
        const Failure.server(message: 'Failed to submit clinic'),
      );
    }
  }

  Future<Result<ClinicModel>> updateClinic(HospitalPayload payload) async {
    try {
      final response = await _service.updateClinic(payload);

      if (!response.isSuccess || response.data == null) {
        return Result.failure(response.error ?? const Failure.unknown());
      }

      final data = response.data;
      final rawClinic = data?['clinic'] ?? data?['data'] ?? data;
      final clinic = ClinicModel.fromJson(
          rawClinic is Map<String, dynamic> ? rawClinic : {});

      _cache = _upsert(_cache, clinic);
      return Result.success(clinic);
    } catch (e) {
      print("Error updating clinic: $e");
      return Result.failure(
        const Failure.server(message: 'Failed to update clinic'),
      );
    }
  }

  Future<Result<String>> deleteClinic(String clinicId) async {
    final response = await _service.deleteClinic(clinicId);

    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final message = response.data!['message']?.toString() ??
          'Clinic deleted successfully';
      _cache = _cache.where((element) => element.id != clinicId).toList();
      return Result.success(message);
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'Failed to delete clinic'),
      );
    }
  }

  List<ClinicModel> _upsert(List<ClinicModel> source, ClinicModel clinic) {
    final list = List<ClinicModel>.from(source);
    final index = list.indexWhere((element) => element.id == clinic.id);
    if (index >= 0) {
      list[index] = clinic;
    } else {
      list.add(clinic);
    }
    return list;
  }
}
