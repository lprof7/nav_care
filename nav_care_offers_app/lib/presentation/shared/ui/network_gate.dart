import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/network/network_cubit.dart';
import '../../../core/network/network_state.dart';

class NetworkGate extends StatelessWidget {
  final Widget child;

  const NetworkGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, state) {
        if (state.status == NetworkStatus.connected) {
          return child;
        }

        if (!state.canShowError) {
          return const _NetworkShimmer();
        }

        final isNoInternet = state.status == NetworkStatus.noInternet;
        final theme = Theme.of(context);
        final iconColor = theme.colorScheme.primary;
        final title = isNoInternet
            ? 'network_error.title'.tr()
            : 'server_error.title'.tr();
        final subtitle = isNoInternet
            ? 'network_error.subtitle'.tr()
            : 'server_error.subtitle'.tr();

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNoInternet ? Icons.wifi_off_rounded : Icons.cloud_off,
                      size: 64,
                      color: iconColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<NetworkCubit>().recheckConnectivity(),
                      icon: const Icon(Icons.refresh),
                      label: Text('network_error.retry'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NetworkShimmer extends StatelessWidget {
  const _NetworkShimmer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;
    final tileColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.white;

    return Scaffold(
      body: SafeArea(
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
                  return _ShimmerHeader(tileColor: tileColor);
                }
                return _ShimmerSection(tileColor: tileColor);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerHeader extends StatelessWidget {
  final Color tileColor;

  const _ShimmerHeader({required this.tileColor});

  @override
  Widget build(BuildContext context) {
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

class _ShimmerSection extends StatelessWidget {
  final Color tileColor;

  const _ShimmerSection({required this.tileColor});

  @override
  Widget build(BuildContext context) {
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
