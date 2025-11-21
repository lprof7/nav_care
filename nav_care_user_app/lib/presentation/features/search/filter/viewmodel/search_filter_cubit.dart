import 'package:flutter_bloc/flutter_bloc.dart';

import 'search_filter_models.dart';
import 'search_filter_state.dart';

class SearchFilterCubit extends Cubit<SearchFilterState> {
  SearchFilterCubit({SearchFilters? initial})
      : super(
          SearchFilterState(
            filters: initial ?? const SearchFilters(),
            initialFilters: initial ?? const SearchFilters(),
          ),
        );

  void resetToInitial() {
    emit(state.copyWith(filters: state.initialFilters));
  }

  void clearAll() {
    emit(
      state.copyWith(
        filters: const SearchFilters(),
      ),
    );
  }

  void updateCity(String value) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(city: value),
      ),
    );
  }

  void updateState(String value) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(state: value),
      ),
    );
  }

  void updateCountry(String value) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(country: value),
      ),
    );
  }

  void updateRatingRange(double minValue, double maxValue) {
    final normalizedMin = minValue <= 0 ? null : minValue;
    final normalizedMax = maxValue >= 5 ? null : maxValue;
    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          minRating: normalizedMin,
          removeMinRating: normalizedMin == null,
          maxRating: normalizedMax,
          removeMaxRating: normalizedMax == null,
        ),
      ),
    );
  }

  void updateMinPrice(double? value) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          minPrice: value,
          removeMinPrice: value == null,
        ),
      ),
    );
  }

  void updateMaxPrice(double? value) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          maxPrice: value,
          removeMaxPrice: value == null,
        ),
      ),
    );
  }

  void toggleCollection(SearchCollection collection) {
    final nextCollections = Set<SearchCollection>.from(state.filters.collections);
    if (nextCollections.contains(collection)) {
      nextCollections.remove(collection);
    } else {
      nextCollections.add(collection);
    }

    emit(
      state.copyWith(
        filters: state.filters.copyWith(collections: nextCollections),
      ),
    );
  }
}
