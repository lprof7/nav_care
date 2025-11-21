import 'package:equatable/equatable.dart';

enum SearchSortField {
  relevance,
  rating,
  price,
  distance,
  name,
}

extension SearchSortFieldX on SearchSortField {
  String get apiValue {
    switch (this) {
      case SearchSortField.relevance:
        return 'relevance';
      case SearchSortField.rating:
        return 'rating';
      case SearchSortField.price:
        return 'price';
      case SearchSortField.distance:
        return 'distance';
      case SearchSortField.name:
        return 'name';
    }
  }

  String get labelKey {
    switch (this) {
      case SearchSortField.relevance:
        return 'home.search.filters.sort.relevance';
      case SearchSortField.rating:
        return 'home.search.filters.sort.rating';
      case SearchSortField.price:
        return 'home.search.filters.sort.price';
      case SearchSortField.distance:
        return 'home.search.filters.sort.distance';
      case SearchSortField.name:
        return 'home.search.filters.sort.name';
    }
  }
}

enum SearchSortOrder {
  asc,
  desc,
}

extension SearchSortOrderX on SearchSortOrder {
  String get apiValue => name;

  String get labelKey {
    switch (this) {
      case SearchSortOrder.asc:
        return 'home.search.filters.sort.asc';
      case SearchSortOrder.desc:
        return 'home.search.filters.sort.desc';
    }
  }
}

enum SearchCollection {
  doctors,
  hospitals,
  serviceOfferings,
}

extension SearchCollectionX on SearchCollection {
  String get apiValue {
    switch (this) {
      case SearchCollection.doctors:
        return 'doctors';
      case SearchCollection.hospitals:
        return 'hospitals';
      case SearchCollection.serviceOfferings:
        return 'serviceOfferings';
    }
  }

  String get labelKey {
    switch (this) {
      case SearchCollection.doctors:
        return 'home.search.filters.collections.doctors';
      case SearchCollection.hospitals:
        return 'home.search.filters.collections.hospitals';
      case SearchCollection.serviceOfferings:
        return 'home.search.filters.collections.services';
    }
  }
}

class SearchFilters extends Equatable {
  final String city;
  final String state;
  final String country;
  final double? minRating;
  final double? maxRating;
  final double? minPrice;
  final double? maxPrice;
  final Set<SearchCollection> collections;

  const SearchFilters({
    this.city = '',
    this.state = '',
    this.country = '',
    this.minRating,
    this.maxRating,
    this.minPrice,
    this.maxPrice,
    this.collections = const {},
  });

  SearchFilters copyWith({
    String? city,
    String? state,
    String? country,
    double? minRating,
    bool removeMinRating = false,
    double? maxRating,
    bool removeMaxRating = false,
    double? minPrice,
    bool removeMinPrice = false,
    double? maxPrice,
    bool removeMaxPrice = false,
    Set<SearchCollection>? collections,
  }) {
    Set<SearchCollection> toImmutableSet(
        Set<SearchCollection>? values, Set<SearchCollection> fallback) {
      if (values == null) return fallback;
      return Set<SearchCollection>.unmodifiable(values);
    }

    return SearchFilters(
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      minRating: removeMinRating ? null : minRating ?? this.minRating,
      maxRating: removeMaxRating ? null : maxRating ?? this.maxRating,
      minPrice: removeMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: removeMaxPrice ? null : maxPrice ?? this.maxPrice,
      collections: toImmutableSet(collections, this.collections),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (city.isNotEmpty) params['city'] = city;
    if (state.isNotEmpty) params['state'] = state;
    if (country.isNotEmpty) params['country'] = country;
    if (minRating != null) params['minRating'] = minRating;
    if (maxRating != null) params['maxRating'] = maxRating;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (collections.isNotEmpty) {
      params['collections'] =
          collections.map((collection) => collection.apiValue).toList();
    }

    return params;
  }

  bool get isEmpty =>
      city.isEmpty &&
      state.isEmpty &&
      country.isEmpty &&
      minRating == null &&
      maxRating == null &&
      minPrice == null &&
      maxPrice == null &&
      collections.isEmpty;

  @override
  List<Object?> get props => [
        city,
        state,
        country,
        minRating,
        maxRating,
        minPrice,
        maxPrice,
        List<SearchCollection>.from(collections)
          ..sort((a, b) => a.index.compareTo(b.index)),
      ];
}
