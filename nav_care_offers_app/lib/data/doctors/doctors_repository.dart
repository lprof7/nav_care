import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/doctors/services/doctors_service.dart';

class DoctorsRepository {
  final DoctorsService _doctorsService;

  DoctorsRepository(this._doctorsService);

  Future<Result<DoctorListModel>> getHospitalDoctors(String hospitalId) async {
    return _doctorsService.getHospitalDoctors(hospitalId);
  }
}