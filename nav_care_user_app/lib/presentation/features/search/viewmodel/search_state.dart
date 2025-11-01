import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';
import 'package:nav_care_user_app/presentation/features/search/filter/viewmodel/search_filter_models.dart';

enum SearchResultsStatus { initial, loading, loaded, failure }

enum SuggestionsStatus { idle, loading, loaded, failure }

enum SearchFilterStatus { idle, applied }

class SearchState extends Equatable {
  final String query;
  final SearchResultsStatus resultsStatus;
  final SuggestionsStatus suggestionsStatus;
  final List<SearchSuggestion> suggestions;
  final Map<SearchResultType, List<SearchResultItem>> resultsByType;
  final String? errorMessage;
  final SearchPagination? pagination;
  final SearchSummary? summary;
  final SearchFilters filters;
  final SearchFilterStatus filterStatus;

  const SearchState({
    this.query = '',
    this.resultsStatus = SearchResultsStatus.initial,
    this.suggestionsStatus = SuggestionsStatus.idle,
    this.suggestions = const [],
    this.resultsByType = const {},
    this.errorMessage,
    this.pagination,
    this.summary,
    this.filters = const SearchFilters(),
    this.filterStatus = SearchFilterStatus.idle,
  });

  SearchState copyWith({
    String? query,
    SearchResultsStatus? resultsStatus,
    SuggestionsStatus? suggestionsStatus,
    List<SearchSuggestion>? suggestions,
    Map<SearchResultType, List<SearchResultItem>>? resultsByType,
    String? errorMessage,
    SearchPagination? pagination,
    SearchSummary? summary,
    SearchFilters? filters,
    SearchFilterStatus? filterStatus,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      resultsStatus: resultsStatus ?? this.resultsStatus,
      suggestionsStatus: suggestionsStatus ?? this.suggestionsStatus,
      suggestions: suggestions ?? this.suggestions,
      resultsByType: resultsByType ?? this.resultsByType,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      pagination: pagination ?? this.pagination,
      summary: summary ?? this.summary,
      filters: filters ?? this.filters,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  @override
  List<Object?> get props => [
        query,
        resultsStatus,
        suggestionsStatus,
        suggestions,
        resultsByType,
        errorMessage,
        pagination,
        summary,
        filters,
        filterStatus,
      ];
}
