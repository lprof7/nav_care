import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/hospitals/models/hospital_model.dart';
import 'package:nav_care_user_app/presentation/features/home/view/navcare_hospitals_page.dart';

import '../viewmodel/hospitals_choice_cubit.dart';
import '../viewmodel/hospitals_choice_state.dart';

class HospitalsChoiceSection extends StatelessWidget {
  const HospitalsChoiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HospitalsChoiceCubit>()..loadHospitals(),
      child: const _HospitalsChoiceBody(),
    );
  }
}

class _HospitalsChoiceBody extends StatelessWidget {
  const _HospitalsChoiceBody();

  @override
  Widget build(BuildContext context) {
    final localeKey = context.locale.languageCode;
    return KeyedSubtree(
      key: ValueKey(localeKey),
      child: BlocBuilder<HospitalsChoiceCubit, HospitalsChoiceState>(
        builder: (context, state) {
          if (state.status == HospitalsChoiceStatus.loading) {
            return const _HospitalsChoiceLoading();
          }

          if (state.status == HospitalsChoiceStatus.failure) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                state.message ?? 'home.hospitals_choice.error'.tr(),
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
                  title: 'home.hospitals_choice.title'.tr(),
                  actionLabel: 'home.hospitals_choice.see_more'.tr(),
                  onTap: () => _openSeeMore(context, state.hospitals),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
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
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;
    final description = hospital.descriptionForLocale(locale);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final imagePath = hospital.primaryImage(baseUrl: baseUrl);
    final facilityLabel = hospital.field.trim().isNotEmpty
        ? hospital.field
        : hospital.facilityType;

    return SizedBox(
      width: 260,
      child: GestureDetector(
        onTap: () {},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _HospitalImage(path: imagePath),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monitor_heart,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            facilityLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hospital.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
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

class _HospitalImage extends StatelessWidget {
  final String? path;

  const _HospitalImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget placeholder(
        {IconData icon = Icons.medical_services_rounded, double size = 48}) {
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
          return placeholder(icon: Icons.local_hospital_rounded, size: 40);
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

class _HospitalsChoiceLoading extends StatefulWidget {
  const _HospitalsChoiceLoading();

  @override
  State<_HospitalsChoiceLoading> createState() =>
      _HospitalsChoiceLoadingState();
}

class _HospitalsChoiceLoadingState extends State<_HospitalsChoiceLoading>
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
