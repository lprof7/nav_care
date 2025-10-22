import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ads_section_state.dart';

class AdsSectionCubit extends Cubit<AdsSectionState> {
  static const List<String> _defaultAssets = [
    'assets/images/ads/1.jpg',
    'assets/images/ads/2.jpg',
    'assets/images/ads/3.jpg',
    'assets/images/ads/4.jpg',
    'assets/images/ads/5.jpg',
  ];

  AdsSectionCubit({List<String>? imageAssets})
      : _images = imageAssets ?? _defaultAssets,
        pageController = PageController(
          initialPage: _computeInitialPage(imageAssets ?? _defaultAssets),
        ),
        super(
          AdsSectionState(
            images: imageAssets ?? _defaultAssets,
            page: _computeInitialPage(imageAssets ?? _defaultAssets),
          ),
        ) {
    _startAutoPlay();
  }

  static const Duration _autoPlayInterval = Duration(seconds: 4);
  static const Duration _autoPlayDuration = Duration(milliseconds: 600);
  static const int _loopOffset = 1000;

  final List<String> _images;
  final PageController pageController;
  Timer? _timer;

  static int _computeInitialPage(List<String> images) {
    if (images.isEmpty) return 0;
    return images.length * _loopOffset;
  }

  void onPageChanged(int page) {
    emit(state.copyWith(page: page));
    _restartAutoPlay();
  }

  void _startAutoPlay() {
    if (state.images.isEmpty) return;
    _timer?.cancel();
    _timer = Timer.periodic(_autoPlayInterval, (_) => _goToNextPage());
  }

  void _restartAutoPlay() {
    if (state.images.isEmpty) return;
    _timer?.cancel();
    _timer = Timer.periodic(_autoPlayInterval, (_) => _goToNextPage());
  }

  void _goToNextPage() {
    final nextPage = state.page + 1;
    pageController.animateToPage(
      nextPage,
      duration: _autoPlayDuration,
      curve: Curves.easeOut,
    );
    emit(state.copyWith(page: nextPage));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    pageController.dispose();
    return super.close();
  }
}
