import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/translation/translation_service.dart';
import 'package:nav_care_offers_app/data/services/doctor_services_repository.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering_payload.dart';
import 'package:nav_care_offers_app/data/service_offerings/service_offerings_repository.dart';

enum ServiceOfferingFormMode { create, edit }

class ServiceOfferingFormCubit extends Cubit<ServiceOfferingFormState> {
  ServiceOfferingFormCubit(
    this._repository, {
    required DoctorServicesRepository servicesRepository,
    required TranslationService translationService,
    ServiceOffering? initial,
    this.useHospitalToken = true,
  })  : _translationService = translationService,
        _servicesRepository = servicesRepository,
        super(ServiceOfferingFormState(
          mode: initial == null
              ? ServiceOfferingFormMode.create
              : ServiceOfferingFormMode.edit,
          initial: initial,
          catalog: initial == null ? const [] : _initialCatalog(initial),
        ));

  final ServiceOfferingsRepository _repository;
  final TranslationService _translationService;
  final DoctorServicesRepository _servicesRepository;
  final bool useHospitalToken;

  static List<ServiceCategory> _initialCatalog(ServiceOffering offering) {
    return [offering.service];
  }

  Future<void> loadCatalog() async {
    if (state.isCatalogLoading) return;
    emit(state.copyWith(isCatalogLoading: true, clearFailure: true));
    final result =
        await _servicesRepository.fetchServicesCatalog(useHospitalToken: useHospitalToken);
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
    String? nameEn,
    String? nameFr,
    String? nameAr,
    List<XFile>? images,
  }) async {
    emit(state.copyWith(
      isSubmitting: true,
      clearFailure: true,
      isSuccess: false,
    ));

    final nameTranslations = await _translateText(nameEn);
    final descriptionTranslations = await _translateText(descriptionEn);

    final payload = ServiceOfferingPayload(
      serviceId: serviceId,
      price: price,
      offers: offers?.trim().isEmpty ?? true ? null : offers?.trim(),
      descriptionEn: descriptionTranslations?['en'] ?? descriptionEn,
      descriptionFr: descriptionTranslations == null
          ? null
          : descriptionTranslations['fr'] ??
              descriptionTranslations['en'] ??
              descriptionEn,
      descriptionAr: descriptionTranslations == null
          ? null
          : descriptionTranslations['ar'] ??
              descriptionTranslations['en'] ??
              descriptionEn,
      descriptionSp: descriptionSp,
      nameEn: nameTranslations?['en'] ?? nameEn,
      nameFr: nameTranslations == null
          ? null
          : nameTranslations['fr'] ?? nameTranslations['en'] ?? nameEn,
      nameAr: nameTranslations == null
          ? null
          : nameTranslations['ar'] ?? nameTranslations['en'] ?? nameEn,
      images: images,
    );

    final result = state.mode == ServiceOfferingFormMode.create
        ? await _repository.createOffering(
            payload,
            useHospitalToken: useHospitalToken,
          )
        : await _repository.updateOffering(
            state.initial!.id,
            payload,
            useHospitalToken: useHospitalToken,
          );

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

  Future<Map<String, String>?> _translateText(String? text) async {
    final trimmed = text?.trim() ?? '';
    if (trimmed.isEmpty) return <String, String>{};
    final result = await _translationService.translate(trimmed);
    return result.fold(
      onFailure: (_) => null, // On failure fall back to en only
      onSuccess: (data) => data,
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
