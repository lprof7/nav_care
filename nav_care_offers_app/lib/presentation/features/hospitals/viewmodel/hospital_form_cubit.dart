import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/translation/translation_service.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart';

part 'hospital_form_state.dart';

class HospitalFormCubit extends Cubit<HospitalFormState> {
  HospitalFormCubit(
    this._repository, {
    required TranslationService translationService,
    Hospital? initialHospital,
  })  : _translationService = translationService,
        super(HospitalFormState(initialHospital: initialHospital));

  final HospitalsRepository _repository;
  final TranslationService _translationService;

  Future<void> submit(HospitalPayload payload) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    final translations = await _translateDescription(payload.descriptionEn);
    final fallbackDescription = payload.descriptionEn;
    final enrichedPayload = translations == null
        ? payload.copyWith(
            descriptionEn: fallbackDescription,
            descriptionFr: null,
            descriptionAr: null,
          )
        : payload.copyWith(
            descriptionEn: translations['en'] ?? fallbackDescription,
            descriptionFr:
                translations['fr'] ?? translations['en'] ?? fallbackDescription,
            descriptionAr:
                translations['ar'] ?? translations['en'] ?? fallbackDescription,
          );

    final result = state.isEditing
        ? await _repository.updateHospital(enrichedPayload)
        : await _repository.submitHospital(enrichedPayload);
    result.fold(
      onFailure: (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      onSuccess: (hospital) => emit(state.copyWith(
        isSubmitting: false,
        lastSaved: hospital,
        submissionSuccess: true,
      )),
    );
  }

  Future<Map<String, String>?> _translateDescription(String? text) async {
    final trimmed = text?.trim() ?? '';
    if (trimmed.isEmpty) return <String, String>{};
    final translationResult = await _translationService.translate(trimmed);
    return translationResult.fold(
      onFailure: (_) => null, // On translation failure proceed with description_en only
      onSuccess: (data) => data,
    );
  }
}
