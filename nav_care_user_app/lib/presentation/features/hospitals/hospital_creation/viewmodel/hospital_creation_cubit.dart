import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/hospitals/hospital_creation/hospital_creation_repository.dart';
import 'package:nav_care_user_app/data/hospitals/hospital_creation/models/hospital_creation_result.dart';

abstract class HospitalCreationState {}

class HospitalCreationInitial extends HospitalCreationState {}

class HospitalCreationLoading extends HospitalCreationState {}

class HospitalCreationSuccess extends HospitalCreationState {
  final HospitalCreationResult result;
  HospitalCreationSuccess(this.result);
}

class HospitalCreationFailure extends HospitalCreationState {
  final String message;
  HospitalCreationFailure(this.message);
}

class HospitalCreationCubit extends Cubit<HospitalCreationState> {
  final HospitalCreationRepository _repository;

  HospitalCreationCubit(this._repository) : super(HospitalCreationInitial());

  Future<void> createHospital(Map<String, dynamic> body) async {
    emit(HospitalCreationLoading());
    final result = await _repository.createHospital(body);
    result.fold(
      onFailure: (failure) => emit(HospitalCreationFailure(failure.message)),
      onSuccess: (data) => emit(HospitalCreationSuccess(data)),
    );
  }
}
