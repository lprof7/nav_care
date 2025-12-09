import 'package:equatable/equatable.dart';

import '../../../../../../data/service_offerings/models/service_offering_model.dart';

enum RecentServiceOfferingsStatus { initial, loading, loaded, failure }

class RecentServiceOfferingsState extends Equatable {
  final RecentServiceOfferingsStatus status;
  final List<ServiceOfferingModel> offerings;
  final String? message;
  final int page;
  final bool hasNextPage;

  const RecentServiceOfferingsState({
    this.status = RecentServiceOfferingsStatus.initial,
    this.offerings = const [],
    this.message,
    this.page = 1,
    this.hasNextPage = true,
  });

  RecentServiceOfferingsState copyWith({
    RecentServiceOfferingsStatus? status,
    List<ServiceOfferingModel>? offerings,
    String? message,
    int? page,
    bool? hasNextPage,
  }) {
    return RecentServiceOfferingsState(
      status: status ?? this.status,
      offerings: offerings ?? this.offerings,
      message: message ?? this.message,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }

  @override
  List<Object?> get props => [status, offerings, message, page, hasNextPage];
}
