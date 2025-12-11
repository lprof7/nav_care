import 'package:equatable/equatable.dart';

import '../../../../../../data/hospitals/models/hospital_model.dart';

enum HospitalsChoiceStatus { initial, loading, loaded, failure }

class HospitalsChoiceState extends Equatable {
  final HospitalsChoiceStatus status;
  final List<HospitalModel> hospitals;
  final String? message;
  final int page;
  final bool hasNextPage;

  const HospitalsChoiceState({
    this.status = HospitalsChoiceStatus.initial,
    this.hospitals = const [],
    this.message,
    this.page = 1,
    this.hasNextPage = true,
  });

  HospitalsChoiceState copyWith({
    HospitalsChoiceStatus? status,
    List<HospitalModel>? hospitals,
    String? message,
    int? page,
    bool? hasNextPage,
  }) {
    return HospitalsChoiceState(
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
