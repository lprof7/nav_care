import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/colors.dart';

class BecomeDoctorRequiredCard extends StatelessWidget {
  final VoidCallback onBecomeDoctor;
  final EdgeInsetsGeometry padding;

  const BecomeDoctorRequiredCard({
    super.key,
    required this.onBecomeDoctor,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsBold.stethoscope,
                color: colorScheme.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'doctor_required.title'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'doctor_required.description'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onBecomeDoctor,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'doctor_required.cta'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
