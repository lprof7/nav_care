import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_user_app/presentation/features/home/view/navcare_doctors_page.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/ads/view/ads_section.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/ads/viewmodel/ads_section_cubit.dart';

import '../viewmodel/doctors_choice_cubit.dart';
import '../viewmodel/doctors_choice_state.dart';

class DoctorsChoiceSection extends StatelessWidget {
  const DoctorsChoiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DoctorsChoiceCubit>()..loadDoctors(),
      child: const _DoctorsChoiceBody(),
    );
  }
}

class _DoctorsChoiceBody extends StatelessWidget {
  const _DoctorsChoiceBody();

  @override
  Widget build(BuildContext context) {
    final localeKey = context.locale.languageCode;
    return KeyedSubtree(
      key: ValueKey(localeKey),
      child: BlocBuilder<DoctorsChoiceCubit, DoctorsChoiceState>(
        builder: (context, state) {
          if (state.status == DoctorsChoiceStatus.loading) {
            return const _DoctorsChoiceLoading();
          }

          if (state.status == DoctorsChoiceStatus.failure) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                state.message ?? 'home.doctors_choice.error'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          if (state.doctors.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(
                  title: 'home.doctors_choice.title'.tr(),
                  actionLabel: 'home.doctors_choice.see_more'.tr(),
                  onTap: () => _openSeeMore(context, state.doctors),
                ),
                const SizedBox(height: 16),
                // New AdsSectionView for Doctors Choice
                BlocProvider(
                  create: (_) => sl<AdsSectionCubit>(),
                  child: const AdsSectionView(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
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

  void _openSeeMore(BuildContext context, List<DoctorModel> doctors) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NavcareDoctorsPage(doctors: doctors),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;
    final bio = doctor.bioForLocale(locale);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final coverPath = doctor.coverImage(baseUrl: baseUrl);
    final avatarPath = doctor.avatarImage(baseUrl: baseUrl);
    final displayName = doctor.displayName.trim().isNotEmpty
        ? doctor.displayName
        : doctor.specialty;
    final specialty = doctor.specialty.trim().isNotEmpty
        ? doctor.specialty
        : 'home.doctors_choice.title'.tr();

    return SizedBox(
      width: 200,
      child: GestureDetector(
        onTap: () {},
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
                  fit: StackFit.expand,
                  children: [
                    _DoctorCoverImage(path: coverPath),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.45),
                          ],
                        ),
                      ),
                    ),
                    if (doctor.rating > 0)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                doctor.rating.toStringAsFixed(1),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (avatarPath != null)
                      Positioned(
                        left: 16,
                        bottom: 4,
                        child: _DoctorAvatarImage(path: avatarPath),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
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

class _DoctorCoverImage extends StatelessWidget {
  final String? path;

  const _DoctorCoverImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget placeholder(
        {IconData icon = Icons.person_rounded, double size = 48}) {
      return Container(
        color: theme.colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(icon, size: size),
      );
    }

    final imagePath = path;
    if (imagePath == null || imagePath.isEmpty) {
      return placeholder();
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder(icon: Icons.person_outline_rounded, size: 40);
        },
        errorBuilder: (context, error, stackTrace) =>
            placeholder(icon: Icons.image_not_supported_rounded, size: 36),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          placeholder(icon: Icons.image_not_supported_rounded, size: 36),
    );
  }
}

class _DoctorAvatarImage extends StatelessWidget {
  final String path;

  const _DoctorAvatarImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget fallback() {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.person_rounded, size: 20),
      );
    }

    if (path.startsWith('http')) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.network(
            path,
            width: 42,
            height: 42,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fallback(),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.asset(
          path,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback(),
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
