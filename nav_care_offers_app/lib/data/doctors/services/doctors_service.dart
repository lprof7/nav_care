import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';

abstract class DoctorsService {
  Future<Result<DoctorListModel>> listDoctors({int page = 1, int limit = 10});
  Future<Result<DoctorListModel>> getHospitalDoctors(String hospitalId);
  Future<Result<DoctorModel>> getDoctorById(String doctorId);
  Future<Result<Map<String, dynamic>>> searchDoctorsCollection({
    required String query,
    int page = 1,
    int limit = 20,
  });
}
