import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/data/hospitals/models/hospital_model.dart';
import 'package:nav_care_user_app/presentation/features/authentication/signin/view/signin_page.dart';
import 'package:nav_care_user_app/presentation/features/authentication/signup/view/signup_page.dart';
import 'package:nav_care_user_app/presentation/features/hospitals/view/hospital_details_page.dart';
import 'package:nav_care_user_app/presentation/features/shell/view/nav_shell_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const NavShellPage()),
    GoRoute(path: '/signin', builder: (ctx, st) => const SigninPage()),
    GoRoute(path: '/signup', builder: (ctx, st) => const SignupPage()),
    GoRoute(path: '/home', builder: (ctx, st) => const NavShellPage()),
    GoRoute(
      path: '/hospitals/:id',
      builder: (ctx, state) {
        final hospital = state.extra as HospitalModel?;
        if (hospital == null) {
          return const _MissingHospitalDetailsPage();
        }
        return HospitalDetailsPage(hospital: hospital);
      },
    ),
  ],
);

class _MissingHospitalDetailsPage extends StatelessWidget {
  const _MissingHospitalDetailsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NavCare'),
      ),
      body: const Center(
        child: Text('Unable to load hospital details.'),
      ),
    );
  }
}
