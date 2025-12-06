import 'package:flutter/material.dart';

/// Shared doctor card used across home sections and hospital details.
class DoctorGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final String? imageUrl;
  final double? rating;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;

  const DoctorGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.imageUrl,
    this.rating,
    this.onTap,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardRadius = 28.0;
    final showButton = buttonLabel != null && buttonLabel!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: Colors.black.withOpacity(0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(cardRadius),
        onTap: onTap ?? onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة الطبيب – تغطي الجزء العلوي بالكامل مثل التصميم
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cardRadius),
                topRight: Radius.circular(cardRadius),
              ),
              child: SizedBox(
                height: 135,
                child: _buildImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholderColor: theme.colorScheme.surfaceVariant,
                ),
              ),
            ),

            // الاسم + علامة التوثيق
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // أيقونة التوثيق (مثل الصورة)
                  Icon(
                    Icons.verified_rounded,
                    size: 18,
                    color: const Color(0xFF0F73F6),
                  ),
                ],
              ),
            ),

            // التخصص / الوصف
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  height: 1.35,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // السطر السفلي: التقييم على اليسار + زر زيارة البروفايل على اليمين
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  if (rating != null && rating! > 0)
                    _RatingBadge(rating: rating)
                  else
                    const SizedBox.shrink(),
                  if (showButton) ...[
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onPressed ?? onTap,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF0F73F6),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_outward_rounded,
                            size: 18,
                          ),
                          label: Text(
                            buttonLabel!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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

    if (rating == null || rating! <= 0) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star_rounded,
          size: 18,
          color: Color(0xFFFFB33E),
        ),
        const SizedBox(width: 4),
        Text(
          rating!.toStringAsFixed(1),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
