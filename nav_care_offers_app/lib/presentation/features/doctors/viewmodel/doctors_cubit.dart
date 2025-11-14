import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/doctors/doctors_repository.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/viewmodel/doctors_state.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  final DoctorsRepository _doctorsRepository;

  DoctorsCubit(this._doctorsRepository) : super(const DoctorsState.initial());

  Future<void> getHospitalDoctors(String hospitalId) async {
    emit(const DoctorsState.loading());
    final result = await _doctorsRepository.getHospitalDoctors(hospitalId);
    result.fold(
      onSuccess: (doctorList) => emit(DoctorsState.success(doctorList: doctorList)),
      onFailure: (failure) => emit(DoctorsState.failure(failure: failure)),
    );
  }
}