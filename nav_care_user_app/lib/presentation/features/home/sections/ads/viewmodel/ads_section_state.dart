part of 'ads_section_cubit.dart';

enum AdsSectionStatus { initial, loading, success, failure }

class AdsSectionState extends Equatable {
  final List<Advertising> advertisings;
  final int page;
  final AdsSectionStatus status;
  final String? message;

  const AdsSectionState({
    this.advertisings = const [],
    this.page = 0,
    this.status = AdsSectionStatus.initial,
    this.message,
  });

  int get currentIndex {
    if (advertisings.isEmpty) return 0;
    final normalized = page % advertisings.length;
    return normalized < 0 ? normalized + advertisings.length : normalized;
  }

  AdsSectionState copyWith({
    List<Advertising>? advertisings,
    int? page,
    AdsSectionStatus? status,
    String? message,
  }) {
    return AdsSectionState(
      advertisings: advertisings ?? this.advertisings,
      page: page ?? this.page,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [advertisings, page, status, message];
}
