import 'package:get_it/get_it.dart';
import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';

import 'hospital_stats_service.dart';

class RemoteHospitalStatsService implements HospitalStatsService {
  RemoteHospitalStatsService(this._apiClient);

  final ApiClient _apiClient;
  final TokenStore _tokenStore = GetIt.I<TokenStore>();

  @override
  Future<Result<Map<String, dynamic>>> fetchHospitalStats() async {
    var token = await _tokenStore.getHospitalToken();
    if (token == null || token.isEmpty) {
      token = await _tokenStore.getClinicToken();
    }
    if (token == null || token.isEmpty) {
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.get(
      _apiClient.apiConfig.hospitalStats,
      parser: (data) => data as Map<String, dynamic>,
      useHospitalToken: true,
    );
  }
}
