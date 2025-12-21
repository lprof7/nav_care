part of 'auth_cubit.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final bool isDoctor;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isDoctor = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool? isDoctor,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isDoctor: isDoctor ?? this.isDoctor,
    );
  }

  @override
  List<Object?> get props => [status, user, isDoctor];
}
