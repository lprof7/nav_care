import 'package:get_it/get_it.dart';
import 'package:nav_care_user_app/presentation/features/authentication/session/auth_session_cubit.dart';

Future<void> handleUnauthorized() async {
  final sl = GetIt.instance;
  if (sl.isRegistered<AuthSessionCubit>()) {
    await sl<AuthSessionCubit>().logout();
  }
}
