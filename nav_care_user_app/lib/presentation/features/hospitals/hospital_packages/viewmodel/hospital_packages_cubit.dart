import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/hospitals/hospital_packages/hospital_packages_repository.dart';
import 'package:nav_care_user_app/data/hospitals/hospital_packages/models/hospital_packages_result.dart';

abstract class HospitalPackagesState {}

class HospitalPackagesInitial extends HospitalPackagesState {}

class HospitalPackagesLoading extends HospitalPackagesState {}

class HospitalPackagesSuccess extends HospitalPackagesState {
  final HospitalPackagesResult result;
  HospitalPackagesSuccess(this.result);
}

class HospitalPackagesFailure extends HospitalPackagesState {
  final String message;
  HospitalPackagesFailure(this.message);
}

class HospitalPackagesCubit extends Cubit<HospitalPackagesState> {
  final HospitalPackagesRepository _repository;

  HospitalPackagesCubit(this._repository) : super(HospitalPackagesInitial());

  Future<void> addPackages(String hospitalId, Map<String, dynamic> body) async {
    emit(HospitalPackagesLoading());
    final result = await _repository.addPackages(hospitalId, body);
    result.fold(
      onFailure: (failure) => emit(HospitalPackagesFailure(failure.message)),
      onSuccess: (data) => emit(HospitalPackagesSuccess(data)),
    );
  }
}
