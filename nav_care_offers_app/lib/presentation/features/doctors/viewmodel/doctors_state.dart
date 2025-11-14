import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';

part 'doctors_state.freezed.dart';

@freezed
class DoctorsState with _$DoctorsState {
  const factory DoctorsState.initial() = _Initial;
  const factory DoctorsState.loading() = _Loading;
  const factory DoctorsState.success({required DoctorListModel doctorList}) = _Success;
  const factory DoctorsState.failure({required Failure failure}) = _Failure;
}