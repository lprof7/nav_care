import 'package:nav_care_offers_app/core/config/api_config.dart';
import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';

import 'hospitals_service.dart';

class RemoteHospitalsService implements HospitalsService {
  RemoteHospitalsService(this._apiClient);

  final ApiClient _apiClient;

  ApiConfig get _config => _apiClient.apiConfig;

  @override
  Future<Result<Map<String, dynamic>>> fetchHospitals({
    int? page,
    int? limit,
  }) {
    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;

    return _apiClient.get(
      _config.userHospitals,
      query: query.isEmpty ? null : query,
      parser: _parseMap,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> submitHospital(
      Map<String, dynamic> body) {
    return _apiClient.post(
      _config.hospitals,
      body: body,
      parser: _parseMap,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> deleteHospital(String hospitalId) {
    return _apiClient.delete(
      _config.hospitalById(hospitalId),
      parser: _parseMap,
    );
  }

  Map<String, dynamic> _parseMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, dynamic val) => MapEntry(key.toString(), val),
      );
    }
    return <String, dynamic>{};
  }
}
