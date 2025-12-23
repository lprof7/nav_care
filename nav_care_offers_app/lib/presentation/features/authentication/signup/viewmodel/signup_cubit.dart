import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/authentication/signup/models/signup_request.dart';
import 'package:nav_care_offers_app/data/authentication/signup/models/signup_result.dart';
import 'package:nav_care_offers_app/data/authentication/signup/signup_repository.dart';

abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final SignupResult result;
  SignupSuccess(this.result);
}

class SignupFailure extends SignupState {
  final String message;
  SignupFailure(this.message);
}

class SignupCubit extends Cubit<SignupState> {
  final SignupRepository _signupRepository;

  SignupCubit(this._signupRepository) : super(SignupInitial());

  Future<void> signup(SignupRequest request) async {
    emit(SignupLoading());

    final result = await _signupRepository.signup(request);
    result.fold(
      onFailure: (failure) => emit(
        SignupFailure(
          failure.statusCode == 413
              ? 'signup_image_too_large'
              : failure.message,
        ),
      ),
      onSuccess: (data) => emit(SignupSuccess(data)),
    );
  }
}
