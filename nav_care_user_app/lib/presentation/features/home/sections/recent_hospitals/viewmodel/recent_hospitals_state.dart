import 'package:equatable/equatable.dart';

import '../../../../../../data/hospitals/models/hospital_model.dart';

enum RecentHospitalsStatus { initial, loading, loaded, failure }

class RecentHospitalsState extends Equatable {
  final RecentHospitalsStatus status;
  final List<HospitalModel> hospitals;
  final String? message;
  final int page;
  final bool hasNextPage;

  const RecentHospitalsState({
    this.status = RecentHospitalsStatus.initial,
    this.hospitals = const [],
    this.message,
    this.page = 1,
    this.hasNextPage = true,
  });

  RecentHospitalsState copyWith({
    RecentHospitalsStatus? status,
    List<HospitalModel>? hospitals,
    String? message,
    int? page,
    bool? hasNextPage,
  }) {
    return RecentHospitalsState(
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
