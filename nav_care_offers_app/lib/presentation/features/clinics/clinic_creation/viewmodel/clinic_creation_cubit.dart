import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/clinics/clinics_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/clinic_creation/viewmodel/clinic_creation_state.dart'; // Import the state file

class ClinicCreationCubit extends Cubit<ClinicCreationState> {
  ClinicCreationCubit(this._clinicsRepository)
      : super(const ClinicCreationState.initial());

  final ClinicsRepository _clinicsRepository;

  Future<void> submitClinic(HospitalPayload payload) async {
    emit(const ClinicCreationState.loading());
    final result = await _clinicsRepository.submitClinic(payload);
    result.fold(
      onSuccess: (clinic) => emit(ClinicCreationState.success(clinic: clinic)),
      onFailure: (failure) =>
          emit(ClinicCreationState.failure(failure: failure)),
    );
  }
}
