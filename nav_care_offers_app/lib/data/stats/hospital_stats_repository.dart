import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/stats/models/stats_models.dart';
import 'package:nav_care_offers_app/data/stats/services/hospital_stats_service.dart';

class HospitalStatsRepository {
  HospitalStatsRepository(this._service);

  final HospitalStatsService _service;

  Future<Result<HospitalStats>> fetchHospitalStats() async {
    final response = await _service.fetchHospitalStats();
    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final payload = _extractDataMap(response.data!);
      return Result.success(HospitalStats.fromJson(payload));
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'Unable to parse hospital stats'),
      );
    }
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> json) {
    const candidates = ['data', 'result', 'payload'];
    for (final key in candidates) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }
    return json;
  }
}
