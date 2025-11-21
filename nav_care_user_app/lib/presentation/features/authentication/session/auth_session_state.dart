part of 'auth_session_cubit.dart';

enum AuthSessionStatus { unknown, authenticated, unauthenticated }

class AuthSessionState extends Equatable {
  final AuthSessionStatus status;
  final User? user;

  const AuthSessionState({
    this.status = AuthSessionStatus.unknown,
    this.user,
  });

  bool get isAuthenticated => status == AuthSessionStatus.authenticated;

  AuthSessionState copyWith({
    AuthSessionStatus? status,
    User? user,
    bool clearUser = false,
  }) {
    return AuthSessionState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, user];
}
