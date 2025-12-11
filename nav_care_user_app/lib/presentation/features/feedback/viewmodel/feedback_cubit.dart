import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/feedback/feedback_repository.dart';

import 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit({required FeedbackRepository repository})
      : _repository = repository,
        super(const FeedbackState());

  final FeedbackRepository _repository;

  Future<bool> submit({
    required String comment,
    Uint8List? screenshot,
  }) async {
    emit(state.copyWith(
      status: FeedbackStatus.submitting,
      errorMessage: null,
      message: null,
    ));

    final result = await _repository.submitFeedback(
      comment: comment,
      screenshot: screenshot,
    );

    return result.fold(
      onFailure: (failure) {
        emit(state.copyWith(
          status: FeedbackStatus.failure,
          errorMessage: failure.message,
        ));
        return false;
      },
      onSuccess: (message) {
        emit(state.copyWith(
          status: FeedbackStatus.success,
          message: message,
        ));
        return true;
      },
    );
  }

  void reset() {
    emit(const FeedbackState());
  }
}
