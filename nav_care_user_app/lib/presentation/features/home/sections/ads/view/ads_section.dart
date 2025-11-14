import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/presentation/shared/ui/molecules/advertising_card.dart';

import '../viewmodel/ads_section_cubit.dart';

class AdsSectionView extends StatelessWidget {
  const AdsSectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdsSectionCubit>(),
      child: const _AdsSectionBody(),
    );
  }
}

class _AdsSectionBody extends StatelessWidget {
  const _AdsSectionBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsSectionCubit, AdsSectionState>(
      builder: (context, state) {
        if (state.status == AdsSectionStatus.loading) {
          return const _AdsSectionLoading();
        }

        if (state.status == AdsSectionStatus.failure) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Text(
              state.message ?? 'home.ads_section.error'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        if (state.advertisings.isEmpty) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<AdsSectionCubit>();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: AspectRatio(
            aspectRatio: 64 / 27,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: cubit.pageController,
                    onPageChanged: cubit.onPageChanged,
                    itemCount: state.advertisings.length *
                        20, // For infinite loop effect
                    itemBuilder: (context, index) {
                      final advertising =
                          state.advertisings[index % state.advertisings.length];
                      return AdvertisingCard(advertising: advertising);
                    },
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < state.advertisings.length; i++)
                          _IndicatorDot(
                            isActive: i == state.currentIndex,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  final bool isActive;

  const _IndicatorDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary
            : colorScheme.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _AdsSectionLoading extends StatefulWidget {
  const _AdsSectionLoading();

  @override
  State<_AdsSectionLoading> createState() => _AdsSectionLoadingState();
}

class _AdsSectionLoadingState extends State<_AdsSectionLoading>
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

          return AspectRatio(
            aspectRatio: 64 / 27,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _ShimmerBar(
                gradient: gradient,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
          );
        },
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
