import 'package:equatable/equatable.dart';

import 'search_filter_models.dart';

class SearchFilterState extends Equatable {
  final SearchFilters filters;
  final SearchFilters initialFilters;

  const SearchFilterState({
    this.filters = const SearchFilters(),
    this.initialFilters = const SearchFilters(),
  });

  bool get hasChanges => filters != initialFilters;

  SearchFilterState copyWith({
    SearchFilters? filters,
    SearchFilters? initialFilters,
  }) {
    return SearchFilterState(
      filters: filters ?? this.filters,
      initialFilters: initialFilters ?? this.initialFilters,
    );
  }

  @override
  List<Object?> get props => [filters, initialFilters];
}
