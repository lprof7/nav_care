import 'package:bloc/bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/translation/translation_service.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'package:nav_care_offers_app/data/doctors/become_doctor_repository.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';

part 'become_doctor_state.dart';

class BecomeDoctorCubit extends Cubit<BecomeDoctorState> {
  BecomeDoctorCubit(
    this._repository,
    this._authCubit,
    this._translationService,
  ) : super(const BecomeDoctorState());

  final BecomeDoctorRepository _repository;
  final AuthCubit _authCubit;
  final TranslationService _translationService;

  Future<void> submit({
    required String bioEn,
    XFile? image,
    String? specialty,
    String? availabilityJson,
  }) async {
    emit(state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      clearError: true,
    ));

    final translations = await _translateBio(bioEn);

    final result = await _repository.becomeDoctor(
      bioEn: translations?['en'] ?? bioEn,
      bioFr: translations == null
          ? null
          : translations['fr'] ?? translations['en'] ?? bioEn,
      bioAr: translations == null
          ? null
          : translations['ar'] ?? translations['en'] ?? bioEn,
      image: image,
      specialty: specialty,
      availabilityJson: availabilityJson,
    );
    result.fold(
      onFailure: (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
          isSuccess: false,
        ),
      ),
      onSuccess: (doctor) async {
        await _authCubit.setAuthenticatedUser(doctor.user);
        emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            doctor: doctor,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<Map<String, String>?> _translateBio(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return <String, String>{};
    final result = await _translationService.translate(trimmed);
    return result.fold(
      onFailure: (_) => null, // Proceed with bio_en only on failure
      onSuccess: (data) => data,
    );
  }
}
