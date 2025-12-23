import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/network_image.dart';

class DoctorInvitationCard extends StatelessWidget {
  final String hospitalName;
  final String status;
  final String? invitedBy;
  final String? imageUrl;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final bool isAccepting;
  final bool isDeclining;

  const DoctorInvitationCard({
    super.key,
    required this.hospitalName,
    required this.status,
    this.invitedBy,
    this.imageUrl,
    this.onAccept,
    this.onDecline,
    this.isAccepting = false,
    this.isDeclining = false,
  });

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'accepted':
        return scheme.primary;
      case 'declined':
      case 'rejected':
        return scheme.error;
      default:
        return scheme.secondary;
    }
  }

  String _statusLabel(BuildContext context) {
    final key = status.toLowerCase();
    final translated = 'hospitals.invitations.status.$key'.tr();
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
    final isPending = status.toLowerCase() == 'pending';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              NetworkImageWrapper(
                imageUrl: imageUrl,
                height: 52,
                width: 52,
                borderRadius: BorderRadius.circular(12),
                fit: BoxFit.cover,
                fallback: Container(
                  height: 52,
                  width: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsBold.buildings,
                    color: theme.colorScheme.primary,
                  ),
                ),
                shimmerChild: Container(
                  height: 52,
                  width: 52,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospitalName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (invitedBy != null && invitedBy!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'doctor_invitations.invited_by'
                            .tr(namedArgs: {'name': invitedBy!}),
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
              const SizedBox(width: 8),
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
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'doctor_invitations.accept'.tr(),
                    onPressed:
                        (isAccepting || isDeclining) ? null : onAccept,
                    icon: isAccepting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.check_rounded, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    text: 'doctor_invitations.decline'.tr(),
                    onPressed:
                        (isAccepting || isDeclining) ? null : onDecline,
                    color: theme.colorScheme.error,
                    textColor: theme.colorScheme.onError,
                    icon: isDeclining
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
