import 'package:equatable/equatable.dart';

import '../../../../../../data/hospitals/models/hospital_model.dart';

enum FeaturedHospitalsStatus { initial, loading, loaded, failure }

class FeaturedHospitalsState extends Equatable {
  final FeaturedHospitalsStatus status;
  final List<HospitalModel> hospitals;
  final String? message;

  const FeaturedHospitalsState({
    this.status = FeaturedHospitalsStatus.initial,
    this.hospitals = const [],
    this.message,
  });

  FeaturedHospitalsState copyWith({
    FeaturedHospitalsStatus? status,
    List<HospitalModel>? hospitals,
    String? message,
  }) {
    return FeaturedHospitalsState(
      status: status ?? this.status,
      hospitals: hospitals ?? this.hospitals,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, hospitals, message];
}
