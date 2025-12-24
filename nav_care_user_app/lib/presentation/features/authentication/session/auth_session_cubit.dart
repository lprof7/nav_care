import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/storage/token_store.dart';
import 'package:nav_care_user_app/core/storage/user_store.dart';
import 'package:nav_care_user_app/data/authentication/models.dart';

part 'auth_session_state.dart';

class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit({
    required TokenStore tokenStore,
    required UserStore userStore,
    required ApiClient apiClient,
  })  : _tokenStore = tokenStore,
        _userStore = userStore,
        _apiClient = apiClient,
        super(const AuthSessionState());

  final TokenStore _tokenStore;
  final UserStore _userStore;
  final ApiClient _apiClient;

  Future<void> refreshSession() async {
    final token = await _tokenStore.getToken();
    final user = await _userStore.getUser();
    if (token != null && token.isNotEmpty && user != null) {
      emit(
        state.copyWith(
          status: AuthSessionStatus.authenticated,
          user: user,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AuthSessionStatus.unauthenticated,
          clearUser: true,
        ),
      );
    }
  }

  /// Verifies the stored token by hitting a protected endpoint.
  /// If the API reports an invalid token or returns 401, clears the session.
  Future<void> verifyTokenValidity() async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      await _clearAuthState();
      return;
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      _apiClient.apiConfig.userAppointments,
      headers: {'Authorization': 'Bearer $token'},
      parser: (json) => json is Map
          ? Map<String, dynamic>.from(json as Map)
          : <String, dynamic>{},
    );

    await response.fold(
      onSuccess: (data) async {
        if (_isInvalidTokenPayload(data)) {
          await _clearAuthState();
        }
      },
      onFailure: (failure) async {
        if (failure.type == FailureType.unauthorized) {
          await _clearAuthState();
        }
      },
    );
  }

  void setAuthenticatedUser(User user) {
    emit(
      state.copyWith(
        status: AuthSessionStatus.authenticated,
        user: user,
      ),
    );
  }

  void clearSession() {
    emit(
      state.copyWith(
        status: AuthSessionStatus.unauthenticated,
        clearUser: true,
      ),
    );
  }

  Future<void> logout() async {
    await _clearAuthState();
  }

  Future<void> _clearAuthState() async {
    await Future.wait([
      _tokenStore.clearToken(),
      _userStore.clearUser(),
    ]);
    clearSession();
  }

  bool _isInvalidTokenPayload(Map<String, dynamic> data) {
    if (data['success'] == false) {
      final message = data['message'];
      final error = data['error'];
      final errorCode = error?.toString().toLowerCase();
      if (errorCode == 'invalidtoken') return true;
      if (_messageContainsInvalidToken(message)) return true;
      if (error is String) {
        final lower = error.toLowerCase();
        if (lower.contains('jwt') ||
            lower.contains('token') ||
            lower.contains('invalid token')) {
          return true;
        }
      }
    }
    return false;
  }

  bool _messageContainsInvalidToken(dynamic message) {
    if (message is String) {
      final lower = message.toLowerCase();
      return lower.contains('invalid token') || lower.contains('jwt');
    }
    if (message is Map) {
      for (final value in message.values) {
        if (value is String) {
          final lower = value.toLowerCase();
          if (lower.contains('invalid token') || lower.contains('jwt')) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
