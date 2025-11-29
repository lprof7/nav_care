import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';

sealed class DoctorsState extends Equatable {
  const DoctorsState();

  const factory DoctorsState.initial() = DoctorsInitial;
  const factory DoctorsState.loading() = DoctorsLoading;
  const factory DoctorsState.success({required DoctorListModel doctorList}) =
      DoctorsSuccess;
  const factory DoctorsState.failure({required Failure failure}) =
      DoctorsFailure;
}

class DoctorsInitial extends DoctorsState {
  const DoctorsInitial();

  @override
  List<Object?> get props => [];
}

class DoctorsLoading extends DoctorsState {
  const DoctorsLoading();

  @override
  List<Object?> get props => [];
}

class DoctorsSuccess extends DoctorsState {
  final DoctorListModel doctorList;

  const DoctorsSuccess({required this.doctorList});

  @override
  List<Object?> get props => [doctorList];
}

class DoctorsFailure extends DoctorsState {
  final Failure failure;

  const DoctorsFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}
