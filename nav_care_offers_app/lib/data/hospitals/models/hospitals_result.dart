import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/data/services/models/pagination.dart';

import 'hospital.dart';

class HospitalsResult extends Equatable {
  final List<Hospital> hospitals;
  final Pagination? pagination;

  const HospitalsResult({
    required this.hospitals,
    this.pagination,
  });

  HospitalsResult copyWith({
    List<Hospital>? hospitals,
    Pagination? pagination,
  }) {
    return HospitalsResult(
      hospitals: hospitals ?? this.hospitals,
      pagination: pagination ?? this.pagination,
    );
  }

  @override
  List<Object?> get props => [hospitals, pagination];
}
