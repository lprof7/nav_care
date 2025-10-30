import 'package:equatable/equatable.dart';

import '../../../../../../data/hospitals/models/hospital_model.dart';

enum FeaturedClinicsStatus { initial, loading, loaded, failure }

class FeaturedClinicsState extends Equatable {
  final FeaturedClinicsStatus status;
  final List<HospitalModel> clinics;
  final String? message;

  const FeaturedClinicsState({
    this.status = FeaturedClinicsStatus.initial,
    this.clinics = const [],
    this.message,
  });

  FeaturedClinicsState copyWith({
    FeaturedClinicsStatus? status,
    List<HospitalModel>? clinics,
    String? message,
  }) {
    return FeaturedClinicsState(
      status: status ?? this.status,
      clinics: clinics ?? this.clinics,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, clinics, message];
}
