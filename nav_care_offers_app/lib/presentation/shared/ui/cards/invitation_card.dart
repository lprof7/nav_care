import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/network_image.dart';

class InvitationCard extends StatelessWidget {
  final String doctorName;
  final String status;
  final String? invitedBy;
  final String? imageUrl;
  final VoidCallback? onCancel;
  final bool isCancelling;

  const InvitationCard({
    super.key,
    required this.doctorName,
    required this.status,
    this.invitedBy,
    this.imageUrl,
    this.onCancel,
    this.isCancelling = false,
  });

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'accepted':
        return scheme.primary;
      case 'rejected':
        return scheme.error;
      default:
        return scheme.secondary;
    }
  }

  String _statusLabel(BuildContext context) {
    final key = status.toLowerCase();
    final translated =
        'hospitals.invitations.status.$key'.tr(); // Fallback handled below
    if (translated.startsWith('hospitals.invitations.status')) {
      return status;
    }
    return translated;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(context);
    final statusLabel = _statusLabel(context);
    final canCancel = onCancel != null && status.toLowerCase() == 'pending';
    final fallbackAvatar = Container(
      height: 44,
      width: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        doctorName.isNotEmpty ? doctorName.characters.first : '?',
        style: theme.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          NetworkImageWrapper(
            imageUrl: imageUrl,
            height: 44,
            width: 44,
            borderRadius: BorderRadius.circular(22),
            fit: BoxFit.cover,
            fallback: fallbackAvatar,
            shimmerChild: Container(
              height: 44,
              width: 44,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (invitedBy != null && invitedBy!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    invitedBy!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Chip(
                label: Text(statusLabel),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                backgroundColor: color.withOpacity(0.12),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                side: BorderSide(color: color.withOpacity(0.3)),
              ),
              if (canCancel) ...[
                const SizedBox(height: 6),
                ActionChip(
                  onPressed: isCancelling ? null : onCancel,
                  label: isCancelling
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 6),
                            Text('hospitals.detail.invitation_cancel'.tr()),
                          ],
                        )
                      : Text('hospitals.detail.invitation_cancel'.tr()),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.4),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
