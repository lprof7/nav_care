import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/clinics/clinics_repository.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/viewmodel/clinics_state.dart';

class ClinicsCubit extends Cubit<ClinicsState> {
  final ClinicsRepository _clinicsRepository;

  ClinicsCubit(this._clinicsRepository) : super(const ClinicsState.initial());

  Future<void> getHospitalClinics(String hospitalId) async {
    emit(const ClinicsState.loading());
    final result = await _clinicsRepository.getHospitalClinics(hospitalId);
    result.fold(
      onSuccess: (clinicList) => emit(ClinicsState.success(clinicList: clinicList)),
      onFailure: (failure) => emit(ClinicsState.failure(failure: failure)),
    );
  }
}