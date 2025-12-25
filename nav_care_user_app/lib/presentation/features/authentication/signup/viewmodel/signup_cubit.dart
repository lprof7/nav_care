import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nav_care_user_app/data/authentication/signup/models/signup_request.dart';
import 'package:nav_care_user_app/data/authentication/signup/models/signup_result.dart';
import 'package:nav_care_user_app/data/authentication/signup/signup_repository.dart';

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

  Future<void> signup(SignupRequest request, {required String localeTag}) async {
    Intl.defaultLocale = localeTag;
    emit(SignupLoading());
    
    final result = await _signupRepository.signup(request);
    result.fold(
      onFailure: (failure) {
        final serverMessage = failure.message;
        final resolvedMessage = failure.statusCode == 413 &&
                (serverMessage.isEmpty || serverMessage == 'Server error')
            ? 'signup_image_too_large'
            : serverMessage;
        emit(SignupFailure(resolvedMessage));
      },
      onSuccess: (data) => emit(SignupSuccess(data)),
    );
  }
}
