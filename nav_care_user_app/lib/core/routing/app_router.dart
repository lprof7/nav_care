import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/presentation/features/authentication/signin/view/signin_page.dart';
import 'package:nav_care_user_app/presentation/features/shell/view/nav_shell_page.dart';

import '../../presentation/features/authentication/signup/view/signup_page.dart';
import '../../presentation/features/services/service_creation/view/add_service_page.dart';
import '../../presentation/features/appointments/appointment_creation/view/add_appointment_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const NavShellPage()),
    GoRoute(path: '/signin', builder: (ctx, st) => const SigninPage()),
    GoRoute(path: '/signup', builder: (ctx, st) => const SignupPage()),
    GoRoute(path: '/home', builder: (ctx, st) => const NavShellPage()),
    GoRoute(
        path: '/services/create', builder: (ctx, st) => const AddServicePage()),
    GoRoute(
        path: '/appointments/create',
        builder: (ctx, st) {
          final serviceOfferingId = st.extra as String;
          return AddAppointmentPage(serviceOfferingId: serviceOfferingId);
        }),
  ],
);
