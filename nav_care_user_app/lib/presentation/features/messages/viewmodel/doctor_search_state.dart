import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/core/responses/pagination.dart';
import 'package:nav_care_user_app/data/doctors/models/doctor_model.dart';

enum DoctorSearchStatus { idle, loading, success, failure }

class DoctorSearchState extends Equatable {
  final DoctorSearchStatus status;
  final String query;
  final List<DoctorModel> doctors;
  final PageMeta? pagination;
  final String? errorMessage;
  final bool isLoadingMore;

  const DoctorSearchState({
    this.status = DoctorSearchStatus.idle,
    this.query = '',
    this.doctors = const [],
    this.pagination,
    this.errorMessage,
    this.isLoadingMore = false,
  });

  bool get hasMore => pagination?.hasNextPage ?? false;

  DoctorSearchState copyWith({
    DoctorSearchStatus? status,
    String? query,
    List<DoctorModel>? doctors,
    PageMeta? pagination,
    String? errorMessage,
    bool? isLoadingMore,
  }) {
    return DoctorSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      doctors: doctors ?? this.doctors,
      pagination: pagination ?? this.pagination,
      errorMessage: errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        status,
        query,
        doctors,
        pagination,
        errorMessage,
        isLoadingMore,
      ];
}
