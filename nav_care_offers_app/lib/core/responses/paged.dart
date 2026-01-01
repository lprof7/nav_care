import 'pagination.dart';

class Paged<T> {
  final List<T> items;
  final PageMeta? meta;
  final int? offset;
  final int? limit;
  final String? nextCursor;

  const Paged({
    required this.items,
    this.meta,
    this.offset,
    this.limit,
    this.nextCursor,
  });
}
