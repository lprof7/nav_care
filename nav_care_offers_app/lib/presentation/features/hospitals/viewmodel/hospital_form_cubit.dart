import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart';

part 'hospital_form_state.dart';

class HospitalFormCubit extends Cubit<HospitalFormState> {
  HospitalFormCubit(
    this._repository, {
    Hospital? initialHospital,
  }) : super(HospitalFormState(initialHospital: initialHospital));

  final HospitalsRepository _repository;

  Future<void> submit(HospitalPayload payload) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    final result = await _repository.submitHospital(payload);
    result.fold(
      onFailure: (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      onSuccess: (hospital) => emit(state.copyWith(
        isSubmitting: false,
        lastSaved: hospital,
        submissionSuccess: true,
      )),
    );
  }
}
