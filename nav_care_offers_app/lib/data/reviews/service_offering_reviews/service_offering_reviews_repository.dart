import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/reviews/service_offering_reviews/models/service_offering_review_model.dart';
import 'package:nav_care_offers_app/data/reviews/service_offering_reviews/service_offering_reviews_remote_service.dart';

class ReviewsPage {
  final List<ServiceOfferingReviewModel> items;
  final PageMeta? meta;

  const ReviewsPage({required this.items, this.meta});
}

class ServiceOfferingReviewsRepository {
  ServiceOfferingReviewsRepository({
    required ServiceOfferingReviewsRemoteService remote,
  }) : _remote = remote;

  final ServiceOfferingReviewsRemoteService _remote;

  Future<ReviewsPage> getReviews({
    required String offeringId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _remote.getReviews(
      offeringId: offeringId,
      page: page,
      limit: limit,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(_resolveErrorMessage(response.error));
    }

    final data = response.data!;
    final root = _asMap(data['data']) ?? data;
    final listSource = root['reviews'] ?? root['data'] ?? root['items'] ?? [];
    final reviews = _mapList(listSource)
        .map(ServiceOfferingReviewModel.fromJson)
        .toList(growable: false);
    final pagination =
        _parsePagination(_asMap(data['pagination']) ?? _asMap(root['pagination']));

    return ReviewsPage(items: reviews, meta: pagination);
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  List<Map<String, dynamic>> _mapList(dynamic source) {
    if (source is Iterable) {
      return source
          .whereType<Map>()
          .map((e) => e.map((key, value) => MapEntry(key.toString(), value)))
          .toList(growable: false);
    }
    return const [];
  }

  PageMeta? _parsePagination(Map<String, dynamic>? json) {
    if (json == null) return null;
    int? _toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return PageMeta(
      page: _toInt(json['page']) ?? 1,
      limit: _toInt(json['limit']) ?? _toInt(json['pageSize']) ?? 10,
      total: _toInt(json['total']) ?? 0,
      pages: _toInt(json['pages']) ?? _toInt(json['totalPages']) ?? 1,
      hasNextPage: json['hasNextPage'] == true,
      hasPrevPage: json['hasPrevPage'] == true,
      nextPage: _toInt(json['nextPage']),
      prevPage: _toInt(json['prevPage']),
    );
  }

  String _resolveErrorMessage(Failure? error) {
    if (error == null) return 'reviews.error.generic';
    if (error.message.isNotEmpty) return error.message;
    switch (error.type) {
      case FailureType.unauthorized:
        return 'reviews.error.unauthorized';
      case FailureType.timeout:
        return 'reviews.error.timeout';
      default:
        return 'reviews.error.generic';
    }
  }
}
