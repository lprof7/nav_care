import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'hospital_packages_service.dart';

class RemoteHospitalPackagesService implements HospitalPackagesService {
  final ApiClient _api;

  RemoteHospitalPackagesService(this._api);

  @override
  Future<Result<Map<String, dynamic>>> addPackages(
    String hospitalId,
    Map<String, dynamic> body,
  ) {
    return _api.post(
      _api.apiConfig.createHospitalPackages(hospitalId),
      body: body,
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}
