import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/advertising/advertising_repository.dart';
import 'package:nav_care_user_app/data/advertising/models/advertising_model.dart';

part 'ads_section_state.dart';

class AdsSectionCubit extends Cubit<AdsSectionState> {
  final AdvertisingRepository _advertisingRepository;

  AdsSectionCubit({required AdvertisingRepository advertisingRepository})
      : _advertisingRepository = advertisingRepository,
        pageController = PageController(initialPage: _computeInitialPage([])),
        super(const AdsSectionState()) {
    loadAdvertisings();
  }

  static const Duration _autoPlayInterval = Duration(seconds: 4);
  static const Duration _autoPlayDuration = Duration(milliseconds: 600);
  static const int _loopOffset = 1000;

  final PageController pageController;
  Timer? _timer;

  static int _computeInitialPage(List<Advertising> advertisings) {
    if (advertisings.isEmpty) return 0;
    return advertisings.length * _loopOffset;
  }

  Future<void> loadAdvertisings() async {
    emit(state.copyWith(status: AdsSectionStatus.loading));
    final result =
        await _advertisingRepository.getAdvertisings(position: 'featured');
    result.fold(
      onFailure: (failure) => emit(
        state.copyWith(
            status: AdsSectionStatus.failure, message: failure.message),
      ),
      onSuccess: (advertisings) {
        emit(
          state.copyWith(
            status: AdsSectionStatus.success,
            advertisings: advertisings,
            page: _computeInitialPage(advertisings),
          ),
        );
        if (advertisings.isNotEmpty) {
          startAutoPlay();
        } else {
          stopAutoPlay();
        }
      },
    );
  }

  void onPageChanged(int page) {
    emit(state.copyWith(page: page));
    startAutoPlay();
  }

  void startAutoPlay() {
    if (state.advertisings.isEmpty) return;
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(_autoPlayInterval, (_) => _goToNextPage());
  }

  void stopAutoPlay() {
    _timer?.cancel();
  }

  void _goToNextPage() {
    if (!pageController.hasClients) return; // Check if PageController is attached
    final nextPage = state.page + 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) { // Re-check after frame callback
        pageController.animateToPage(
          nextPage,
          duration: _autoPlayDuration,
          curve: Curves.easeOut,
        );
      }
    });
    emit(state.copyWith(page: nextPage));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    pageController.dispose();
    return super.close();
  }

}
