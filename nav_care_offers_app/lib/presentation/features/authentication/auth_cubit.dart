import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/storage/doctor_store.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final DoctorStore _doctorStore;
  final TokenStore _tokenStore;
  final ApiClient _apiClient;

  AuthCubit(
    this._doctorStore,
    this._tokenStore,
    this._apiClient,
  ) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    final doctor = await _doctorStore.getDoctor();
    final token = await _tokenStore.getUserToken();
    if (doctor == null || token == null || token.isEmpty) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
      return;
    }

    try {
      final user = User.fromJson(doctor);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    }
  }

  Future<void> login(User user) async {
    await _doctorStore.setDoctor(user.toJson());
    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  /// Hits a protected endpoint to ensure the stored token is still valid.
  /// On 401 or invalid token payload, clears persisted session.
  Future<void> verifyTokenValidity() async {
    final token = await _tokenStore.getUserToken();
    final storedDoctor = await _doctorStore.getDoctor();
    if (token == null || token.isEmpty || storedDoctor == null) {
      await logout();
      return;
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      _apiClient.apiConfig.doctorAppointments,
      headers: {'Authorization': 'Bearer $token'},
      parser: (json) => json is Map
          ? Map<String, dynamic>.from(json as Map)
          : <String, dynamic>{},
    );

    await response.fold(
      onFailure: (failure) async {
        if (failure.type == FailureType.unauthorized) {
          await logout();
        }
      },
      onSuccess: (data) async {
        if (_isInvalidTokenPayload(data)) {
          await logout();
          return;
        }
        // If the token is valid but the cubit is not authenticated, restore it.
        if (state.status != AuthStatus.authenticated) {
          try {
            emit(
              state.copyWith(
                status: AuthStatus.authenticated,
                user: User.fromJson(storedDoctor),
              ),
            );
          } catch (_) {
            await logout();
          }
        }
      },
    );
  }

  Future<void> setAuthenticatedUser(User user) async {
    await _doctorStore.setDoctor(user.toJson());
    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  Future<void> logout() async {
    await Future.wait([
      _doctorStore.clearDoctor(),
      _tokenStore.clearUserToken(),
      _tokenStore.clearHospitalToken(),
    ]);
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  bool _isInvalidTokenPayload(Map<String, dynamic> data) {
    if (data['success'] == false) {
      final message = data['message'];
      final error = data['error'];

      bool containsInvalid(dynamic value) {
        if (value is String) {
          final lower = value.toLowerCase();
          return lower.contains('invalid token') || lower.contains('jwt');
        }
        if (value is Map) {
          return value.values.any(containsInvalid);
        }
        return false;
      }

      if (containsInvalid(message)) return true;
      if (error is String &&
          (error.toLowerCase().contains('jwt') ||
              error.toLowerCase().contains('token'))) {
        return true;
      }
    }
    return false;
  }
}
