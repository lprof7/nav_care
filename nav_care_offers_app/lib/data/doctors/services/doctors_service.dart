import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';

abstract class DoctorsService {
  Future<Result<DoctorListModel>> getHospitalDoctors(String hospitalId);
}