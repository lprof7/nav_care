import 'package:equatable/equatable.dart';

import '../../../../../../data/hospitals/models/hospital_model.dart';

enum HospitalsChoiceStatus { initial, loading, loaded, failure }

class HospitalsChoiceState extends Equatable {
  final HospitalsChoiceStatus status;
  final List<HospitalModel> hospitals;
  final String? message;

  const HospitalsChoiceState({
    this.status = HospitalsChoiceStatus.initial,
    this.hospitals = const [],
    this.message,
  });

  HospitalsChoiceState copyWith({
    HospitalsChoiceStatus? status,
    List<HospitalModel>? hospitals,
    String? message,
  }) {
    return HospitalsChoiceState(
      status: status ?? this.status,
      hospitals: hospitals ?? this.hospitals,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, hospitals, message];
}
