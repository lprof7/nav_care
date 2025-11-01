import 'package:nav_care_user_app/core/responses/result.dart';

abstract class HospitalCreationService {
  Future<Result<Map<String, dynamic>>> createHospital(
    Map<String, dynamic> body,
  );
}
