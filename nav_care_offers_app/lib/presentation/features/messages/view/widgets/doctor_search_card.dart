import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';

class DoctorSearchCard extends StatelessWidget {
  final DoctorModel doctor;
  final String? imageUrl;
  final VoidCallback onOpenDetail;

  const DoctorSearchCard({
    super.key,
    required this.doctor,
    required this.imageUrl,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.surfaceVariant,
            backgroundImage:
                imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage(imageUrl!) : null,
            onBackgroundImageError: (_, __) {},
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? const Icon(Icons.person_rounded)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : '--',
                      style:
                          theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onOpenDetail,
            child: Text('messages.send_message'.tr()),
          ),
        ],
      ),
    );
  }
}
