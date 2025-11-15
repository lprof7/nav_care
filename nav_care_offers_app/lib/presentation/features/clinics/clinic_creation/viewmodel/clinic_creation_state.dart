import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';

part 'clinic_creation_state.freezed.dart';

@freezed
class ClinicCreationState with _$ClinicCreationState {
  const factory ClinicCreationState.initial() = _Initial;
  const factory ClinicCreationState.loading() = _Loading;
  const factory ClinicCreationState.success({required ClinicModel clinic}) =
      _Success;
  const factory ClinicCreationState.failure({required Failure failure}) =
      _Failure;
}
