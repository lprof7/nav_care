import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/data/stats/models/stats_models.dart';

enum HospitalStatsStatus { initial, loading, success, failure }

class HospitalStatsState extends Equatable {
  final HospitalStatsStatus status;
  final HospitalStats? stats;
  final Failure? failure;

  const HospitalStatsState({
    required this.status,
    this.stats,
    this.failure,
  });

  const HospitalStatsState.initial()
      : this(status: HospitalStatsStatus.initial);

  HospitalStatsState copyWith({
    HospitalStatsStatus? status,
    HospitalStats? stats,
    Failure? failure,
  }) {
    return HospitalStatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, stats, failure];
}
