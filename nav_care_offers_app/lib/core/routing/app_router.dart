import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/signin/view/signin_page.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/signup/view/signup_page.dart';
import 'package:nav_care_offers_app/presentation/features/shell/view/nav_shell_page.dart';

GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (ctx, st) => const SigninPage()),
      GoRoute(path: '/signin', builder: (ctx, st) => const SigninPage()),
      GoRoute(path: '/signup', builder: (ctx, st) => const SignupPage()),
      GoRoute(path: '/home', builder: (ctx, st) => const NavShellPage()),
    ],
  );
}
