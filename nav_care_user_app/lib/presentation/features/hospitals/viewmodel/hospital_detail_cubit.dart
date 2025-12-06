import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/clinics/clinics_repository.dart';
import 'package:nav_care_user_app/data/doctors/doctors_repository.dart';
import 'package:nav_care_user_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_user_app/data/hospitals/models/hospital_model.dart';
import 'package:nav_care_user_app/data/service_offerings/service_offerings_repository.dart';

import 'hospital_detail_state.dart';

class HospitalDetailCubit extends Cubit<HospitalDetailState> {
  HospitalDetailCubit({
    required HospitalsRepository hospitalsRepository,
    required ClinicsRepository clinicsRepository,
    required DoctorsRepository doctorsRepository,
    required ServiceOfferingsRepository offeringsRepository,
  })  : _hospitalsRepository = hospitalsRepository,
        _clinicsRepository = clinicsRepository,
        _doctorsRepository = doctorsRepository,
        _offeringsRepository = offeringsRepository,
        super(const HospitalDetailState());

  final HospitalsRepository _hospitalsRepository;
  final ClinicsRepository _clinicsRepository;
  final DoctorsRepository _doctorsRepository;
  final ServiceOfferingsRepository _offeringsRepository;

  Future<void> load(String hospitalId) async {
    emit(state.copyWith(
        status: HospitalDetailStatus.loading, clearMessage: true));
    try {
      final clinics = await _clinicsRepository.getHospitalClinics(hospitalId);
      final hospital = await _hospitalsRepository.getHospitalById(hospitalId);
      final doctors =
          await _doctorsRepository.getHospitalDoctors(hospitalId: hospitalId);

      final offerings = await _offeringsRepository.getRecentServiceOfferings(
        providerId: hospitalId,
        limit: 20,
      );

      emit(state.copyWith(
        status: HospitalDetailStatus.success,
        hospital: hospital,
        clinics: clinics.items,
        doctors: doctors,
        offerings: offerings.items,
        clearMessage: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: HospitalDetailStatus.failure,
        message: error.toString(),
      ));
    }
  }
}
