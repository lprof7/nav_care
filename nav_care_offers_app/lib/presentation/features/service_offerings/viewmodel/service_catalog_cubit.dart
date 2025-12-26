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
  final bool isLoadingMore;
  final int page;
  final bool hasNext;
  final bool isCreating;
  final Failure? failure;

  const ServiceCatalogState({
    this.catalog = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.page = 1,
    this.hasNext = true,
    this.isCreating = false,
    this.failure,
  });

  ServiceCatalogState copyWith({
    List<ServiceCategory>? catalog,
    bool? isLoading,
    bool? isLoadingMore,
    int? page,
    bool? hasNext,
    bool? isCreating,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ServiceCatalogState(
      catalog: catalog ?? this.catalog,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isCreating: isCreating ?? this.isCreating,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
        catalog,
        isLoading,
        isLoadingMore,
        page,
        hasNext,
        isCreating,
        failure,
      ];
}

class ServiceCatalogCubit extends Cubit<ServiceCatalogState> {
  ServiceCatalogCubit(
    this._repository, {
    required this.useHospitalToken,
  }) : super(const ServiceCatalogState());

  final DoctorServicesRepository _repository;
  final bool useHospitalToken;
  static const int _pageSize = 20;

  Future<void> loadCatalog({bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;
    if (!refresh && !state.hasNext) return;

    final nextPage = (refresh || state.catalog.isEmpty) ? 1 : state.page + 1;
    emit(state.copyWith(
      isLoading: refresh || state.catalog.isEmpty,
      isLoadingMore: !refresh && state.catalog.isNotEmpty,
      clearFailure: true,
    ));

    final result = await _repository.fetchServicesCatalog(
      page: nextPage,
      limit: _pageSize,
      useHospitalToken: useHospitalToken,
    );
    result.fold(
      onFailure: (failure) => emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          failure: failure,
        ),
      ),
      onSuccess: (payload) {
        final services = payload.services;
        final merged = refresh || state.catalog.isEmpty
            ? services
            : [
                ...state.catalog,
                ...services.where(
                  (item) =>
                      state.catalog.indexWhere((c) => c.id == item.id) < 0,
                ),
              ];
        final hasNext = payload.pagination != null
            ? payload.pagination!.page < payload.pagination!.totalPages
            : services.length >= _pageSize;

        emit(state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          catalog: merged,
          page: payload.pagination?.page ?? nextPage,
          hasNext: hasNext,
          clearFailure: true,
        ));
      },
    );
  }

  Future<void> loadMore() => loadCatalog();

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
