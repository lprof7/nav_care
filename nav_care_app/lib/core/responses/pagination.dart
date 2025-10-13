class PageMeta {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  const PageMeta(
      {required this.page,
      required this.pageSize,
      required this.total,
      required this.totalPages});
}

class Paged<T> {
  final List<T> items;
  final PageMeta? meta; // page/pageSize format
  final int? offset; // for offset/limit format
  final int? limit;
  final String? nextCursor; // for cursor-based format
  const Paged(
      {required this.items,
      this.meta,
      this.offset,
      this.limit,
      this.nextCursor});
}
