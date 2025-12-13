import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_user_app/presentation/features/doctors/view/doctor_detail_page.dart';
import 'package:nav_care_user_app/presentation/features/home/view/navcare_doctors_page.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/doctor_grid_card.dart';

import '../viewmodel/recent_doctors_cubit.dart';
import '../viewmodel/recent_doctors_state.dart';

class RecentDoctorsSection extends StatelessWidget {
  const RecentDoctorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localeKey = context.locale.languageCode;
    return KeyedSubtree(
      key: ValueKey(localeKey),
      child: BlocBuilder<RecentDoctorsCubit, RecentDoctorsState>(
        builder: (context, state) {
          if (state.status == RecentDoctorsStatus.loading &&
              state.doctors.isEmpty) {
            return const _RecentDoctorsLoading();
          }

          if (state.status == RecentDoctorsStatus.failure &&
              state.doctors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/error/failure.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.message ?? 'common.error_occurred'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state.doctors.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                'home.recent_doctors.empty'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(
                  title: 'home.recent_doctors.title'.tr(),
                  actionLabel: 'home.recent_doctors.see_more'.tr(),
                  onTap: () => _openSeeMore(context),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.doctors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final doctor = state.doctors[index];
                      return _DoctorCard(doctor: doctor);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openSeeMore(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RecentDoctorsCubit>(),
          child: const NavcareDoctorsPage(
            enablePagination: true,
            titleKey: 'home.recent_doctors.title',
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final coverPath = doctor.avatarImage(baseUrl: baseUrl) ??
        doctor.coverImage(baseUrl: baseUrl);
    final displayName = doctor.displayName.trim().isNotEmpty
        ? doctor.displayName
        : doctor.specialty;
    final specialty = doctor.specialty.trim().isNotEmpty
        ? doctor.specialty
        : 'home.recent_doctors.title'.tr();

    return SizedBox(
      width: 200,
      child: DoctorGridCard(
        title: displayName,
        subtitle: specialty,
        imageUrl: coverPath,
        rating: doctor.rating > 0 ? doctor.rating : null,
        buttonLabel: 'hospitals.detail.cta.view_profile'.tr(),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DoctorDetailPage(
                doctorId: doctor.id,
                initial: doctor,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _RecentDoctorsLoading extends StatelessWidget {
  const _RecentDoctorsLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceVariant.withOpacity(0.6);
    final highlightColor = theme.colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _ShimmerBar(
                  gradient: LinearGradient(
                    colors: [
                      baseColor,
                      Color.lerp(baseColor, highlightColor, 0.7) ??
                          highlightColor,
                      baseColor,
                    ],
                    stops: const [0.2, 0.5, 0.8],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  height: 20,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              _ShimmerBar(
                gradient: LinearGradient(
                  colors: [
                    baseColor,
                    Color.lerp(baseColor, highlightColor, 0.7) ??
                        highlightColor,
                    baseColor,
                  ],
                  stops: const [0.2, 0.5, 0.8],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                width: 80,
                height: 18,
                borderRadius: BorderRadius.circular(24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, __) => _ShimmerDoctorCard(
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerDoctorCard extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerDoctorCard({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        baseColor,
        Color.lerp(baseColor, highlightColor, 0.7) ?? highlightColor,
        baseColor,
      ],
      stops: const [0.2, 0.5, 0.8],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return SizedBox(
      width: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: gradient),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _ShimmerBar(
                      gradient: gradient,
                      width: 60,
                      height: 18,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 10,
                    child: _ShimmerCircle(
                      gradient: gradient,
                      diameter: 48,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBar(
                    gradient: gradient,
                    width: 120,
                    height: 18,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  _ShimmerBar(
                    gradient: gradient,
                    width: 100,
                    height: 14,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 10),
                  _ShimmerBar(
                    gradient: gradient,
                    height: 12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 6),
                  _ShimmerBar(
                    gradient: gradient,
                    width: 140,
                    height: 12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  final Gradient gradient;
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const _ShimmerBar({
    required this.gradient,
    this.width,
    required this.height,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: gradient,
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final Gradient gradient;
  final double diameter;
  final BoxBorder? border;

  const _ShimmerCircle({
    required this.gradient,
    required this.diameter,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        gradient: gradient,
      ),
    );
  }
}
