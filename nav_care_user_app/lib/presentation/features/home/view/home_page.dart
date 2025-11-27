import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/core/network/network_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/ads/viewmodel/ads_section_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/doctors_choice/viewmodel/doctors_choice_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/featured_doctors/viewmodel/featured_doctors_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/featured_hospitals/viewmodel/featured_hospitals_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/featured_services/viewmodel/featured_services_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/hospitals_choice/viewmodel/hospitals_choice_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/recent_service_offerings/viewmodel/recent_service_offerings_cubit.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_button.dart';

import '../sections/ads/view/ads_section.dart';
import '../sections/featured_services/view/featured_services_section.dart';
import '../sections/doctors_choice/view/doctors_choice_section.dart';
import '../sections/hospitals_choice/view/hospitals_choice_section.dart';
import '../sections/featured_hospitals/view/featured_hospitals_section.dart';
import '../sections/featured_doctors/view/featured_doctors_section.dart';
import '../sections/recent_hospitals/view/recent_hospitals_section.dart';
import '../sections/recent_service_offerings/view/recent_service_offerings_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const sections = [
      _BecomeDoctorBanner(),
      AdsSectionView(),
      FeaturedServicesSection(),
      HospitalsChoiceSection(),
      DoctorsChoiceSection(),
      AdsSectionView(),
      FeaturedHospitalsSection(),
      FeaturedDoctorsSection(),
      RecentHospitalsSection(),
      RecentServiceOfferingsSection(),
      AdsSectionView(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider<AdsSectionCubit>(
          create: (context) => sl<AdsSectionCubit>()..loadAdvertisings(),
        ),
        BlocProvider<FeaturedServicesCubit>(
          create: (context) => sl<FeaturedServicesCubit>()..loadFeaturedServices(),
        ),
        BlocProvider<HospitalsChoiceCubit>(
          create: (context) => sl<HospitalsChoiceCubit>()..loadHospitals(),
        ),
        BlocProvider<DoctorsChoiceCubit>(
          create: (context) => sl<DoctorsChoiceCubit>()..loadDoctors(),
        ),
        BlocProvider<FeaturedHospitalsCubit>(
          create: (context) => sl<FeaturedHospitalsCubit>()..loadHospitals(),
        ),
        BlocProvider<FeaturedDoctorsCubit>(
          create: (context) => sl<FeaturedDoctorsCubit>()..loadDoctors(),
        ),
        BlocProvider<RecentServiceOfferingsCubit>(
          create: (context) => sl<RecentServiceOfferingsCubit>()..loadOfferings(),
        ),
      ],
      child: BlocConsumer<NetworkCubit, NetworkState>(
        listener: (context, state) {
          if (state.status == NetworkStatus.connected) {
            _loadAllData(context);
          }
        },
        builder: (context, state) {
          if (state.status == NetworkStatus.connected) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdsSectionCubit>().loadAdvertisings();
                context.read<FeaturedServicesCubit>().loadFeaturedServices();
                context.read<HospitalsChoiceCubit>().loadHospitals();
                context.read<DoctorsChoiceCubit>().loadDoctors();
                context.read<FeaturedHospitalsCubit>().loadHospitals();
                context.read<FeaturedDoctorsCubit>().loadDoctors();
                context.read<RecentServiceOfferingsCubit>().loadOfferings();
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => sections[index],
              ),
            );
          } else {
            String imagePath;
            String messageKey;
            if (state.status == NetworkStatus.noInternet) {
              imagePath = 'assets/error/network_error.png';
              messageKey = 'network_error.message';
            } else {
              // NetworkStatus.serverError
              imagePath = 'assets/error/server_error.png';
              messageKey = 'server_error.message';
            }

            return Padding(
              padding: const EdgeInsets.all(24.0), // تصغير الهوامش لتبتعد عن الحواف
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      imagePath,
                      width: 150, // تصغير حجم الصورة
                      height: 150,
                    ),
                    const SizedBox(height: 15), // تصغير المسافة
                    Text(
                      messageKey.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18), // تصغير حجم الخط
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15), // تصغير المسافة
                    TextButton(
                      onPressed: () {
                        context.read<NetworkCubit>().recheckConnectivity();
                        _loadAllData(context);
                      },
                      child: Text(
                        'network_error.retry'.tr(),
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _loadAllData(BuildContext context) {
    context.read<AdsSectionCubit>().loadAdvertisings();
    context.read<FeaturedServicesCubit>().loadFeaturedServices();
    context.read<HospitalsChoiceCubit>().loadHospitals();
    context.read<DoctorsChoiceCubit>().loadDoctors();
    context.read<FeaturedHospitalsCubit>().loadHospitals();
    context.read<FeaturedDoctorsCubit>().loadDoctors();
    context.read<RecentServiceOfferingsCubit>().loadOfferings();
  }
}

class _BecomeDoctorBanner extends StatelessWidget {
  const _BecomeDoctorBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.2),
              colorScheme.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.35),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 360;
            return isWide
                ? Row(
                    children: [
                      Expanded(child: _BannerText(theme)),
                      const SizedBox(width: 16),
                      _BannerButton(colorScheme),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BannerText(theme),
                      const SizedBox(height: 12),
                      _BannerButton(colorScheme),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _BannerText extends StatelessWidget {
  final ThemeData theme;

  const _BannerText(this.theme);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'home.banner.become_doctor.title'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'home.banner.become_doctor.subtitle'.tr(),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _BannerButton extends StatelessWidget {
  final ColorScheme colorScheme;

  const _BannerButton(this.colorScheme);

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.arrow_forward_rounded),
      label: Text('home.banner.become_doctor.cta'.tr()),
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
