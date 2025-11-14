import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';

part 'hospital_detail_state.dart';

class HospitalDetailCubit extends Cubit<HospitalDetailState> {
  HospitalDetailCubit(
    this._repository,
    this._tokenStore, {
    required Hospital initialHospital,
  }) : super(HospitalDetailState(hospital: initialHospital));

  final HospitalsRepository _repository;
  final TokenStore _tokenStore;

  void refreshFromRepository() {
    final updated = _repository.findById(state.hospital.id);
    if (updated != null) {
      emit(state.copyWith(hospital: updated));
    }
  }

  void updateHospital(Hospital hospital) {
    emit(state.copyWith(hospital: hospital));
  }

  Future<void> getHospitalToken() async {
    emit(state.copyWith(isFetchingToken: true));
    final result = await _repository.accessHospitalToken(state.hospital.id);
    result.fold(
      onFailure: (failure) => emit(state.copyWith(
        isFetchingToken: false,
        errorMessage: failure.message,
      )),
      onSuccess: (token) {
        _tokenStore.setToken(token); // Save the token persistently
        emit(state.copyWith(
          isFetchingToken: false,
          hospitalToken: token,
        ));
      },
    );
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
