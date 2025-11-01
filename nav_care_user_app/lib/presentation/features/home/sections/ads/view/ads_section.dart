import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../viewmodel/ads_section_cubit.dart';

class AdsSectionView extends StatelessWidget {
  const AdsSectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdsSectionCubit(),
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
        if (state.images.isEmpty) {
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
                    itemBuilder: (context, index) {
                      final asset =
                          state.images[index % state.images.length];
                      return Image.asset(
                        asset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      );
                    },
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < state.images.length; i++)
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
