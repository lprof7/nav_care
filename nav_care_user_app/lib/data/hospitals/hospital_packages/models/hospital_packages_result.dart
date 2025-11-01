import 'hospital_package_model.dart';

class HospitalPackagesResult {
  final List<HospitalPackageModel> packages;
  final String message;

  HospitalPackagesResult({
    required this.packages,
    required this.message,
  });
}
