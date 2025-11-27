import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/hospitals/models/hospital_model.dart';
import 'package:nav_care_user_app/presentation/features/hospitals/view/hospital_detail_page.dart';
import 'package:nav_care_user_app/presentation/features/home/view/navcare_hospitals_page.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/home_hospital_card.dart';

import '../viewmodel/featured_hospitals_cubit.dart';
import '../viewmodel/featured_hospitals_state.dart';

class FeaturedHospitalsSection extends StatelessWidget {
  const FeaturedHospitalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FeaturedHospitalsBody();
  }
}

class _FeaturedHospitalsBody extends StatelessWidget {
  const _FeaturedHospitalsBody();

  @override
  Widget build(BuildContext context) {
    final localeKey = context.locale.languageCode;
    return KeyedSubtree(
      key: ValueKey(localeKey),
      child: BlocBuilder<FeaturedHospitalsCubit, FeaturedHospitalsState>(
        builder: (context, state) {
          if (state.status == FeaturedHospitalsStatus.loading) {
            return const _FeaturedHospitalsLoading();
          }

          if (state.status == FeaturedHospitalsStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/error/failure.png', // الصورة عند الفشل
                    width: 100, // تصغير حجم الصورة
                    height: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.message ?? 'common.error_occurred'.tr(), // رسالة خطأ عامة
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state.hospitals.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(
                  title: 'home.featured_hospitals.title'.tr(),
                  actionLabel: 'home.featured_hospitals.see_more'.tr(),
                  onTap: () => _openSeeMore(context, state.hospitals),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 355,
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

  void _openSeeMore(BuildContext context, List<HospitalModel> hospitals) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NavcareHospitalsPage(hospitals: hospitals),
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

class _FeaturedHospitalsLoading extends StatefulWidget {
  const _FeaturedHospitalsLoading();

  @override
  State<_FeaturedHospitalsLoading> createState() =>
      _FeaturedHospitalsLoadingState();
}

class _FeaturedHospitalsLoadingState extends State<_FeaturedHospitalsLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceVariant.withOpacity(0.6);
    final highlightColor = theme.colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final slide = _controller.value * 2 - 1; // -1 to 1
          final gradient = LinearGradient(
            begin: Alignment(-1.5 + slide, 0),
            end: Alignment(1.5 + slide, 0),
            colors: [
              baseColor,
              Color.lerp(baseColor, highlightColor, 0.7) ?? highlightColor,
              baseColor,
            ],
            stops: const [0.2, 0.5, 0.8],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ShimmerBar(
                      gradient: gradient,
                      height: 20,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _ShimmerBar(
                    gradient: gradient,
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
                    gradient: gradient,
                    baseColor: baseColor,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShimmerHospitalCard extends StatelessWidget {
  final Gradient gradient;
  final Color baseColor;

  const _ShimmerHospitalCard({
    required this.gradient,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
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
