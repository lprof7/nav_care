import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';

part 'hospital_detail_state.dart';

class HospitalDetailCubit extends Cubit<HospitalDetailState> {
  HospitalDetailCubit(
    this._repository, {
    required Hospital initialHospital,
  }) : super(HospitalDetailState(hospital: initialHospital));

  final HospitalsRepository _repository;

  void refreshFromRepository() {
    final updated = _repository.findById(state.hospital.id);
    if (updated != null) {
      emit(state.copyWith(hospital: updated));
    }
  }

  void updateHospital(Hospital hospital) {
    emit(state.copyWith(hospital: hospital));
  }

  Future<void> deleteHospital() async {
    emit(state.copyWith(isDeleting: true, errorMessage: null, successMessageKey: null));
    final result = await _repository.deleteHospital(state.hospital.id);
    result.fold(
      onFailure: (failure) => emit(state.copyWith(
        isDeleting: false,
        errorMessage: failure.message,
      )),
      onSuccess: (_) => emit(
        state.copyWith(
          isDeleting: false,
          isDeleted: true,
          successMessageKey: 'hospitals.detail.delete_success',
        ),
      ),
    );
  }
}
