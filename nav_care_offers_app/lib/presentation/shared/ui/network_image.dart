import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/network/network_cubit.dart';
import '../../../core/network/network_state.dart';

class NetworkImageWrapper extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? fallback;
  final Widget? shimmerChild;

  const NetworkImageWrapper({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
    this.shimmerChild,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius;
    Widget content = _NetworkImageCore(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      fallback: fallback,
      shimmerChild: shimmerChild,
    );

    if (radius != null) {
      content = ClipRRect(
        borderRadius: radius,
        child: content,
      );
    }
    return content;
  }
}

class _NetworkImageCore extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? fallback;
  final Widget? shimmerChild;

  const _NetworkImageCore({
    required this.imageUrl,
    this.height,
    this.width,
    required this.fit,
    this.fallback,
    this.shimmerChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return fallback ?? _defaultFallback(theme);
    }

    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, state) {
        final showError =
            state.status != NetworkStatus.connected && state.canShowError;
        final showShimmer =
            state.status != NetworkStatus.connected && !state.canShowError;

        if (showShimmer) {
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: shimmerChild ??
                Container(
                  height: height,
                  width: width,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
          );
        }

        if (showError) {
          return fallback ?? _defaultFallback(theme);
        }

        return Image.network(
          imageUrl!,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback ?? _defaultFallback(theme),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: shimmerChild ??
                  Container(
                    height: height,
                    width: width,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
            );
          },
        );
      },
    );
  }

  Widget _defaultFallback(ThemeData theme) {
    return Container(
      height: height,
      width: width,
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
