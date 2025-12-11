import 'package:equatable/equatable.dart';

import '../../../../../../data/doctors/models/doctor_model.dart';

enum FeaturedDoctorsStatus { initial, loading, loaded, failure }

class FeaturedDoctorsState extends Equatable {
  final FeaturedDoctorsStatus status;
  final List<DoctorModel> doctors;
  final String? message;
  final int page;
  final bool hasNextPage;

  const FeaturedDoctorsState({
    this.status = FeaturedDoctorsStatus.initial,
    this.doctors = const [],
    this.message,
    this.page = 1,
    this.hasNextPage = true,
  });

  FeaturedDoctorsState copyWith({
    FeaturedDoctorsStatus? status,
    List<DoctorModel>? doctors,
    String? message,
    int? page,
    bool? hasNextPage,
  }) {
    return FeaturedDoctorsState(
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
