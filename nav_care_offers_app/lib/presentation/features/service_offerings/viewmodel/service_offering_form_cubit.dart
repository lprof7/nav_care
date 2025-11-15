import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering_payload.dart';
import 'package:nav_care_offers_app/data/service_offerings/service_offerings_repository.dart';

enum ServiceOfferingFormMode { create, edit }

class ServiceOfferingFormCubit extends Cubit<ServiceOfferingFormState> {
  ServiceOfferingFormCubit(
    this._repository, {
    ServiceOffering? initial,
  }) : super(ServiceOfferingFormState(
          mode: initial == null
              ? ServiceOfferingFormMode.create
              : ServiceOfferingFormMode.edit,
          initial: initial,
          catalog: initial == null ? const [] : _initialCatalog(initial),
        ));

  final ServiceOfferingsRepository _repository;

  static List<ServiceCategory> _initialCatalog(ServiceOffering offering) {
    return [offering.service];
  }

  Future<void> loadCatalog() async {
    if (state.isCatalogLoading) return;
    emit(state.copyWith(isCatalogLoading: true, clearFailure: true));
    final result = await _repository.fetchServicesCatalog();
    result.fold(
      onFailure: (failure) => emit(state.copyWith(
        isCatalogLoading: false,
        failure: failure,
      )),
      onSuccess: (services) {
        final normalized = List<ServiceCategory>.from(services);
        final initialService = state.initial?.service;
        if (initialService != null &&
            normalized.every((element) => element.id != initialService.id)) {
          normalized.insert(0, initialService);
        }
        emit(state.copyWith(
          isCatalogLoading: false,
          catalog: normalized,
          clearFailure: true,
        ));
      },
    );
  }

  Future<void> submit({
    required String serviceId,
    required double price,
    String? offers,
    String? descriptionEn,
    String? descriptionFr,
    String? descriptionAr,
    String? descriptionSp,
  }) async {
    emit(state.copyWith(
      isSubmitting: true,
      clearFailure: true,
      isSuccess: false,
    ));

    final payload = ServiceOfferingPayload(
      serviceId: serviceId,
      price: price,
      offers: offers?.trim().isEmpty ?? true ? null : offers?.trim(),
      descriptionEn: descriptionEn,
      descriptionFr: descriptionFr,
      descriptionAr: descriptionAr,
      descriptionSp: descriptionSp,
    );

    final result = state.mode == ServiceOfferingFormMode.create
        ? await _repository.createOffering(payload)
        : await _repository.updateOffering(state.initial!.id, payload);

    result.fold(
      onFailure: (failure) => emit(
        state.copyWith(isSubmitting: false, failure: failure, isSuccess: false),
      ),
      onSuccess: (offering) => emit(
        state.copyWith(
          isSubmitting: false,
          clearFailure: true,
          isSuccess: true,
          result: offering,
        ),
      ),
    );
  }
}

class ServiceOfferingFormState extends Equatable {
  final ServiceOfferingFormMode mode;
  final ServiceOffering? initial;
  final List<ServiceCategory> catalog;
  final bool isCatalogLoading;
  final bool isSubmitting;
  final bool isSuccess;
  final ServiceOffering? result;
  final Failure? failure;

  const ServiceOfferingFormState({
    required this.mode,
    this.initial,
    this.catalog = const [],
    this.isCatalogLoading = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.result,
    this.failure,
  });

  ServiceOfferingFormState copyWith({
    ServiceOffering? initial,
    List<ServiceCategory>? catalog,
    bool? isCatalogLoading,
    bool? isSubmitting,
    bool? isSuccess,
    ServiceOffering? result,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ServiceOfferingFormState(
      mode: mode,
      initial: initial ?? this.initial,
      catalog: catalog ?? this.catalog,
      isCatalogLoading: isCatalogLoading ?? this.isCatalogLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      result: result ?? this.result,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
        mode,
        initial,
        catalog,
        isCatalogLoading,
        isSubmitting,
        isSuccess,
        result,
        failure,
      ];
}
