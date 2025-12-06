import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/data/authentication/google/google_auth_service.dart';
import 'package:nav_care_user_app/data/authentication/google/google_user.dart';
import 'package:nav_care_user_app/data/authentication/models.dart';
import 'package:nav_care_user_app/data/authentication/signin/signin_repository.dart';

abstract class SocialAuthState {}

class SocialAuthInitial extends SocialAuthState {}

class SocialAuthLoading extends SocialAuthState {}

class SocialAuthSuccess extends SocialAuthState {
  final User user;
  SocialAuthSuccess(this.user);
}

class SocialAuthNeedsProfile extends SocialAuthState {
  final GoogleAccount account;
  SocialAuthNeedsProfile(this.account);
}

class SocialAuthFailure extends SocialAuthState {
  final String message;
  SocialAuthFailure(this.message);
}

class SocialAuthCubit extends Cubit<SocialAuthState> {
  SocialAuthCubit(
    this._googleAuthService,
    this._signinRepository,
  ) : super(SocialAuthInitial());

  final GoogleAuthService _googleAuthService;
  final SigninRepository _signinRepository;

  Future<void> signInWithGoogle() async {
    emit(SocialAuthLoading());
    try {
      final account = await _googleAuthService.signInWithGoogle();
      final result = await _signinRepository.signin({
        'email': account.email,
        'password': account.uid,
      });

      result.fold(
        onFailure: (failure) {
          if (failure.type == FailureType.unauthorized) {
            emit(SocialAuthNeedsProfile(account));
          } else {
            emit(SocialAuthFailure(failure.message));
          }
        },
        onSuccess: (user) => emit(SocialAuthSuccess(user)),
      );
    } catch (e) {
      emit(SocialAuthFailure(_mapError(e)));
    }
  }

  String _mapError(Object error) {
    final msg = error.toString();
    if (msg.contains('cancel')) return 'تم إلغاء تسجيل الدخول عبر Google';
    if (msg.contains('email_not_found')) {
      return 'تعذر الحصول على البريد الإلكتروني من Google';
    }
    return 'فشل تسجيل الدخول عبر Google';
  }
}
