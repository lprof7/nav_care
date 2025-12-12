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
import 'package:shimmer/shimmer.dart';

import '../sections/ads/view/ads_section.dart';
import '../sections/featured_services/view/featured_services_section.dart';
import '../sections/doctors_choice/view/doctors_choice_section.dart';
import '../sections/hospitals_choice/view/hospitals_choice_section.dart';
import '../sections/featured_hospitals/view/featured_hospitals_section.dart';
import '../sections/featured_doctors/view/featured_doctors_section.dart';
import '../sections/recent_hospitals/view/recent_hospitals_section.dart';
import '../sections/recent_doctors/view/recent_doctors_section.dart';
import '../sections/recent_service_offerings/view/recent_service_offerings_section.dart';
import '../sections/recent_hospitals/viewmodel/recent_hospitals_cubit.dart';
import '../sections/recent_doctors/viewmodel/recent_doctors_cubit.dart';

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
      AdsSectionView(),
      RecentHospitalsSection(),
      RecentServiceOfferingsSection(),
      RecentDoctorsSection(),
      AdsSectionView(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider<AdsSectionCubit>(
          create: (context) => sl<AdsSectionCubit>()..loadAdvertisings(),
        ),
        BlocProvider<FeaturedServicesCubit>(
          create: (context) =>
              sl<FeaturedServicesCubit>()..loadFeaturedServices(),
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
        BlocProvider<RecentHospitalsCubit>(
          create: (context) => sl<RecentHospitalsCubit>()..loadHospitals(),
        ),
        BlocProvider<RecentDoctorsCubit>(
          create: (context) => sl<RecentDoctorsCubit>()..loadDoctors(),
        ),
        BlocProvider<RecentServiceOfferingsCubit>(
          create: (context) =>
              sl<RecentServiceOfferingsCubit>()..loadOfferings(),
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
                context.read<RecentHospitalsCubit>().loadHospitals();
                context.read<RecentDoctorsCubit>().loadDoctors();
                context.read<RecentServiceOfferingsCubit>().loadOfferings();
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => sections[index],
              ),
            );
          } else if (!state.canShowError) {
            return const _HomeConnectionShimmer();
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
              padding:
                  const EdgeInsets.all(24.0), // تصغير الهوامش لتبتعد عن الحواف
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 18), // تصغير حجم الخط
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
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
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
    context.read<RecentHospitalsCubit>().loadHospitals();
    context.read<RecentDoctorsCubit>().loadDoctors();
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

class _HomeConnectionShimmer extends StatelessWidget {
  const _HomeConnectionShimmer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: ListView.separated(
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) {
              if (index == 0) {
                return const _ShimmerHeaderCard();
              }
              return const _ShimmerSectionCard();
            },
          ),
        ),
      ),
    );
  }
}

class _ShimmerHeaderCard extends StatelessWidget {
  const _ShimmerHeaderCard();

  @override
  Widget build(BuildContext context) {
    final tileColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 18, width: 160, color: tileColor),
          const SizedBox(height: 12),
          Container(height: 14, width: 220, color: tileColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Container(height: 44, color: tileColor)),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerSectionCard extends StatelessWidget {
  const _ShimmerSectionCard();

  @override
  Widget build(BuildContext context) {
    final tileColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 16, width: 120, color: tileColor),
          const SizedBox(height: 12),
          Container(height: 14, width: 200, color: tileColor),
          const SizedBox(height: 16),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 2 ? 0 : 10),
                  child: Column(
                    children: [
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(height: 12, color: tileColor),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
