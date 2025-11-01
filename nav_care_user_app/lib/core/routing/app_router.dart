import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/presentation/features/authentication/signin/view/signin_page.dart';
import 'package:nav_care_user_app/presentation/features/shell/view/nav_shell_page.dart';

import '../../presentation/features/authentication/signup/view/signup_page.dart';
import '../../presentation/features/services/service_creation/view/add_service_page.dart';
import '../../presentation/features/hospitals/hospital_creation/view/add_hospital_page.dart';
import '../../presentation/features/hospitals/hospital_packages/view/add_hospital_packages_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const NavShellPage()),
    GoRoute(path: '/signin', builder: (ctx, st) => const SigninPage()),
    GoRoute(path: '/signup', builder: (ctx, st) => const SignupPage()),
    GoRoute(path: '/home', builder: (ctx, st) => const NavShellPage()),
    GoRoute(
        path: '/services/create', builder: (ctx, st) => const AddServicePage()),
    GoRoute(
        path: '/hospitals/create',
        builder: (ctx, st) => const AddHospitalPage()),
    GoRoute(
      path: '/hospitals/:id/packages/add',
      builder: (ctx, st) => AddHospitalPackagesPage(
        hospitalId: st.pathParameters['id'] ?? '',
      ),
    ),
  ],
);
