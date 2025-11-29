import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/become_doctor/view/become_doctor_page.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/signin/view/signin_page.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/hospital_detail_page.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/hospital_form_page.dart';
import 'package:nav_care_offers_app/presentation/features/shell/view/nav_shell_page.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/clinic_creation/view/clinic_form_page.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/clinic_creation/viewmodel/clinic_creation_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/view/clinics_list_page.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/viewmodel/clinics_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/view/doctor_detail_page.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/view/doctors_list_page.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/viewmodel/doctors_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/view/service_offerings_page.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/view/service_offering_form_page.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/view/service_offering_detail_page.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offerings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (ctx, st) => const SigninPage()),
      GoRoute(path: '/signin', builder: (ctx, st) => const SigninPage()),
      GoRoute(
        path: '/become-doctor',
        builder: (ctx, st) => BecomeDoctorPage(user: st.extra as User?),
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
          final hospital = passed is Hospital
              ? passed
              : sl<HospitalsRepository>().findById(id);
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
          final hospital = passed is Hospital
              ? passed
              : sl<HospitalsRepository>().findById(id);
          return HospitalFormPage(initial: hospital);
        },
      ),
      GoRoute(
        path: '/hospitals/:hospitalId/clinics',
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          return BlocProvider(
            create: (context) => sl<ClinicsCubit>(),
            child: ClinicsListPage(hospitalId: hospitalId),
          );
        },
      ),
      GoRoute(
        path: '/hospitals/:hospitalId/clinics/new',
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          return BlocProvider(
            create: (context) => sl<ClinicCreationCubit>(),
            child: ClinicFormPage(hospitalId: hospitalId),
          );
        },
      ),
      GoRoute(
        path: '/hospitals/:hospitalId/doctors',
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          return BlocProvider(
            create: (context) => sl<DoctorsCubit>(),
            child: DoctorsListPage(hospitalId: hospitalId),
          );
        },
      ),
      GoRoute(
        path: '/doctors/:doctorId/detail',
        builder: (ctx, st) {
          final doctorId = st.pathParameters['doctorId'] ?? '';
          final extra = st.extra;
          DoctorModel? doctor;
          String? hospitalId;
          List<DoctorModel>? hospitalDoctors;
          List<HospitalInvitation>? invitations;
          if (extra is DoctorModel) {
            doctor = extra;
          } else if (extra is Map) {
            final map = extra.cast<dynamic, dynamic>();
            final doc = map['doctor'];
            if (doc is DoctorModel) doctor = doc;
            hospitalId = map['hospitalId']?.toString();
            hospitalDoctors = (map['hospitalDoctors'] as List?)
                ?.whereType<DoctorModel>()
                .toList();
            invitations = (map['invitations'] as List?)
                ?.whereType<HospitalInvitation>()
                .toList();
          }
          return DoctorDetailPage(
            doctorId: doctorId,
            initial: doctor,
            hospitalId: hospitalId,
            hospitalDoctors: hospitalDoctors,
            invitations: invitations,
          );
        },
      ),
      GoRoute(
        path: '/hospitals/:hospitalId/service-offerings',
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          return BlocProvider(
            create: (context) => sl<ServiceOfferingsCubit>(),
            child: ServiceOfferingsPage(hospitalId: hospitalId),
          );
        },
      ),
      GoRoute(
        path: '/hospitals/:hospitalId/service-offerings/new',
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          return ServiceOfferingFormPage(hospitalId: hospitalId);
        },
      ),
      GoRoute(
        path: '/hospitals/:hospitalId/service-offerings/:offeringId/edit',
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          final offering = st.extra;
          return ServiceOfferingFormPage(
            hospitalId: hospitalId,
            initial: offering is ServiceOffering ? offering : null,
          );
        },
      ),
      GoRoute(
        path: '/hospitals/:hospitalId/service-offerings/:offeringId/detail',
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          final offeringId = st.pathParameters['offeringId'] ?? '';
          final offering = st.extra;
          return ServiceOfferingDetailPage(
            hospitalId: hospitalId,
            offeringId: offeringId,
            initial: offering is ServiceOffering ? offering : null,
          );
        },
      ),
    ],
  );
}
