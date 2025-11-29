import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';

sealed class ClinicCreationState extends Equatable {
  const ClinicCreationState();

  const factory ClinicCreationState.initial() = ClinicCreationInitial;
  const factory ClinicCreationState.loading() = ClinicCreationLoading;
  const factory ClinicCreationState.success({required ClinicModel clinic}) =
      ClinicCreationSuccess;
  const factory ClinicCreationState.failure({required Failure failure}) =
      ClinicCreationFailure;
}

class ClinicCreationInitial extends ClinicCreationState {
  const ClinicCreationInitial();

  @override
  List<Object?> get props => [];
}

class ClinicCreationLoading extends ClinicCreationState {
  const ClinicCreationLoading();

  @override
  List<Object?> get props => [];
}

class ClinicCreationSuccess extends ClinicCreationState {
  final ClinicModel clinic;

  const ClinicCreationSuccess({required this.clinic});

  @override
  List<Object?> get props => [clinic];
}

class ClinicCreationFailure extends ClinicCreationState {
  final Failure failure;

  const ClinicCreationFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}
