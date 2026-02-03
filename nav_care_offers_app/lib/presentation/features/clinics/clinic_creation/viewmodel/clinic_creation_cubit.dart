import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/clinics/clinics_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/core/translation/translation_service.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/clinic_creation/viewmodel/clinic_creation_state.dart'; // Import the state file

class ClinicCreationCubit extends Cubit<ClinicCreationState> {
  ClinicCreationCubit(
    this._clinicsRepository,
    this._translationService,
  ) : super(const ClinicCreationState.initial());

  final ClinicsRepository _clinicsRepository;
  final TranslationService _translationService;

  Future<void> submitClinic(HospitalPayload payload) async {
    emit(const ClinicCreationState.loading());

    // Check if manual translations are provided
    final hasManualAr = payload.descriptionAr != null &&
        payload.descriptionAr!.trim().isNotEmpty;
    final hasManualFr = payload.descriptionFr != null &&
        payload.descriptionFr!.trim().isNotEmpty;

    HospitalPayload updatedPayload;

    if (hasManualAr && hasManualFr) {
      // Use manual translations directly, skip API
      updatedPayload = payload;
    } else {
      // Call translation API for missing translations
      final translations = await _translateDescription(payload.descriptionEn);
      final fallbackDescription = payload.descriptionEn;

      updatedPayload = translations == null
          ? payload.copyWith(
              descriptionEn: fallbackDescription,
              descriptionFr: hasManualFr ? payload.descriptionFr : null,
              descriptionAr: hasManualAr ? payload.descriptionAr : null,
            )
          : payload.copyWith(
              descriptionEn: translations['en'] ?? fallbackDescription,
              descriptionFr: hasManualFr
                  ? payload.descriptionFr
                  : (translations['fr'] ??
                      translations['en'] ??
                      fallbackDescription),
              descriptionAr: hasManualAr
                  ? payload.descriptionAr
                  : (translations['ar'] ??
                      translations['en'] ??
                      fallbackDescription),
            );
    }

    final result = await _clinicsRepository.createClinic(updatedPayload);
    result.fold(
      onSuccess: (clinic) => emit(ClinicCreationState.success(clinic: clinic)),
      onFailure: (failure) =>
          emit(ClinicCreationState.failure(failure: failure)),
    );
  }

  Future<Map<String, String>?> _translateDescription(String? text) async {
    final trimmed = text?.trim() ?? '';
    if (trimmed.isEmpty) return <String, String>{};
    final translationResult = await _translationService.translate(trimmed);
    return translationResult.fold(
      onFailure: (_) => null, // Continue with description_en only on failure
      onSuccess: (data) => data,
    );
  }
}
