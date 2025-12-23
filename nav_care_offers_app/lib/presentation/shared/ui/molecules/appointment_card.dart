import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nav_care_offers_app/data/appointments/models/appointment_model.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.trailing,
    this.onEditStatus,
  });

  final AppointmentModel appointment;
  final VoidCallback? onTap;
  final Widget? trailing;
  final VoidCallback? onEditStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final start = DateTime.tryParse(appointment.startTime);
    final end = DateTime.tryParse(appointment.endTime);

    final localeTag = context.locale.toLanguageTag();
    final rangeLabel = _formatRange(localeTag, start, end) ??
        '${appointment.startTime} → ${appointment.endTime}';
    final priceLabel = NumberFormat.simpleCurrency(
      locale: localeTag,
    ).format(appointment.price);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.4),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 16),
              ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 420;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PatientAvatar(imageUrl: appointment.patient.profilePicture),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _HeaderInfo(
                        appointment: appointment,
                        isCompact: isCompact,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _StatusChip(status: appointment.status),
                        if (trailing != null) ...[
                          const SizedBox(height: 12),
                          trailing!,
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _InfoWrap(
                  rangeLabel: rangeLabel,
                  priceLabel: priceLabel,
                  serviceName: appointment.service.name,
                  specialty: appointment.provider.specialty,
                  providerName: appointment.provider.user.name,
                ),
                const SizedBox(height: 16),
                _ContactRow(
                  phone: appointment.patient.phone,
                  email: appointment.patient.email,
                  onEditStatus: onEditStatus,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String? _formatRange(
    String locale,
    DateTime? start,
    DateTime? end,
  ) {
    if (start == null || end == null) return null;

    final dateFormat = DateFormat.yMMMd(locale);
    final timeFormat = DateFormat.Hm(locale);
    final startSegment =
        '${dateFormat.format(start)} · ${timeFormat.format(start)}';
    final endSegment = '${dateFormat.format(end)} · ${timeFormat.format(end)}';
    return '$startSegment → $endSegment';
  }
}

class _PatientAvatar extends StatelessWidget {
  const _PatientAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
          height: 72,
          width: 72,
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
          child: imageUrl.isEmpty
              ? Icon(
                  Icons.person_outline,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                )
              : NetworkImageWrapper(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  fallback: Icon(
                    Icons.person_outline,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shimmerChild: Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                )),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  const _HeaderInfo({
    required this.appointment,
    required this.isCompact,
  });

  final AppointmentModel appointment;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appointment.patient.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          appointment.patient.phone,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${appointment.service.name} • ${appointment.provider.user.name}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: isCompact ? 1.4 : 1.6,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = _statusColor(theme, status);
    final label = _statusLabel(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoWrap extends StatelessWidget {
  const _InfoWrap({
    required this.rangeLabel,
    required this.priceLabel,
    required this.serviceName,
    required this.specialty,
    required this.providerName,
  });

  final String rangeLabel;
  final String priceLabel;
  final String serviceName;
  final String specialty;
  final String providerName;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _InfoPill(
          icon: Icons.schedule_rounded,
          label: rangeLabel,
        ),
        _InfoPill(
          icon: Icons.sell_outlined,
          label: priceLabel,
        ),
        _InfoPill(
          icon: PhosphorIconsBold.stethoscope,
          label: serviceName,
        ),
        _InfoPill(
          icon: Icons.person_pin_circle_outlined,
          label: '$providerName · $specialty',
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.phone,
    required this.email,
    this.onEditStatus,
  });

  final String phone;
  final String email;
  final VoidCallback? onEditStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          height: 32,
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _ContactDetail(
              icon: Icons.phone_outlined,
              value: phone,
            ),
            _ContactDetail(
              icon: Icons.mail_outline_rounded,
              value: email,
            ),
          ],
        ),
        if (onEditStatus != null) ...[
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 180,
              child: AppButton(
                text: 'appointments.list.change_status'.tr(),
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: onEditStatus,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ContactDetail extends StatelessWidget {
  const _ContactDetail({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          value,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

Color _statusColor(ThemeData theme, String status) {
  final colorScheme = theme.colorScheme;
  switch (status) {
    case 'confirmed':
      return Colors.green.shade700;
    case 'completed':
      return Colors.teal.shade700;
    case 'cancelled':
      return colorScheme.error;
    default:
      return colorScheme.primary;
  }
}

String _statusLabel(BuildContext context, String status) {
  final key = 'appointment_status.$status';
  final translated = key.tr();
  if (translated != key) return translated;
  const fallback = {
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };
  return fallback[status] ?? status;
}
