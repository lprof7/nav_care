import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/doctors/services/doctors_service.dart';

class RemoteDoctorsService implements DoctorsService {
  final ApiClient _apiClient;

  RemoteDoctorsService(this._apiClient);

  @override
  Future<Result<DoctorListModel>> listDoctors({
    int page = 1,
    int limit = 10,
  }) async {
    return _apiClient.get(
      _apiClient.apiConfig.doctors,
      query: {'page': page, 'limit': limit},
      parser: _parseDoctorList,
    );
  }

  @override
  Future<Result<DoctorListModel>> getHospitalDoctors(String hospitalId) async {
    return _apiClient.get(
      '/api/hospitals/$hospitalId/doctors',
      parser: _parseDoctorList,
      useHospitalToken: true, // Use hospital token for this API call
    );
  }

  DoctorListModel _parseDoctorList(dynamic json) {
    if (json is Map<String, dynamic>) {
      final dataMap = json['data'] is Map<String, dynamic> ? json['data'] : json;
      return DoctorListModel.fromJson(
          dataMap is Map<String, dynamic> ? dataMap : <String, dynamic>{});
    }
    return DoctorListModel.fromJson(<String, dynamic>{'data': [], 'pagination': {}});
  }

  @override
  Future<Result<DoctorModel>> getDoctorById(String doctorId) {
    return _apiClient.get(
      _apiClient.apiConfig.doctorById(doctorId),
      parser: _parseDoctorDetail,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> searchDoctorsCollection({
    required String query,
    int page = 1,
    int limit = 20,
  }) {
    return _apiClient.get<Map<String, dynamic>>(
      _apiClient.apiConfig.searchDoctorsCollection,
      query: {
        'query': query,
        'page': page,
        'limit': limit,
      },
      parser: (json) =>
          json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  DoctorModel _parseDoctorDetail(dynamic json) {
    if (json is Map<String, dynamic>) {
      final data = json['data'];
      if (data is Map<String, dynamic>) {
        final doctorMap = data['doctor'] ?? data['data'] ?? data;
        if (doctorMap is Map<String, dynamic>) {
          return DoctorModel.fromJson(doctorMap);
        }
      }
      final doctorMap = json['doctor'] ?? json['data'];
      if (doctorMap is Map<String, dynamic>) {
        return DoctorModel.fromJson(doctorMap);
      }
    }
    return DoctorModel.fromJson(<String, dynamic>{});
  }
}
