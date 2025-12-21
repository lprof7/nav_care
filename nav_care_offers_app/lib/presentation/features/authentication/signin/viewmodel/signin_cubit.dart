import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/authentication/signin/signin_repository.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';

abstract class SigninState {}

class SigninInitial extends SigninState {}

class SigninLoading extends SigninState {}

class SigninSuccess extends SigninState {
  final bool isDoctor;
  SigninSuccess({required this.isDoctor});
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
      onSuccess: (outcome) {
        switch (outcome.resolution) {
          case SigninResolution.authenticated:
            sl<AuthCubit>().login(
              outcome.user,
              isDoctor: outcome.isDoctor,
            );
            emit(SigninSuccess(isDoctor: outcome.isDoctor));
            break;
        }
      },
    );
  }
}
