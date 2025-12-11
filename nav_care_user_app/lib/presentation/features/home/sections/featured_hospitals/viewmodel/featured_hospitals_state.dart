import 'package:equatable/equatable.dart';

import '../../../../../../data/hospitals/models/hospital_model.dart';

enum FeaturedHospitalsStatus { initial, loading, loaded, failure }

class FeaturedHospitalsState extends Equatable {
  final FeaturedHospitalsStatus status;
  final List<HospitalModel> hospitals;
  final String? message;
  final int page;
  final bool hasNextPage;

  const FeaturedHospitalsState({
    this.status = FeaturedHospitalsStatus.initial,
    this.hospitals = const [],
    this.message,
    this.page = 1,
    this.hasNextPage = true,
  });

  FeaturedHospitalsState copyWith({
    FeaturedHospitalsStatus? status,
    List<HospitalModel>? hospitals,
    String? message,
    int? page,
    bool? hasNextPage,
  }) {
    return FeaturedHospitalsState(
      status: status ?? this.status,
      hospitals: hospitals ?? this.hospitals,
      message: message ?? this.message,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }

  @override
  List<Object?> get props => [status, hospitals, message, page, hasNextPage];
}
