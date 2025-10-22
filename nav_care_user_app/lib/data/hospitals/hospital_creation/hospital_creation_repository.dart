import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/data/hospitals/hospital_creation/models/hospital_creation_result.dart';
import 'package:nav_care_user_app/data/hospitals/hospital_creation/models/hospital_model.dart';
import 'services/hospital_creation_service.dart';

class HospitalCreationRepository {
  final HospitalCreationService _service;

  HospitalCreationRepository(this._service);

  Future<Result<HospitalCreationResult>> createHospital(
    Map<String, dynamic> body,
  ) async {
    final result = await _service.createHospital(body);

    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      final data = response['data'];
      final message =
          response['message']?.toString() ?? 'Hospital created successfully';

      HospitalModel? hospital;
      if (data is Map<String, dynamic>) {
        try {
          hospital = HospitalModel.fromJson(data);
        } catch (_) {
          hospital = null;
        }
      }

      return Result.success(
        HospitalCreationResult(hospital: hospital, message: message),
      );
    }

    return Result.failure(result.error ?? const Failure.unknown());
  }
}
