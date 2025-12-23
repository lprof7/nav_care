import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_user_app/presentation/features/home/view/navcare_doctors_page.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/doctor_grid_card.dart';
import 'package:nav_care_user_app/presentation/features/doctors/view/doctor_detail_page.dart';

import '../viewmodel/doctors_choice_cubit.dart';
import '../viewmodel/doctors_choice_state.dart';

class DoctorsChoiceSection extends StatelessWidget {
  const DoctorsChoiceSection({
    super.key,
    this.translationPrefix = 'home.doctors_choice',
  });

  final String translationPrefix;

  @override
  Widget build(BuildContext context) {
    return _DoctorsChoiceBody(translationPrefix: translationPrefix);
  }
}

class _DoctorsChoiceBody extends StatelessWidget {
  final String translationPrefix;

  const _DoctorsChoiceBody({required this.translationPrefix});

  String _tr(BuildContext context, String key) =>
      '$translationPrefix.$key'.tr();

  @override
  Widget build(BuildContext context) {
    final localeKey = context.locale.languageCode;
    return KeyedSubtree(
      key: ValueKey(localeKey),
      child: BlocBuilder<DoctorsChoiceCubit, DoctorsChoiceState>(
        builder: (context, state) {
          if (state.status == DoctorsChoiceStatus.loading &&
              state.doctors.isEmpty) {
            return const _DoctorsChoiceLoading();
          }

          if (state.status == DoctorsChoiceStatus.failure &&
              state.doctors.isEmpty) {
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
                    state.message ??
                        'common.error_occurred'.tr(), // رسالة خطأ عامة
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
                _tr(context, 'empty'),
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
                  title: _tr(context, 'title'),
                  actionLabel: _tr(context, 'see_more'),
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
          value: context.read<DoctorsChoiceCubit>(),
          child: NavcareDoctorsPage(
            titleKey: '$translationPrefix.title',
            enablePagination: true,
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
        : 'home.doctors_choice.title'.tr();

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

class _DoctorsChoiceLoading extends StatefulWidget {
  const _DoctorsChoiceLoading();

  @override
  State<_DoctorsChoiceLoading> createState() => _DoctorsChoiceLoadingState();
}

class _DoctorsChoiceLoadingState extends State<_DoctorsChoiceLoading>
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
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, __) => _ShimmerDoctorCard(
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

class _ShimmerDoctorCard extends StatelessWidget {
  final Gradient gradient;
  final Color baseColor;

  const _ShimmerDoctorCard({
    required this.gradient,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: baseColor.withOpacity(0.8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
