import 'package:flutter/material.dart';

class HospitalCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String facilityLabel;
  final String? phoneLabel;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? trailing;
  final List<Widget> footer;

  const HospitalCard({
    super.key,
    required this.title,
    required this.facilityLabel,
    this.subtitle,
    this.phoneLabel,
    this.imageUrl,
    this.onTap,
    this.trailing,
    this.footer = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? theme.colorScheme.surfaceContainerLow : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: const Color(0x14000000),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(theme),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTexts(theme)),
                      if (trailing != null) trailing!,
                    ],
                  ),
                  if (phoneLabel != null && phoneLabel!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            phoneLabel!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (footer.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: footer,
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

  Widget _buildHeaderImage(ThemeData theme) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        height: 160,
        width: double.infinity,
        color: theme.colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.local_hospital_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: theme.colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTexts(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            facilityLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
