import 'package:nav_care_user_app/core/responses/result.dart';

abstract class HospitalPackagesService {
  Future<Result<Map<String, dynamic>>> addPackages(
    String hospitalId,
    Map<String, dynamic> body,
  );
}
