import 'package:equatable/equatable.dart';

import '../../../../../../data/service_offerings/models/service_offering_model.dart';

enum RecentServiceOfferingsStatus { initial, loading, loaded, failure }

class RecentServiceOfferingsState extends Equatable {
  final RecentServiceOfferingsStatus status;
  final List<ServiceOfferingModel> offerings;
  final String? message;

  const RecentServiceOfferingsState({
    this.status = RecentServiceOfferingsStatus.initial,
    this.offerings = const [],
    this.message,
  });

  RecentServiceOfferingsState copyWith({
    RecentServiceOfferingsStatus? status,
    List<ServiceOfferingModel>? offerings,
    String? message,
  }) {
    return RecentServiceOfferingsState(
      status: status ?? this.status,
      offerings: offerings ?? this.offerings,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, offerings, message];
}
