import 'package:nav_care_user_app/core/responses/result.dart';

import 'models/user_profile_model.dart';
import 'user_remote_service.dart';

class UserRepository {
  UserRepository({required UserRemoteService remoteService})
      : _remoteService = remoteService;

  final UserRemoteService _remoteService;

  Future<UserProfileModel> fetchProfile() async {
    final result = await _remoteService.getProfile();
    print(result.data);
    print(result.error?.message);
    if (!result.isSuccess || result.data == null) {
      final message =
          _extractMessage(result.error?.message) ?? 'Failed to load profile.';
      throw Exception(message);
    }
    final userMap = _extractUserMap(result.data!);
    if (userMap == null) {
      throw Exception('Profile data is missing.');
    }
    return UserProfileModel.fromJson(userMap);
  }

  Future<UserProfileModel> updateProfile({
    String? name,
    String? password,
  }) async {
    final payload = <String, dynamic>{
      if (name != null && name.isNotEmpty) 'name': name,
      if (password != null && password.isNotEmpty) 'password': password,
    };

    if (payload.isEmpty) {
      throw Exception('No updates provided.');
    }

    final result = await _remoteService.updateProfile(payload);
    if (!result.isSuccess || result.data == null) {
      final message =
          _extractMessage(result.error?.message) ?? 'Failed to update profile.';
      throw Exception(message);
    }
    final userMap = _extractUserMap(result.data!);
    if (userMap == null) {
      throw Exception('Profile data is missing.');
    }
    return UserProfileModel.fromJson(userMap);
  }

  String? _extractMessage(dynamic message) {
    if (message is String && message.isNotEmpty) {
      return message;
    }
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
      if (localized.isNotEmpty) {
        return localized;
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractUserMap(Map<String, dynamic> source) {
    final data = source['data'];
    if (data is Map<String, dynamic>) {
      if (data.containsKey('user')) {
        final user = data['user'];
        if (user is Map<String, dynamic>) {
          return user;
        }
      }
      return data;
    }
    return null;
  }
}
