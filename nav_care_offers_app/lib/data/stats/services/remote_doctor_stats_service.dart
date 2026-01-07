import 'package:get_it/get_it.dart';
import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';

import 'doctor_stats_service.dart';

class RemoteDoctorStatsService implements DoctorStatsService {
  RemoteDoctorStatsService(this._apiClient);

  final ApiClient _apiClient;
  final TokenStore _tokenStore = GetIt.I<TokenStore>();

  @override
  Future<Result<Map<String, dynamic>>> fetchDoctorStats() async {
    final token = await _tokenStore.getDoctorToken();
    if (token == null || token.isEmpty) {
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.get(
      _apiClient.apiConfig.doctorStats,
      parser: (data) => data as Map<String, dynamic>,
      useDoctorToken: true,
    );
  }
}
