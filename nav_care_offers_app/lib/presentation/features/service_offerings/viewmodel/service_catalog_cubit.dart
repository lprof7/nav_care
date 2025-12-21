import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_catalog_payload.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/services/doctor_services_repository.dart';

class ServiceCatalogState extends Equatable {
  final List<ServiceCategory> catalog;
  final bool isLoading;
  final bool isCreating;
  final Failure? failure;

  const ServiceCatalogState({
    this.catalog = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.failure,
  });

  ServiceCatalogState copyWith({
    List<ServiceCategory>? catalog,
    bool? isLoading,
    bool? isCreating,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ServiceCatalogState(
      catalog: catalog ?? this.catalog,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [catalog, isLoading, isCreating, failure];
}

class ServiceCatalogCubit extends Cubit<ServiceCatalogState> {
  ServiceCatalogCubit(
    this._repository, {
    required this.useHospitalToken,
  }) : super(const ServiceCatalogState());

  final DoctorServicesRepository _repository;
  final bool useHospitalToken;

  Future<void> loadCatalog() async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true, clearFailure: true));
    final result =
        await _repository.fetchServicesCatalog(useHospitalToken: useHospitalToken);
    result.fold(
      onFailure: (failure) => emit(
        state.copyWith(isLoading: false, failure: failure),
      ),
      onSuccess: (services) => emit(
        state.copyWith(
          isLoading: false,
          catalog: services,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<Result<ServiceCategory>> createService(
    ServiceCatalogPayload payload, {
    bool useHospitalToken = true,
  }) async {
    emit(state.copyWith(isCreating: true, clearFailure: true));
    final result = await _repository.createService(
      payload,
      useHospitalToken: useHospitalToken,
    );
    result.fold(
      onFailure: (failure) => emit(
        state.copyWith(isCreating: false, failure: failure),
      ),
      onSuccess: (service) {
        final updated = [
          service,
          ...state.catalog.where((item) => item.id != service.id),
        ];
        emit(
          state.copyWith(
            isCreating: false,
            catalog: updated,
            clearFailure: true,
          ),
        );
      },
    );
    return result;
  }
}
