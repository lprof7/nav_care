import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/responses/pagination.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/data/reviews/hospital_reviews/hospital_reviews_remote_service.dart';
import 'package:nav_care_user_app/data/reviews/hospital_reviews/models/hospital_review_model.dart';

class HospitalReviewsRepository {
  HospitalReviewsRepository({required HospitalReviewsRemoteService remote})
      : _remote = remote;

  final HospitalReviewsRemoteService _remote;

  Future<Paged<HospitalReviewModel>> getHospitalReviews({
    required String hospitalId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _remote.getHospitalReviews(
      hospitalId: hospitalId,
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
        .map((e) => HospitalReviewModel.fromJson(e))
        .toList(growable: false);
    final pagination =
        _parsePagination(_asMap(data['pagination']) ?? _asMap(root['pagination']));

    return Paged(items: reviews, meta: pagination);
  }

  Future<HospitalReviewCreationResult> createHospitalReview({
    required String hospitalId,
    required double rating,
    required String comment,
  }) async {
    final response = await _remote.createHospitalReview(
      hospitalId: hospitalId,
      rating: rating,
      comment: comment,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(_resolveErrorMessage(response.error));
    }

    final data = response.data!;
    final root = _asMap(data['data']) ?? data;
    final reviewJson =
        _asMap(root['review']) ?? _asMap(root['data']) ?? _asMap(root);
    final review = HospitalReviewModel.fromJson(reviewJson ?? const {});
    final newRating = _toDouble(root['rating']);
    final reviewsCount = _toInt(root['reviewsCount']);

    return HospitalReviewCreationResult(
      review: review,
      rating: newRating,
      reviewsCount: reviewsCount,
    );
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
      pageSize: _toInt(json['limit']) ?? _toInt(json['pageSize']) ?? 10,
      total: _toInt(json['total']) ?? 0,
      totalPages: _toInt(json['pages']) ?? _toInt(json['totalPages']) ?? 1,
    );
  }

  String _resolveErrorMessage(Failure? error) {
    if (error == null) return 'reviews.error.generic';
    if (error.message.isNotEmpty) {
      return error.message;
    }
    switch (error.type) {
      case FailureType.unauthorized:
        return 'reviews.error.unauthorized';
      case FailureType.timeout:
        return 'reviews.error.timeout';
      default:
        return 'reviews.error.generic';
    }
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class HospitalReviewCreationResult {
  final HospitalReviewModel review;
  final double? rating;
  final int? reviewsCount;

  const HospitalReviewCreationResult({
    required this.review,
    this.rating,
    this.reviewsCount,
  });
}
