import 'package:equatable/equatable.dart';

import '../../../../../../data/doctors/models/doctor_model.dart';

enum DoctorsChoiceStatus { initial, loading, loaded, failure }

class DoctorsChoiceState extends Equatable {
  final DoctorsChoiceStatus status;
  final List<DoctorModel> doctors;
  final String? message;
  final int page;
  final bool hasNextPage;

  const DoctorsChoiceState({
    this.status = DoctorsChoiceStatus.initial,
    this.doctors = const [],
    this.message,
    this.page = 1,
    this.hasNextPage = true,
  });

  DoctorsChoiceState copyWith({
    DoctorsChoiceStatus? status,
    List<DoctorModel>? doctors,
    String? message,
    int? page,
    bool? hasNextPage,
  }) {
    return DoctorsChoiceState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      message: message ?? this.message,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }

  @override
  List<Object?> get props => [status, doctors, message, page, hasNextPage];
}
