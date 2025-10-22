import 'package:equatable/equatable.dart';

import '../../../../../../data/doctors/models/doctor_model.dart';

enum DoctorsChoiceStatus { initial, loading, loaded, failure }

class DoctorsChoiceState extends Equatable {
  final DoctorsChoiceStatus status;
  final List<DoctorModel> doctors;
  final String? message;

  const DoctorsChoiceState({
    this.status = DoctorsChoiceStatus.initial,
    this.doctors = const [],
    this.message,
  });

  DoctorsChoiceState copyWith({
    DoctorsChoiceStatus? status,
    List<DoctorModel>? doctors,
    String? message,
  }) {
    return DoctorsChoiceState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, doctors, message];
}
