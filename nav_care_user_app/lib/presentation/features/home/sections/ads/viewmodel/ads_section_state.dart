part of 'ads_section_cubit.dart';

class AdsSectionState extends Equatable {
  final List<String> images;
  final int page;

  const AdsSectionState({
    required this.images,
    required this.page,
  });

  int get currentIndex {
    if (images.isEmpty) return 0;
    final normalized = page % images.length;
    return normalized < 0 ? normalized + images.length : normalized;
  }

  AdsSectionState copyWith({
    List<String>? images,
    int? page,
  }) {
    return AdsSectionState(
      images: images ?? this.images,
      page: page ?? this.page,
    );
  }

  @override
  List<Object> get props => [images, page];
}
