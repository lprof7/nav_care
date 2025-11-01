import 'hospital_model.dart';

class HospitalCreationResult {
  final HospitalModel? hospital;
  final String message;

  HospitalCreationResult({
    this.hospital,
    required this.message,
  });
}
