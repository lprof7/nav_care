import 'package:flutter/material.dart';

/// Shared doctor card used across home sections and hospital details.
class DoctorGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final String? imageUrl;
  final double? rating;
  final bool isSaved;
  final VoidCallback? onToggleSave;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;

  const DoctorGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.imageUrl,
    this.rating,
    this.isSaved = false,
    this.onToggleSave,
    this.onTap,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap ?? onPressed,
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
                  SizedBox(
                    height: 20,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
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
            if (buttonLabel != null && buttonLabel!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed ?? onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F73F6),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(buttonLabel!),
                  ),
                ),
              ),
            ] else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
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
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
      child: const Icon(Icons.person_rounded),
    );
  }

  return Image.network(
    imageUrl,
    fit: fit,
    errorBuilder: (_, __, ___) => Container(
      color: color,
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded),
    ),
  );
}
