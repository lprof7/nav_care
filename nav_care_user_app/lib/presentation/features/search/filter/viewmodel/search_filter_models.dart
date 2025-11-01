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
  final double? radius;
  final String city;
  final String state;
  final String country;
  final double? minRating;
  final double? maxRating;
  final double? minPrice;
  final double? maxPrice;
  final String facilityType;
  final List<String> languages;
  final List<String> insuranceAccepted;
  final SearchSortField? sortBy;
  final SearchSortOrder? sortOrder;
  final Set<SearchCollection> collections;

  const SearchFilters({
    this.radius,
    this.city = '',
    this.state = '',
    this.country = '',
    this.minRating,
    this.maxRating,
    this.minPrice,
    this.maxPrice,
    this.facilityType = '',
    this.languages = const [],
    this.insuranceAccepted = const [],
    this.sortBy,
    this.sortOrder,
    this.collections = const {},
  });

  SearchFilters copyWith({
    double? radius,
    bool removeRadius = false,
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
    String? facilityType,
    List<String>? languages,
    List<String>? insuranceAccepted,
    SearchSortField? sortBy,
    bool removeSortBy = false,
    SearchSortOrder? sortOrder,
    bool removeSortOrder = false,
    Set<SearchCollection>? collections,
  }) {
    List<String> toImmutableList(List<String>? values, List<String> fallback) {
      if (values == null) return fallback;
      return List<String>.unmodifiable(values);
    }

    Set<SearchCollection> toImmutableSet(
        Set<SearchCollection>? values, Set<SearchCollection> fallback) {
      if (values == null) return fallback;
      return Set<SearchCollection>.unmodifiable(values);
    }

    return SearchFilters(
      radius: removeRadius ? null : radius ?? this.radius,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      minRating: removeMinRating ? null : minRating ?? this.minRating,
      maxRating: removeMaxRating ? null : maxRating ?? this.maxRating,
      minPrice: removeMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: removeMaxPrice ? null : maxPrice ?? this.maxPrice,
      facilityType: facilityType ?? this.facilityType,
      languages: toImmutableList(languages, this.languages),
      insuranceAccepted:
          toImmutableList(insuranceAccepted, this.insuranceAccepted),
      sortBy: removeSortBy ? null : sortBy ?? this.sortBy,
      sortOrder: removeSortOrder ? null : sortOrder ?? this.sortOrder,
      collections: toImmutableSet(collections, this.collections),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (radius != null) params['radius'] = radius;
    if (city.isNotEmpty) params['city'] = city;
    if (state.isNotEmpty) params['state'] = state;
    if (country.isNotEmpty) params['country'] = country;
    if (minRating != null) params['minRating'] = minRating;
    if (maxRating != null) params['maxRating'] = maxRating;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (facilityType.isNotEmpty) params['facilityType'] = facilityType;
    if (languages.isNotEmpty) params['languages'] = languages;
    if (insuranceAccepted.isNotEmpty) {
      params['insuranceAccepted'] = insuranceAccepted;
    }
    if (sortBy != null) params['sortBy'] = sortBy!.apiValue;
    if (sortOrder != null) params['sortOrder'] = sortOrder!.apiValue;
    if (collections.isNotEmpty) {
      params['collections'] =
          collections.map((collection) => collection.apiValue).toList();
    }

    return params;
  }

  bool get isEmpty =>
      radius == null &&
      city.isEmpty &&
      state.isEmpty &&
      country.isEmpty &&
      minRating == null &&
      maxRating == null &&
      minPrice == null &&
      maxPrice == null &&
      facilityType.isEmpty &&
      languages.isEmpty &&
      insuranceAccepted.isEmpty &&
      sortBy == null &&
      sortOrder == null &&
      collections.isEmpty;

  @override
  List<Object?> get props => [
        radius,
        city,
        state,
        country,
        minRating,
        maxRating,
        minPrice,
        maxPrice,
        facilityType,
        languages,
        insuranceAccepted,
        sortBy,
        sortOrder,
        List<SearchCollection>.from(collections)
          ..sort((a, b) => a.index.compareTo(b.index)),
      ];
}
