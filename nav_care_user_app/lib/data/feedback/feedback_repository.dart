import 'dart:typed_data';

import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/core/utils/multipart_helper.dart';

import 'feedback_remote_service.dart';

class FeedbackRepository {
  FeedbackRepository({required FeedbackRemoteService remoteService})
      : _remoteService = remoteService;

  final FeedbackRemoteService _remoteService;

  Future<Result<String>> submitFeedback({
    required String comment,
    Uint8List? screenshot,
  }) async {
    final multipartScreenshot = await MultipartHelper.toMultipartFile(
      screenshot,
      fallbackName: 'feedback.png',
    );

    final result = await _remoteService.sendFeedback(
      comment: comment,
      screenshot: multipartScreenshot,
    );

    if (!result.isSuccess || result.data == null) {
      return Result.failure(result.error ?? const Failure.unknown());
    }

    final message =
        _extractMessage(result.data!) ?? 'Feedback submitted successfully';

    return Result.success(message);
  }

  String? _extractMessage(Map<String, dynamic> payload) {
    final message = payload['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is Map<String, dynamic>) {
      final localized = [
        message['ar'],
        message['fr'],
        message['en'],
        message['sp'],
      ].whereType<String>().firstWhere(
            (value) => value.isNotEmpty,
            orElse: () => '',
          );
      if (localized.isNotEmpty) return localized;
    }
    return null;
  }
}
