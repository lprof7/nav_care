import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/services/doctor_services_repository.dart';
import 'package:nav_care_offers_app/data/services/models/doctor_service.dart';
import 'package:nav_care_offers_app/data/services/models/pagination.dart';

part 'doctor_services_state.dart';

class DoctorServicesCubit extends Cubit<DoctorServicesState> {
  DoctorServicesCubit(this._repository) : super(DoctorServicesInitial());

  final DoctorServicesRepository _repository;

  Future<void> fetchServices({int? page, int? limit, bool? active}) async {
    emit(DoctorServicesLoading());
    final result = await _repository.fetchServices(
      page: page,
      limit: limit,
      active: active,
    );
    result.fold(
      onFailure: (failure) =>
          emit(DoctorServicesFailure(message: failure.message)),
      onSuccess: (data) => emit(
        DoctorServicesSuccess(
          services: data.services,
          pagination: data.pagination,
        ),
      ),
    );
  }
}
