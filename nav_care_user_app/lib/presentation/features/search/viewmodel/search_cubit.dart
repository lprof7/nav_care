import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';
import 'package:nav_care_user_app/data/search/search_repository.dart';
import 'package:nav_care_user_app/presentation/features/search/filter/viewmodel/search_filter_models.dart';

import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required SearchRepository repository})
      : _repository = repository,
        super(const SearchState());

  final SearchRepository _repository;
  Timer? _debounce;
  String _lastSuggestionQuery = '';

  void onQueryChanged(String value) {
    final trimmed = value.trimLeft();
    emit(state.copyWith(
      query: value,
      suggestionsStatus: SuggestionsStatus.idle,
    ));

    if (trimmed.length < 2) {
      _debounce?.cancel();
      emit(state.copyWith(
          suggestions: const [], suggestionsStatus: SuggestionsStatus.idle));
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchSuggestions(trimmed);
    });
  }

  Future<void> _fetchSuggestions(String value) async {
    if (value == _lastSuggestionQuery) return;
    _lastSuggestionQuery = value;
    emit(state.copyWith(suggestionsStatus: SuggestionsStatus.loading));

    final result = await _repository.getSuggestions(query: value);
    result.fold(
      onFailure: (failure) {
        if (value != _lastSuggestionQuery) return;
        emit(
          state.copyWith(
            suggestionsStatus: SuggestionsStatus.failure,
            errorMessage: failure.message,
            resultsByType: const {},
          ),
        );
      },
      onSuccess: (suggestions) {
        if (value != _lastSuggestionQuery) return;
        emit(state.copyWith(
          suggestionsStatus: SuggestionsStatus.loaded,
          suggestions: suggestions,
          clearError: true,
        ));
      },
    );
  }

  Future<void> submitSearch({String? queryOverride}) async {
    final effectiveQuery = queryOverride ?? state.query;
    await _executeSearch(effectiveQuery, state.filters);
  }

  Future<void> applyFilters(SearchFilters filters) async {
    await _executeSearch(state.query, filters, fromFilters: true);
  }

  Future<void> clearFilters() async {
    if (state.filters.isEmpty) return;
    await _executeSearch(state.query, const SearchFilters(),
        fromFilters: true);
  }

  Future<void> _executeSearch(
    String rawQuery,
    SearchFilters filters, {
    bool fromFilters = false,
  }) async {
    _debounce?.cancel();

    final trimmedQuery = rawQuery.trim();
    final params = filters.toQueryParameters();
    if (trimmedQuery.isNotEmpty) {
      params['query'] = trimmedQuery;
    }

    if (params.isEmpty) {
      emit(
        state.copyWith(
          query: trimmedQuery,
          resultsStatus: SearchResultsStatus.initial,
          suggestionsStatus: SuggestionsStatus.idle,
          suggestions: const [],
          resultsByType: const {},
          pagination: null,
          summary: null,
          filters: filters,
          filterStatus:
              fromFilters ? SearchFilterStatus.idle : state.filterStatus,
          clearError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        query: trimmedQuery,
        filters: filters,
        resultsStatus: SearchResultsStatus.loading,
        suggestionsStatus: SuggestionsStatus.idle,
        suggestions: const [],
        clearError: true,
        filterStatus:
            fromFilters ? SearchFilterStatus.applied : state.filterStatus,
      ),
    );

    final result = await _repository.search(query: params);

    result.fold(
      onFailure: (failure) {
        emit(
          state.copyWith(
            resultsStatus: SearchResultsStatus.failure,
            errorMessage: failure.message,
            resultsByType: const {},
            filters: filters,
          ),
        );
      },
      onSuccess: (response) {
        emit(
          state.copyWith(
            resultsStatus: SearchResultsStatus.loaded,
            resultsByType: response.resultsByType,
            pagination: response.pagination,
            summary: response.summary,
            clearError: true,
            filters: filters,
          ),
        );
      },
    );
  }

  void onSuggestionSelected(SearchSuggestion suggestion) {
    emit(state.copyWith(
      query: suggestion.value,
      suggestionsStatus: SuggestionsStatus.loaded,
      suggestions: const [],
    ));
    submitSearch(queryOverride: suggestion.value);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
