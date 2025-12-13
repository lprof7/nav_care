import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/hospitals/models/hospital_model.dart';
import 'package:nav_care_user_app/presentation/features/home/view/navcare_hospitals_page.dart';
import 'package:nav_care_user_app/presentation/features/hospitals/view/hospital_detail_page.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/home_hospital_card.dart';

import '../viewmodel/recent_hospitals_cubit.dart';
import '../viewmodel/recent_hospitals_state.dart';

class RecentHospitalsSection extends StatelessWidget {
  const RecentHospitalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localeKey = context.locale.languageCode;
    return KeyedSubtree(
      key: ValueKey(localeKey),
      child: BlocBuilder<RecentHospitalsCubit, RecentHospitalsState>(
        builder: (context, state) {
          if (state.status == RecentHospitalsStatus.loading &&
              state.hospitals.isEmpty) {
            return const _RecentHospitalsLoading();
          }

          if (state.status == RecentHospitalsStatus.failure &&
              state.hospitals.isEmpty) {
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

          if (state.hospitals.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                'home.recent_hospitals.empty'.tr(),
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
                  title: 'home.recent_hospitals.title'.tr(),
                  actionLabel: 'home.recent_hospitals.see_more'.tr(),
                  onTap: () => _openSeeMore(context),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 360,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.hospitals.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final hospital = state.hospitals[index];
                      return _HospitalCard(hospital: hospital);
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
          value: context.read<RecentHospitalsCubit>(),
          child: const NavcareHospitalsPage(
            enablePagination: true,
            titleKey: 'home.recent_hospitals.title',
            emptyKey: 'home.recent_hospitals.empty',
          ),
        ),
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final HospitalModel hospital;

  const _HospitalCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final description = hospital.descriptionForLocale(locale);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final imagePath = hospital.primaryImage(baseUrl: baseUrl);
    final facilityLabel = hospital.field.trim().isNotEmpty
        ? hospital.field
        : hospital.facilityType;
    final subtitle = description.isNotEmpty
        ? description
        : 'hospitals.detail.no_description'.tr();

    final location =
        hospital.address.trim().isNotEmpty ? hospital.address.trim() : null;

    return SizedBox(
      width: 210,
      child: HomeHospitalCard(
        title: hospital.name,
        subtitle: subtitle,
        badgeLabel: facilityLabel,
        imageUrl: imagePath,
        location: location,
        onTap: () => _openDetail(context),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HospitalDetailPage(
          hospitalId: hospital.id,
          initial: hospital,
        ),
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

class _RecentHospitalsLoading extends StatelessWidget {
  const _RecentHospitalsLoading();

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
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, __) => _ShimmerHospitalCard(
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

class _ShimmerHospitalCard extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerHospitalCard({
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
      width: 260,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 220,
          color: baseColor.withOpacity(0.8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: gradient),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBar(
                      gradient: gradient,
                      width: 120,
                      height: 24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(height: 14),
                    _ShimmerBar(
                      gradient: gradient,
                      width: 160,
                      height: 18,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 8),
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
