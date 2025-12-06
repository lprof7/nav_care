import 'package:characters/characters.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeHospitalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeLabel;
  final String? imageUrl;
  final VoidCallback? onTap;
  final String? location;

  const HomeHospitalCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    this.imageUrl,
    this.onTap,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final leadingLetter = _safeLeadingLetter(title);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      shadowColor: accent.withOpacity(0.08),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 130,
                      width: double.infinity,
                      child: _buildImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholderColor: theme.colorScheme.surfaceVariant,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -26,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
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
                                    style: theme.textTheme.titleLarge?.copyWith(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 28, 12, 0),
              child: Column(
                children: [
                  SizedBox(
                    height: 40, // تحديد ارتفاع ثابت للعنوان
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      badgeLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36, // تحديد ارتفاع ثابت للوصف
                    child: Text(
                      subtitle.isNotEmpty
                          ? subtitle
                          : 'hospitals.detail.no_description'.tr(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  if (location != null && location!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 16, color: accent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

String _safeLeadingLetter(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.characters.first.toUpperCase();
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
