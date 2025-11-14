import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination.freezed.dart';
part 'pagination.g.dart';

@freezed
class PageMeta with _$PageMeta {
  const factory PageMeta({
    required int page,
    required int limit,
    required int total,
    required int pages,
    @Default(false) bool hasNextPage,
    @Default(false) bool hasPrevPage,
    int? nextPage,
    int? prevPage,
  }) = _PageMeta;

  factory PageMeta.fromJson(Map<String, dynamic> json) => _$PageMetaFromJson(json);
}

@freezed
class Pagination with _$Pagination {
  const factory Pagination({
    required int total,
    required int page,
    required int limit,
    required int pages,
    required bool hasNextPage,
    required bool hasPrevPage,
    int? nextPage,
    int? prevPage,
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, dynamic> json) => _$PaginationFromJson(json);
}
