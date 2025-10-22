import 'package:nav_care_user_app/core/responses/result.dart';

abstract class ServiceCreationService {
  Future<Result<Map<String, dynamic>>> createService(
    Map<String, dynamic> body,
  );
}
