import 'package:equatable/equatable.dart';

enum FeedbackStatus { idle, submitting, success, failure }

class FeedbackState extends Equatable {
  final FeedbackStatus status;
  final String? message;
  final String? errorMessage;

  const FeedbackState({
    this.status = FeedbackStatus.idle,
    this.message,
    this.errorMessage,
  });

  FeedbackState copyWith({
    FeedbackStatus? status,
    String? message,
    String? errorMessage,
  }) {
    return FeedbackState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, message, errorMessage];
}
