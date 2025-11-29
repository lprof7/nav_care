import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';

sealed class ClinicsState extends Equatable {
  const ClinicsState();

  const factory ClinicsState.initial() = ClinicsInitial;
  const factory ClinicsState.loading() = ClinicsLoading;
  const factory ClinicsState.success({required ClinicListModel clinicList}) =
      ClinicsSuccess;
  const factory ClinicsState.failure({required Failure failure}) =
      ClinicsFailure;
}

class ClinicsInitial extends ClinicsState {
  const ClinicsInitial();

  @override
  List<Object?> get props => [];
}

class ClinicsLoading extends ClinicsState {
  const ClinicsLoading();

  @override
  List<Object?> get props => [];
}

class ClinicsSuccess extends ClinicsState {
  final ClinicListModel clinicList;

  const ClinicsSuccess({required this.clinicList});

  @override
  List<Object?> get props => [clinicList];
}

class ClinicsFailure extends ClinicsState {
  final Failure failure;

  const ClinicsFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}
