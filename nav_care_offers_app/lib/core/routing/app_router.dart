import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/become_doctor/view/become_doctor_page.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/signin/view/signin_page.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/hospital_detail_page.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/hospital_form_page.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/manage/manage_placeholder_page.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/manage/manage_target.dart';
import 'package:nav_care_offers_app/presentation/features/shell/view/nav_shell_page.dart';

GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (ctx, st) => const SigninPage()),
      GoRoute(path: '/signin', builder: (ctx, st) => const SigninPage()),
      GoRoute(
        path: '/become-doctor',
        builder: (ctx, st) =>
            BecomeDoctorPage(user: st.extra as User?),
      ),
      GoRoute(path: '/home', builder: (ctx, st) => const NavShellPage()),
      GoRoute(
        path: '/hospitals/new',
        builder: (ctx, st) => const HospitalFormPage(),
      ),
      GoRoute(
        path: '/hospitals/:id',
        builder: (ctx, st) {
          final id = st.pathParameters['id'] ?? '';
          final passed = st.extra;
          final hospital =
              passed is Hospital ? passed : sl<HospitalsRepository>().findById(id);
          return HospitalDetailPage(
            hospitalId: id,
            initial: hospital,
          );
        },
      ),
      GoRoute(
        path: '/hospitals/:id/edit',
        builder: (ctx, st) {
          final id = st.pathParameters['id'] ?? '';
          final passed = st.extra;
          final hospital =
              passed is Hospital ? passed : sl<HospitalsRepository>().findById(id);
          return HospitalFormPage(initial: hospital);
        },
      ),
      GoRoute(
        path: '/hospitals/:id/manage/:target',
        builder: (ctx, st) {
          final id = st.pathParameters['id'] ?? '';
          final targetParam = st.pathParameters['target'] ?? 'clinics';
          final repository = sl<HospitalsRepository>();
          final extra = st.extra;

          ManageTarget target =
              targetParam == 'doctors' ? ManageTarget.doctors : ManageTarget.clinics;
          Hospital? hospital = repository.findById(id);

          if (extra is Map) {
            final rawHospital = extra['hospital'];
            if (rawHospital is Hospital) {
              hospital = rawHospital;
            }
            final rawTarget = extra['target'];
            if (rawTarget is ManageTarget) {
              target = rawTarget;
            }
          }

          hospital ??= Hospital(id: id, name: 'Hospital');

          return HospitalManagePlaceholderPage(
            hospital: hospital,
            target: target,
          );
        },
      ),
    ],
  );
}
