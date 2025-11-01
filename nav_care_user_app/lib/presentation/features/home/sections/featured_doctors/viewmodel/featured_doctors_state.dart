import 'package:equatable/equatable.dart';

import '../../../../../../data/doctors/models/doctor_model.dart';

enum FeaturedDoctorsStatus { initial, loading, loaded, failure }

class FeaturedDoctorsState extends Equatable {
  final FeaturedDoctorsStatus status;
  final List<DoctorModel> doctors;
  final String? message;

  const FeaturedDoctorsState({
    this.status = FeaturedDoctorsStatus.initial,
    this.doctors = const [],
    this.message,
  });

  FeaturedDoctorsState copyWith({
    FeaturedDoctorsStatus? status,
    List<DoctorModel>? doctors,
    String? message,
  }) {
    return FeaturedDoctorsState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, doctors, message];
}
