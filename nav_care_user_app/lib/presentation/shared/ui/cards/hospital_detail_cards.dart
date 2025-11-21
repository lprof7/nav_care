import 'package:flutter/material.dart';

/// Reusable bordered/raised container with drop shadow used across hospital detail screens.
class ShadowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? backgroundColor;

  const ShadowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: color,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Section wrapper with a header (icon + title) used in hospital details.
class HospitalDetailSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final EdgeInsetsGeometry contentPadding;
  final double spacing;

  const HospitalDetailSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.contentPadding = const EdgeInsets.all(14),
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ShadowCard(
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: spacing),
          child,
        ],
      ),
    );
  }
}

class HospitalOverviewStat {
  final IconData icon;
  final String label;
  final String value;

  const HospitalOverviewStat({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class HospitalOverviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double rating;
  final String? imageUrl;
  final List<HospitalOverviewStat> stats;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  const HospitalOverviewCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.stats,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    this.imageUrl,
    this.onPrimaryTap,
    this.onSecondaryTap,
    this.isSaved = false,
    this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ShadowCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SquareImage(imageUrl: imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StarRatingBar(
                          rating: rating.clamp(0, 5),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          rating > 0 ? rating.toStringAsFixed(1) : '--',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleSave,
                icon: Icon(
                  isSaved ? Icons.favorite_rounded : Icons.favorite_border,
                  color: isSaved ? theme.colorScheme.primary : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: stats
                .map((stat) => _StatItem(
                      icon: stat.icon,
                      label: stat.label,
                      value: stat.value,
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SolidActionButton(
                  label: primaryActionLabel,
                  icon: Icons.send_rounded,
                  color: const Color(0xFF2E7CF6),
                  onPressed: onPrimaryTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SolidActionButton(
                  label: secondaryActionLabel,
                  icon: Icons.call_rounded,
                  color: const Color(0xFF0F3D67),
                  onPressed: onSecondaryTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarRatingBar extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRatingBar({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final double normalized = rating.clamp(0, 5);
    return Row(
      children: List.generate(5, (index) {
        final value = normalized - index;
        final icon = value >= 1
            ? Icons.star_rounded
            : value >= 0.4
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;
        return Padding(
          padding: EdgeInsets.only(right: index == 4 ? 0 : 2),
          child: Icon(
            icon,
            size: size,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}

class _SolidActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _SolidActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class DoctorGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String? imageUrl;
  final double? rating;
  final bool isSaved;
  final VoidCallback? onToggleSave;
  final VoidCallback? onPressed;

  const DoctorGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.imageUrl,
    this.rating,
    this.isSaved = false,
    this.onToggleSave,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.1), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: _buildImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholderColor: theme.colorScheme.surfaceVariant,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _RatingBadge(rating: rating),
                ),
                if (onToggleSave != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      icon: Icon(
                        isSaved ? Icons.favorite_rounded : Icons.favorite_border,
                        color: isSaved ? accent : Colors.blueGrey,
                      ),
                      onPressed: onToggleSave,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F73F6),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(buttonLabel),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class InfoGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String? imageUrl;
  final String? badgeLabel;
  final String? priceLabel;
  final VoidCallback? onPressed;

  const InfoGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.imageUrl,
    this.badgeLabel,
    this.priceLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final badge = badgeLabel;
    final leadingLetter = _safeLeadingLetter(title);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.1), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: _buildImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholderColor: theme.colorScheme.surfaceVariant,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -26,
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F3D67),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: ClipOval(
                        child: imageUrl != null && imageUrl!.isNotEmpty
                            ? _buildImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholderColor:
                                    theme.colorScheme.surfaceVariant,
                              )
                            : Center(
                                child: Text(
                                  leadingLetter,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (badge != null && badge.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      badge,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                if (priceLabel != null && priceLabel!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    priceLabel!,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: accent, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class ServiceOfferingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeLabel;
  final String? priceLabel;
  final String? imageUrl;
  final VoidCallback? onPressed;
  final bool isSaved;
  final VoidCallback? onToggleSave;
  final String? buttonLabel;

  const ServiceOfferingCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
    this.priceLabel,
    this.imageUrl,
    this.onPressed,
    this.isSaved = false,
    this.onToggleSave,
    this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
                        isSaved ? Icons.favorite_rounded : Icons.favorite_border,
                        color: isSaved ? accent : Colors.blueGrey,
                      ),
                      onPressed: onToggleSave,
                    ),
                  ),
                if (badgeLabel != null && badgeLabel!.isNotEmpty)
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
                            badgeLabel!,
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
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey.shade700,
                  ),
                ),
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
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F73F6),
                  foregroundColor: Colors.white,
                 padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(buttonLabel ?? ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _safeLeadingLetter(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, 1).toUpperCase();
}

class _RatingBadge extends StatelessWidget {
  final double? rating;

  const _RatingBadge({this.rating});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            rating != null && rating! > 0 ? rating!.toStringAsFixed(1) : '--',
            style: theme.textTheme.labelMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final String? imageUrl;
  final double? rating;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  const _HeaderImage({
    required this.imageUrl,
    required this.rating,
    this.isSaved = false,
    this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 156,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholderColor: theme.colorScheme.surfaceVariant,
          ),
          if (rating != null)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating! > 0 ? rating!.toStringAsFixed(1) : '--',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          if (onToggleSave != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                icon: Icon(
                  isSaved ? Icons.favorite_rounded : Icons.favorite_border,
                  color: isSaved ? theme.colorScheme.primary : null,
                ),
                onPressed: onToggleSave,
              ),
            ),
        ],
      ),
    );
  }
}

class _SquareImage extends StatelessWidget {
  final String? imageUrl;

  const _SquareImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 86,
        height: 86,
        child: _buildImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholderColor: theme.colorScheme.surfaceVariant,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Widget _buildImage({
  required String? imageUrl,
  required BoxFit fit,
  Color? placeholderColor,
}) {
  final color = placeholderColor ?? Colors.grey.shade200;
  if (imageUrl == null || imageUrl.isEmpty) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_rounded),
    );
  }

  if (imageUrl.startsWith('http')) {
    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: color,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_rounded),
      ),
    );
  }

  return Image.asset(
    imageUrl,
    fit: fit,
    errorBuilder: (_, __, ___) => Container(
      color: color,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_rounded),
    ),
  );
}
