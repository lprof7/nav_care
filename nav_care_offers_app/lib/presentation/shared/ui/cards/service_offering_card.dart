import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/network_image.dart';

/// Reusable card for displaying a service offering (title, subtitle, badge/price, image, actions).
class ServiceOfferingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeLabel;
  final String? priceLabel;
  final String? imageUrl;
  final String? baseUrl;
  final VoidCallback? onPressed;
  final VoidCallback? onTap;
  final bool isSaved;
  final VoidCallback? onToggleSave;
  final String? buttonLabel;
  final double? rating;

  const ServiceOfferingCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
    this.priceLabel,
    this.imageUrl,
    this.baseUrl,
    this.onPressed,
    this.onTap,
    this.isSaved = false,
    this.onToggleSave,
    this.buttonLabel,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final badge = badgeLabel;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap ?? onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withOpacity(0.07), width: 1),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 96,
                        width: double.infinity,
                        child: _buildImage(
                          imageUrl: imageUrl,
                          baseUrl: baseUrl,
                          fit: BoxFit.cover,
                          placeholderColor: theme.colorScheme.surfaceVariant,
                        ),
                      ),
                    ),
                    if (onToggleSave != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          icon: Icon(
                            isSaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border,
                            color: isSaved ? accent : Colors.blueGrey,
                          ),
                          onPressed: onToggleSave,
                        ),
                      ),
                    if (badge != null && badge.isNotEmpty)
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 16, color: accent),
                              const SizedBox(width: 6),
                              Text(
                                badge,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 36,
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    ),
                    if (rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating! > 0 ? rating!.toStringAsFixed(1) : '--',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (priceLabel != null && priceLabel!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        priceLabel!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed ?? onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F73F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      buttonLabel?.tr() ??
                          'hospitals.actions.view_details'.tr(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildImage({
  required String? imageUrl,
  String? baseUrl,
  required BoxFit fit,
  Color? placeholderColor,
}) {
  final color = placeholderColor ?? Colors.grey.shade200;
  if (imageUrl == null || imageUrl.isEmpty) {
    return Container(
      color: color,
      alignment: Alignment.center,
    );
  }

  // Resolve relative path to a full URL when possible (align with detail page behavior).
  final resolvedUrl = () {
    if (imageUrl.startsWith('https')) return imageUrl;
    if (baseUrl != null && baseUrl.isNotEmpty) {
      try {
        return Uri.parse(baseUrl).resolve(imageUrl).toString();
      } catch (_) {
        return imageUrl;
      }
    }
    return imageUrl;
  }();

  if (resolvedUrl.startsWith('http')) {
    return NetworkImageWrapper(
      imageUrl: resolvedUrl,
      fit: fit,
      fallback: Container(
        color: color,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_rounded),
      ),
      shimmerChild: Container(color: color),
    );
  }

  // If still not a valid URL, show fallback instead of attempting asset load.
  return Container(
    color: color,
    alignment: Alignment.center,
  );
}

class LargServiceOfferingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeLabel;
  final String? priceLabel;
  final String? imageUrl;
  final String? baseUrl;
  final VoidCallback? onPressed;
  final VoidCallback? onTap;
  final bool isSaved;
  final VoidCallback? onToggleSave;
  final String? buttonLabel;
  final double? rating;

  const LargServiceOfferingCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
    this.priceLabel,
    this.imageUrl,
    this.baseUrl,
    this.onPressed,
    this.onTap,
    this.isSaved = false,
    this.onToggleSave,
    this.buttonLabel,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final badge = badgeLabel;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap ?? onPressed,
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withOpacity(0.07), width: 1),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _buildImage(
                            imageUrl: imageUrl,
                            baseUrl: baseUrl,
                            fit: BoxFit.cover,
                            placeholderColor: theme.colorScheme.surfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    if (onToggleSave != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          icon: Icon(
                            isSaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border,
                            color: isSaved ? accent : Colors.blueGrey,
                          ),
                          onPressed: onToggleSave,
                        ),
                      ),
                    if (badge != null && badge.isNotEmpty)
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 16, color: accent),
                              const SizedBox(width: 6),
                              Text(
                                badge,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 42,
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    ),
                    if (rating != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating! > 0 ? rating!.toStringAsFixed(1) : '--',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (priceLabel != null && priceLabel!.isNotEmpty) ...[
                      Text(
                        priceLabel!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed ?? onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F73F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      buttonLabel?.tr() ??
                          'hospitals.actions.view_details'.tr(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
