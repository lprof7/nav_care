import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/doctors/services/doctors_service.dart';

class DoctorsRepository {
  final DoctorsService _doctorsService;

  DoctorsRepository(this._doctorsService);

  Future<Result<DoctorListModel>> listDoctors({
    int page = 1,
    int limit = 10,
  }) {
    return _doctorsService.listDoctors(page: page, limit: limit);
  }

  Future<Result<DoctorListModel>> getHospitalDoctors(String hospitalId) async {
    return _doctorsService.getHospitalDoctors(hospitalId);
  }

  Future<Result<DoctorModel>> getDoctorById(String doctorId) {
    return _doctorsService.getDoctorById(doctorId);
  }
}
