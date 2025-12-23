import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_user_app/presentation/features/doctors/view/doctor_detail_page.dart';
import 'package:nav_care_user_app/presentation/features/home/view/navcare_doctors_page.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/doctor_grid_card.dart';

import '../viewmodel/featured_doctors_cubit.dart';
import '../viewmodel/featured_doctors_state.dart';

class FeaturedDoctorsSection extends StatelessWidget {
  const FeaturedDoctorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FeaturedDoctorsBody();
  }
}

class _FeaturedDoctorsBody extends StatelessWidget {
  const _FeaturedDoctorsBody();

  @override
  Widget build(BuildContext context) {
    final localeKey = context.locale.languageCode;
    return KeyedSubtree(
      key: ValueKey(localeKey),
      child: BlocBuilder<FeaturedDoctorsCubit, FeaturedDoctorsState>(
        builder: (context, state) {
          switch (state.status) {
            case FeaturedDoctorsStatus.loading:
              if (state.doctors.isEmpty) {
                return const _FeaturedDoctorsLoading();
              }
              break;
            case FeaturedDoctorsStatus.failure:
              if (state.doctors.isEmpty) {
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
              break;
            case FeaturedDoctorsStatus.loaded:
              break;
            case FeaturedDoctorsStatus.initial:
              return const SizedBox.shrink();
          }

          if (state.doctors.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                'home.featured_doctors.empty'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FeaturedSectionHeader(
                  title: 'home.featured_doctors.title'.tr(),
                  actionLabel: 'home.featured_doctors.see_more_with_icon'.tr(),
                  onTap: () => _openSeeMore(context),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 290,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.doctors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final doctor = state.doctors[index];
                      return _FeaturedDoctorCard(doctor: doctor);
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
          value: context.read<FeaturedDoctorsCubit>(),
          child: const NavcareDoctorsPage(
            enablePagination: true,
            titleKey: 'home.featured_doctors.page_title',
          ),
        ),
      ),
    );
  }
}

class _FeaturedDoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const _FeaturedDoctorCard({required this.doctor});

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
        : 'home.featured_doctors.title'.tr();

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

class _FeaturedSectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _FeaturedSectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _FeaturedDoctorsLoading extends StatefulWidget {
  const _FeaturedDoctorsLoading();

  @override
  State<_FeaturedDoctorsLoading> createState() =>
      _FeaturedDoctorsLoadingState();
}

class _FeaturedDoctorsLoadingState extends State<_FeaturedDoctorsLoading>
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
          final slide = _controller.value * 2 - 1;
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
                    child: _FeaturedShimmerBar(
                      gradient: gradient,
                      height: 20,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _FeaturedShimmerBar(
                    gradient: gradient,
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
                  itemBuilder: (_, __) => _FeaturedShimmerDoctorCard(
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

class _FeaturedShimmerDoctorCard extends StatelessWidget {
  final Gradient gradient;
  final Color baseColor;

  const _FeaturedShimmerDoctorCard({
    required this.gradient,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
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
                    child: _FeaturedShimmerBar(
                      gradient: gradient,
                      width: 60,
                      height: 18,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 10,
                    child: _FeaturedShimmerCircle(
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
                  _FeaturedShimmerBar(
                    gradient: gradient,
                    width: 120,
                    height: 18,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  _FeaturedShimmerBar(
                    gradient: gradient,
                    width: 100,
                    height: 14,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 10),
                  _FeaturedShimmerBar(
                    gradient: gradient,
                    height: 12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 6),
                  _FeaturedShimmerBar(
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

class _FeaturedShimmerBar extends StatelessWidget {
  final Gradient gradient;
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const _FeaturedShimmerBar({
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

class _FeaturedShimmerCircle extends StatelessWidget {
  final Gradient gradient;
  final double diameter;
  final BoxBorder? border;

  const _FeaturedShimmerCircle({
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
