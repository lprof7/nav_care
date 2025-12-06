import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/responses/pagination.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/data/reviews/doctor_reviews/doctor_reviews_remote_service.dart';
import 'package:nav_care_user_app/data/reviews/doctor_reviews/models/doctor_review_model.dart';

class DoctorReviewsRepository {
  DoctorReviewsRepository({required DoctorReviewsRemoteService remote})
      : _remote = remote;

  final DoctorReviewsRemoteService _remote;

  Future<Paged<DoctorReviewModel>> getDoctorReviews({
    required String doctorId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _remote.getDoctorReviews(
      doctorId: doctorId,
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
        .map((e) => DoctorReviewModel.fromJson(e))
        .toList(growable: false);
    final pagination =
        _parsePagination(_asMap(data['pagination']) ?? _asMap(root['pagination']));

    return Paged(items: reviews, meta: pagination);
  }

  Future<DoctorReviewCreationResult> createDoctorReview({
    required String doctorId,
    required double rating,
    required String comment,
  }) async {
    final response = await _remote.createDoctorReview(
      doctorId: doctorId,
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
    final review = DoctorReviewModel.fromJson(reviewJson ?? const {});
    final newRating = _toDouble(root['rating']);
    final reviewsCount = _toInt(root['reviewsCount']);
    return DoctorReviewCreationResult(
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

class DoctorReviewCreationResult {
  final DoctorReviewModel review;
  final double? rating;
  final int? reviewsCount;

  const DoctorReviewCreationResult({
    required this.review,
    this.rating,
    this.reviewsCount,
  });
}
