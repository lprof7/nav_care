import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/authentication/models.dart';
import 'package:nav_care_user_app/data/authentication/signin/signin_repository.dart';

abstract class SigninState {}

class SigninInitial extends SigninState {}

class SigninLoading extends SigninState {}

class SigninSuccess extends SigninState {
  final User user;
  SigninSuccess(this.user);
}

class SigninFailure extends SigninState {
  final String message;
  SigninFailure(this.message);
}

class SigninCubit extends Cubit<SigninState> {
  final SigninRepository _signinRepository;

  SigninCubit(this._signinRepository) : super(SigninInitial());

  Future<void> signin(String identifier, String password) async {
    emit(SigninLoading());
    final result = await _signinRepository.signin({
      'identifier': identifier,
      'password': password,
    });
    result.fold(
      onFailure: (failure) => emit(SigninFailure(failure.message)),
      onSuccess: (user) => emit(SigninSuccess(user)),
    );
  }
}
