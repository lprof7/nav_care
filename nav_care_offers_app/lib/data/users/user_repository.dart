import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';

import 'models/user_profile_model.dart';
import 'user_remote_service.dart';

class UserRepository {
  UserRepository({required UserRemoteService remoteService}) : _remoteService = remoteService;

  final UserRemoteService _remoteService;

  Future<UserProfileModel> fetchProfile() async {
    final result = await _remoteService.getProfile();
    if (!result.isSuccess || result.data == null) {
      final message = _extractMessage(result.error?.message) ?? 'Failed to load profile.';
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
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? imagePath,
  }) async {
    final payload = <String, dynamic>{
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (address != null && address.isNotEmpty) 'address': address,
      if (city != null && city.isNotEmpty) 'city': city,
      if (state != null && state.isNotEmpty) 'state': state,
      if (country != null && country.isNotEmpty) 'country': country,
    };

    final hasImage = imagePath != null && imagePath.isNotEmpty;
    if (payload.isEmpty && !hasImage) {
      throw Exception('No updates provided.');
    }

    Object body = payload;
    if (hasImage) {
      final fileName = imagePath!.split(Platform.pathSeparator).last;
      payload['image'] = await MultipartFile.fromFile(imagePath, filename: fileName);
      body = FormData.fromMap(payload);
    }

    final result = await _remoteService.updateProfile(body);
    if (!result.isSuccess || result.data == null) {
      final message = _extractMessage(result.error?.message) ?? 'Failed to update profile.';
      throw Exception(message);
    }
    final userMap = _extractUserMap(result.data!);
    if (userMap == null) {
      throw Exception('Profile data is missing.');
    }
    return UserProfileModel.fromJson(userMap);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final result = await _remoteService.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (!result.isSuccess) {
      final message = _extractMessage(result.error?.message) ?? 'Failed to update password.';
      throw Exception(message);
    }
  }

  Future<void> requestPasswordReset(String email) async {
    final result = await _remoteService.requestPasswordReset(email: email);
    if (!result.isSuccess) {
      final message = _extractMessage(result.error?.message) ?? 'Failed to request reset.';
      throw Exception(message);
    }
  }

  Future<String> deleteAccount() async {
    final result = await _remoteService.deleteMe();
    if (!result.isSuccess || result.data == null) {
      final message = _extractMessage(result.error?.message) ?? 'Failed to delete account.';
      throw Exception(message);
    }
    final message = _extractMessage(result.data?['message']) ?? 'Account deleted.';
    return message;
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
