enum SearchResultType { doctor, hospital, serviceOffering, unknown }

SearchResultType searchResultTypeFrom(String? raw) {
  switch (raw) {
    case 'doctor':
      return SearchResultType.doctor;
    case 'hospital':
      return SearchResultType.hospital;
    case 'serviceOffering':
      return SearchResultType.serviceOffering;
    default:
      return SearchResultType.unknown;
  }
}

class SearchLocation {
  final double? latitude;
  final double? longitude;
  final String address;
  final String city;
  final String state;
  final String country;

  const SearchLocation({
    this.latitude,
    this.longitude,
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
  });

  factory SearchLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchLocation();
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return SearchLocation(
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
    );
  }
}

class SearchResultItem {
  final String id;
  final SearchResultType type;
  final String title;
  final String subtitle;
  final String description;
  final double? rating;
  final double? price;
  final String? facilityType;
  final List<String> languages;
  final List<String> insuranceAccepted;
  final List<String> collections;
  final SearchLocation location;
  final String? imagePath;
  final String? secondaryImagePath;
  final Map<String, dynamic> extra;

  const SearchResultItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle = '',
    this.description = '',
    this.rating,
    this.price,
    this.facilityType,
    this.languages = const [],
    this.insuranceAccepted = const [],
    this.collections = const [],
    this.location = const SearchLocation(),
    this.imagePath,
    this.secondaryImagePath,
    this.extra = const {},
  });

  factory SearchResultItem.fromJson(
    Map<String, dynamic> json, {
    SearchResultType? forcedType,
  }) {
    SearchResultType resolveType() {
      if (forcedType != null) return forcedType;
      return searchResultTypeFrom(json['type']?.toString());
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    List<String> stringList(dynamic value) {
      if (value is List) {
        return value
            .where((element) => element != null)
            .map((e) => e.toString())
            .toList(growable: false);
      }
      return const [];
    }

    String firstNonEmpty(List<dynamic> values) {
      for (final value in values) {
        if (value == null) continue;
        final text = value.toString();
        if (text.trim().isNotEmpty) return text;
      }
      return '';
    }

    final type = resolveType();

    String title = json['name']?.toString() ?? '';
    String subtitle = '';
    String description = '';
    String? imagePath;
    String? secondaryImagePath;
    double? rating = parseDouble(json['rating']);
    double? price = parseDouble(json['price']);
    String? facilityType = json['facilityType']?.toString();
    SearchLocation location =
        SearchLocation.fromJson(json['location'] as Map<String, dynamic>?);

    Map<String, dynamic> extra = {};
    if (json.isNotEmpty) {
      extra = json.map((key, value) => MapEntry(key.toString(), value));
    }

    switch (type) {
      case SearchResultType.doctor:
        final user = extra['user'] is Map
            ? Map<String, dynamic>.from(extra['user'] as Map)
            : null;
        title = user?['name']?.toString() ?? title;
        subtitle = json['specialty']?.toString() ?? '';
        description = json['bio_en']?.toString() ??
            json['bio']?.toString() ??
            description;
        imagePath = json['cover']?.toString();
        secondaryImagePath = user?['profilePicture']?.toString();
        rating ??= parseDouble(json['rating']);
        break;
      case SearchResultType.hospital:
        title = json['name']?.toString() ?? title;
        facilityType = json['facility_type']?.toString() ?? facilityType;
        description = json['description_en']?.toString() ??
            json['description']?.toString() ??
            description;
        final coordinates = json['coordinates'] as Map<String, dynamic>?;
        if (coordinates != null) {
          location = SearchLocation.fromJson(coordinates);
        }
        final images = json['images'];
        if (images is List && images.isNotEmpty) {
          imagePath = images.first?.toString();
        }
        break;
      case SearchResultType.serviceOffering:
        final service = extra['service'] is Map
            ? Map<String, dynamic>.from(extra['service'] as Map)
            : null;
        final provider = extra['provider'] is Map
            ? Map<String, dynamic>.from(extra['provider'] as Map)
            : null;
        final providerUser = provider?['user'] is Map
            ? Map<String, dynamic>.from(provider?['user'] as Map)
            : null;
        final offeringName = firstNonEmpty([
          json['name_en'],
          json['name_fr'],
          json['name_ar'],
          json['name_sp'],
          json['name'],
          extra['name_en'],
          extra['name'],
          service?['name_en'],
          service?['name_fr'],
          service?['name_ar'],
          service?['name_sp'],
        ]);
        title = offeringName.isNotEmpty ? offeringName : title;
        subtitle = providerUser?['name']?.toString() ?? '';
        description = provider?['specialty']?.toString() ?? '';
        imagePath = service?['image']?.toString();
        secondaryImagePath = providerUser?['profilePicture']?.toString();
        price = price ?? parseDouble(json['price']);
        break;
      case SearchResultType.unknown:
        title = json['name']?.toString() ??
            json['title']?.toString() ??
            title;
        description = json['description']?.toString() ?? description;
        break;
    }

    final collections = stringList(json['collections']);
    final languages = stringList(json['languages']);
    final insuranceAccepted = stringList(json['insuranceAccepted']);

    return SearchResultItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: type,
      title: title,
      subtitle: subtitle,
      description: description,
      rating: rating,
      price: price,
      facilityType: facilityType,
      languages: languages,
      insuranceAccepted: insuranceAccepted,
      collections: collections.isNotEmpty
          ? collections
          : <String>[type.name],
      location: location,
      imagePath: imagePath,
      secondaryImagePath: secondaryImagePath,
      extra: extra,
    );
  }
}

class SearchPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int? nextPage;
  final int? prevPage;

  const SearchPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    this.hasNextPage = false,
    this.hasPrevPage = false,
    this.nextPage,
    this.prevPage,
  });

  factory SearchPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SearchPagination(
        page: 1,
        limit: 20,
        total: 0,
        totalPages: 0,
      );
    }
    int parseInt(dynamic value, [int fallback = 0]) {
      if (value == null) return fallback;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? fallback;
    }

    return SearchPagination(
      page: parseInt(json['page'], 1),
      limit: parseInt(json['limit'], 20),
      total: parseInt(json['total'], 0),
      totalPages: parseInt(json['pages'] ?? json['totalPages'], 0),
      hasNextPage: json['hasNextPage'] == true,
      hasPrevPage: json['hasPrevPage'] == true,
      nextPage: json['nextPage'] == null ? null : parseInt(json['nextPage']),
      prevPage: json['prevPage'] == null ? null : parseInt(json['prevPage']),
    );
  }
}

class SearchSummary {
  final int doctors;
  final int hospitals;
  final int serviceOfferings;
  final int total;

  const SearchSummary({
    required this.doctors,
    required this.hospitals,
    required this.serviceOfferings,
    required this.total,
  });

  factory SearchSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SearchSummary(doctors: 0, hospitals: 0, serviceOfferings: 0, total: 0);
    }
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return SearchSummary(
      doctors: parseInt(json['doctors']),
      hospitals: parseInt(json['hospitals']),
      serviceOfferings: parseInt(json['serviceOfferings']),
      total: parseInt(json['total']),
    );
  }
}

class SearchResponse {
  final Map<SearchResultType, List<SearchResultItem>> resultsByType;
  final SearchPagination pagination;
  final SearchSummary summary;

  const SearchResponse({
    required this.resultsByType,
    required this.pagination,
    required this.summary,
  });

  List<SearchResultItem> get allResults =>
      resultsByType.values.expand((items) => items).toList(growable: false);

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final rawResults = dataMap['results'];
    final parsed = <SearchResultType, List<SearchResultItem>>{};

    void assign(SearchResultType type, List<dynamic> payload) {
      final items = payload
          .whereType<Map<String, dynamic>>()
          .map((e) => SearchResultItem.fromJson(e, forcedType: type))
          .toList(growable: false);
      if (items.isNotEmpty) {
        parsed[type] = items;
      }
    }

    if (rawResults is Map) {
      final map = rawResults.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      assign(SearchResultType.doctor, map['doctors'] as List<dynamic>? ?? []);
      assign(
          SearchResultType.hospital, map['hospitals'] as List<dynamic>? ?? []);
      assign(SearchResultType.serviceOffering,
          map['serviceOfferings'] as List<dynamic>? ?? []);
      final others = <SearchResultItem>[];
      map.forEach((key, value) {
        if (key == 'doctors' ||
            key == 'hospitals' ||
            key == 'serviceOfferings') {
          return;
        }
        if (value is List) {
          final inferredType = searchResultTypeFrom(key);
          others.addAll(
            value
                .whereType<Map<String, dynamic>>()
                .map(
                  (e) => SearchResultItem.fromJson(
                    e,
                    forcedType: inferredType,
                  ),
                ),
          );
        }
      });
      if (others.isNotEmpty) {
        parsed.putIfAbsent(SearchResultType.unknown, () => others);
      }
    } else if (rawResults is List) {
      assign(SearchResultType.unknown, rawResults);
    }

    return SearchResponse(
      resultsByType: Map.unmodifiable(parsed),
      pagination: SearchPagination.fromJson(
          dataMap['pagination'] as Map<String, dynamic>?),
      summary:
          SearchSummary.fromJson(dataMap['summary'] as Map<String, dynamic>?),
    );
  }
}

class SearchSuggestion {
  final String id;
  final String type;
  final String value;
  final String displayText;
  final Map<String, dynamic> extra;

  const SearchSuggestion({
    required this.id,
    required this.type,
    required this.value,
    required this.displayText,
    this.extra = const {},
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> extra = const {};
    final rawExtra = json['extra'];
    if (rawExtra is Map<String, dynamic>) {
      extra = Map<String, dynamic>.from(rawExtra);
    } else if (rawExtra is Map) {
      extra = rawExtra.map((key, value) => MapEntry(key.toString(), value));
    }

    return SearchSuggestion(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      displayText: json['displayText']?.toString() ?? '',
      extra: extra,
    );
  }
}







