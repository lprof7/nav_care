import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/colors.dart';

class SignInRequiredCard extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;
  final VoidCallback? onGoogleSignIn;
  final EdgeInsetsGeometry padding;

  const SignInRequiredCard({
    super.key,
    required this.onSignIn,
    required this.onCreateAccount,
    this.onGoogleSignIn,
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
                Icons.lock_rounded,
                color: colorScheme.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'auth_required.title'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'auth_required.description'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onSignIn,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'sign_in'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onCreateAccount,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'auth_required.create_account'.tr(),
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (onGoogleSignIn != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: colorScheme.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Expanded(child: Divider(color: colorScheme.outlineVariant)),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onGoogleSignIn,
              icon: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'G',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandGoogleAccent,
                  ),
                ),
              ),
              label: Text(
                'sign_in_with_google'.tr(),
                style: theme.textTheme.titleMedium,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
