import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';

part 'clinics_state.freezed.dart';

@freezed
class ClinicsState with _$ClinicsState {
  const factory ClinicsState.initial() = _Initial;
  const factory ClinicsState.loading() = _Loading;
  const factory ClinicsState.success({required ClinicListModel clinicList}) = _Success;
  const factory ClinicsState.failure({required Failure failure}) = _Failure;
}