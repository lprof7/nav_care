import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/storage/doctor_store.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final DoctorStore _doctorStore;
  final TokenStore _tokenStore;

  AuthCubit(this._doctorStore, this._tokenStore) : super(const AuthState());

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
}
