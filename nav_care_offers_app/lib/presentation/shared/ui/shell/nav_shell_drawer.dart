import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';

import '../../../shared/theme/colors.dart';
import 'nav_shell_destination.dart';

class NavShellDrawer extends StatelessWidget {
  final int selectedIndex;
  final List<NavShellDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onVerifyTap;
  final Locale currentLocale;
  final List<Locale> supportedLocales;
  final ValueChanged<Locale> onLocaleChanged;

  const NavShellDrawer({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.currentLocale,
    required this.supportedLocales,
    required this.onLocaleChanged,
    this.onVerifyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _DrawerHeader(
                onClose: () => Navigator.of(context).pop(),
                onVerifyTap: onVerifyTap,
                currentLocale: currentLocale,
                supportedLocales: supportedLocales,
                onLocaleChanged: onLocaleChanged,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  final isSelected = index == selectedIndex;

                  return Material(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).pop();
                        onDestinationSelected(index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              destination.icon,
                              color: isSelected
                                  ? colorScheme.primary
                                  : theme.iconTheme.color,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                destination.label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                            if (destination.badgeLabel != null)
                              _BadgeChip(label: destination.badgeLabel!),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: destinations.length,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.settings_rounded,
                color: theme.iconTheme.color,
              ),
              title: Text(
                'shell.drawer_settings'.tr(),
                style: theme.textTheme.bodyMedium,
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'shell.drawer_logout'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onVerifyTap;
  final Locale currentLocale;
  final List<Locale> supportedLocales;
  final ValueChanged<Locale> onLocaleChanged;

  const _DrawerHeader({
    required this.onClose,
    required this.onVerifyTap,
    required this.currentLocale,
    required this.supportedLocales,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textOnPrimary,
                onPressed: onClose,
              ),
              const Spacer(),
              _LanguageSelector(
                currentLocale: currentLocale,
                supportedLocales: supportedLocales,
                onLocaleChanged: onLocaleChanged,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.surface,
                  child: Icon(
                    Icons.person_rounded,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'shell.drawer_default_name'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'shell.drawer_default_email'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.textOnPrimary,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onVerifyTap,
            child: Text('shell.drawer_verify_phone'.tr()),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;

  const _BadgeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final List<Locale> supportedLocales;
  final ValueChanged<Locale> onLocaleChanged;

  const _LanguageSelector({
    required this.currentLocale,
    required this.supportedLocales,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Locale effectiveLocale = _findMatchingLocale();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: effectiveLocale,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textOnPrimary,
          ),
          dropdownColor: AppColors.primary,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (locale) {
            if (locale == null) return;
            onLocaleChanged(locale);
          },
          items: supportedLocales.map((locale) {
            final label = 'shell.language.${locale.languageCode}'.tr();
            return DropdownMenuItem<Locale>(
              value: locale,
              child: Row(
                children: [
                  const Icon(
                    Icons.language_rounded,
                    color: AppColors.textOnPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(label),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Locale _findMatchingLocale() {
    for (final locale in supportedLocales) {
      if (locale.languageCode == currentLocale.languageCode) {
        return locale;
      }
    }
    return supportedLocales.isNotEmpty ? supportedLocales.first : currentLocale;
  }
}
