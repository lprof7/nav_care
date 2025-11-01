import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/data/hospitals/hospital_packages/models/hospital_package_model.dart';
import 'package:nav_care_user_app/data/hospitals/hospital_packages/models/hospital_packages_result.dart';
import 'services/hospital_packages_service.dart';

class HospitalPackagesRepository {
  final HospitalPackagesService _service;

  HospitalPackagesRepository(this._service);

  Future<Result<HospitalPackagesResult>> addPackages(
    String hospitalId,
    Map<String, dynamic> body,
  ) async {
    final result = await _service.addPackages(hospitalId, body);
    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      final message =
          response['message']?.toString() ?? 'Packages added successfully';
      final data = response['data'];
      final packages = <HospitalPackageModel>[];

      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            try {
              packages.add(HospitalPackageModel.fromJson(item));
            } catch (_) {
              continue;
            }
          }
        }
      } else if (data is Map<String, dynamic>) {
        try {
          packages.add(HospitalPackageModel.fromJson(data));
        } catch (_) {}
      }

      return Result.success(
        HospitalPackagesResult(packages: packages, message: message),
      );
    }

    return Result.failure(result.error ?? const Failure.unknown());
  }
}
