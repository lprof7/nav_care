import 'package:equatable/equatable.dart';

import '../../../../../../data/doctors/models/doctor_model.dart';

enum RecentDoctorsStatus { initial, loading, loaded, failure }

class RecentDoctorsState extends Equatable {
  final RecentDoctorsStatus status;
  final List<DoctorModel> doctors;
  final String? message;
  final int page;
  final bool hasNextPage;

  const RecentDoctorsState({
    this.status = RecentDoctorsStatus.initial,
    this.doctors = const [],
    this.message,
    this.page = 1,
    this.hasNextPage = true,
  });

  RecentDoctorsState copyWith({
    RecentDoctorsStatus? status,
    List<DoctorModel>? doctors,
    String? message,
    int? page,
    bool? hasNextPage,
  }) {
    return RecentDoctorsState(
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
