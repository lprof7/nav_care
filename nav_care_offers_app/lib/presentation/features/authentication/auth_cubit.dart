import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/storage/secure_doctor_store.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SecureDoctorStore _doctorStore;

  AuthCubit(this._doctorStore) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    final doctor = await _doctorStore.getDoctor();
    if (doctor != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: User.fromJson(doctor)));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login(User user) async {
    await _doctorStore.setDoctor(user.toJson());
    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  Future<void> logout() async {
    await _doctorStore.clearDoctor();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }
}