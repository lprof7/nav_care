import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/data/stats/models/stats_models.dart';

enum DoctorStatsStatus { initial, loading, success, failure }

class DoctorStatsState extends Equatable {
  final DoctorStatsStatus status;
  final DoctorStats? stats;
  final Failure? failure;

  const DoctorStatsState({
    required this.status,
    this.stats,
    this.failure,
  });

  const DoctorStatsState.initial()
      : this(status: DoctorStatsStatus.initial);

  DoctorStatsState copyWith({
    DoctorStatsStatus? status,
    DoctorStats? stats,
    Failure? failure,
  }) {
    return DoctorStatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, stats, failure];
}
