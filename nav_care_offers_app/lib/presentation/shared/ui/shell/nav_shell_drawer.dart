import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../shared/theme/colors.dart';
import '../molecules/sign_in_required_card.dart';
import 'nav_shell_destination.dart';

class NavShellDrawer extends StatelessWidget {
  final int selectedIndex;
  final List<NavShellDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onVerifyTap;
  final Locale currentLocale;
  final List<Locale> supportedLocales;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback? onLogoutTap;
  final bool isLogoutLoading;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? userAvatar;
  final bool isProfileLoading;
  final String? profileError;
  final VoidCallback? onProfileRetry;
  final VoidCallback? onProfileTap;
  final bool isAuthenticated;
  final VoidCallback? onSignInTap;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onGoogleSignInTap;
  final VoidCallback? onFaqTap;
  final VoidCallback? onContactTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onFeedbackTap;
  final VoidCallback? onSupportTap;
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;

  const NavShellDrawer({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.currentLocale,
    required this.supportedLocales,
    required this.onLocaleChanged,
    this.onVerifyTap,
    this.onLogoutTap,
    this.isLogoutLoading = false,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userAvatar,
    this.isProfileLoading = false,
    this.profileError,
    this.onProfileRetry,
    this.onProfileTap,
    this.isAuthenticated = false,
    this.onSignInTap,
    this.onSignUpTap,
    this.onGoogleSignInTap,
    this.onFaqTap,
    this.onContactTap,
    this.onSettingsTap,
    this.onAboutTap,
    this.onFeedbackTap,
    this.onSupportTap,
    required this.themeMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<dynamic> allDrawerItems = [
      ...destinations,
      _DrawerAction(
        icon: PhosphorIconsBold.question,
        label: 'shell.drawer_faq'.tr(),
        onTap: onFaqTap,
      ),
      _DrawerAction(
        icon: PhosphorIconsBold.envelopeSimple,
        label: 'shell.drawer_contact'.tr(),
        onTap: onContactTap,
      ),
      _DrawerAction(
        icon: PhosphorIconsBold.info,
        label: 'shell.drawer_about'.tr(),
        onTap: onAboutTap,
      ),
      _DrawerAction(
        icon: PhosphorIconsBold.chatTeardropText,
        label: 'shell.drawer_feedback'.tr(),
        onTap: onFeedbackTap,
      ),
    ];

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
                userName: userName,
                userEmail: userEmail,
                userPhone: userPhone,
                userAvatar: userAvatar,
                isProfileLoading: isProfileLoading,
                profileError: profileError,
                onProfileRetry: onProfileRetry,
                onProfileTap: onProfileTap,
                isAuthenticated: isAuthenticated,
                onSignInTap: onSignInTap == null
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        onSignInTap?.call();
                      },
                onSignUpTap: onSignUpTap == null
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        onSignUpTap?.call();
                      },
                onGoogleSignInTap: onGoogleSignInTap == null
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        onGoogleSignInTap?.call();
                      },
                onFaqTap: onFaqTap,
                onContactTap: onContactTap,
                onSettingsTap: onSettingsTap,
                onAboutTap: onAboutTap,
                onFeedbackTap: onFeedbackTap,
                onSupportTap: onSupportTap,
                themeMode: themeMode,
                onThemeToggle: onThemeToggle,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemBuilder: (context, index) {
                  final item = allDrawerItems[index];

                  if (item is NavShellDestination) {
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
                                item.icon,
                                color: isSelected
                                    ? colorScheme.primary
                                    : theme.iconTheme.color,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
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
                              if (item.badgeLabel != null)
                                _BadgeChip(label: item.badgeLabel!),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (item is _DrawerAction) {
                    return _DrawerActionTile(
                      icon: item.icon,
                      label: item.label,
                      onTap: () {
                        Navigator.of(context).pop();
                        item.onTap?.call();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: allDrawerItems.length,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                PhosphorIconsBold.signOut,
                color: theme.iconTheme.color,
              ),
              title: Text(
                'shell.drawer_logout'.tr(),
                style: theme.textTheme.bodyMedium,
              ),
              enabled: isAuthenticated && !isLogoutLoading,
              trailing: isLogoutLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: () {
                if (isLogoutLoading || !isAuthenticated) return;
                Navigator.of(context).pop();
                onLogoutTap?.call();
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
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? userAvatar;
  final bool isProfileLoading;
  final String? profileError;
  final VoidCallback? onProfileRetry;
  final VoidCallback? onProfileTap;
  final bool isAuthenticated;
  final VoidCallback? onSignInTap;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onGoogleSignInTap;
  final VoidCallback? onFaqTap;
  final VoidCallback? onContactTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onFeedbackTap;
  final VoidCallback? onSupportTap;
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;

  const _DrawerHeader({
    required this.onClose,
    required this.onVerifyTap,
    required this.currentLocale,
    required this.supportedLocales,
    required this.onLocaleChanged,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userAvatar,
    this.isProfileLoading = false,
    this.profileError,
    this.onProfileRetry,
    this.onProfileTap,
    required this.isAuthenticated,
    this.onSignInTap,
    this.onSignUpTap,
    this.onGoogleSignInTap,
    this.onFaqTap,
    this.onContactTap,
    this.onSettingsTap,
    this.onAboutTap,
    this.onFeedbackTap,
    this.onSupportTap,
    required this.themeMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayName = (userName != null && userName!.trim().isNotEmpty)
        ? userName!.trim()
        : 'shell.drawer_default_name'.tr();
    final emailLabel = (userEmail != null && userEmail!.trim().isNotEmpty)
        ? userEmail!.trim()
        : 'shell.drawer_default_email'.tr();
    final phoneLabel =
        userPhone?.trim().isNotEmpty == true ? userPhone!.trim() : null;

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
                icon: const Icon(PhosphorIconsBold.x),
                color: AppColors.textOnPrimary,
                onPressed: onClose,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'shell.drawer_theme'.tr(),
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? PhosphorIconsBold.moonStars
                      : PhosphorIconsBold.sunDim,
                  color: AppColors.textOnPrimary,
                ),
                onPressed: onThemeToggle,
              ),
              const SizedBox(width: 4),
              _LanguageSelector(
                currentLocale: currentLocale,
                supportedLocales: supportedLocales,
                onLocaleChanged: onLocaleChanged,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isAuthenticated) ...[
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
                    backgroundImage:
                        userAvatar != null ? NetworkImage(userAvatar!) : null,
                    child: userAvatar == null
                        ? Icon(
                            Icons.person_rounded,
                            color: colorScheme.primary,
                            size: 32,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emailLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              AppColors.textOnPrimary.withValues(alpha: 0.72),
                        ),
                      ),
                      if (phoneLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          phoneLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                AppColors.textOnPrimary.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                      if (isProfileLoading) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'profile.drawer_status_loading'.tr(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                      ] else if (profileError != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              PhosphorIconsBold.warning,
                              color: AppColors.textOnPrimary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'profile.drawer_status_error'.tr(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.textOnPrimary
                                      .withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            if (onProfileRetry != null)
                              TextButton(
                                onPressed: onProfileRetry,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textOnPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                ),
                                child: Text('profile.retry'.tr()),
                              ),
                          ],
                        ),
                      ],
                      if (onProfileTap != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: onProfileTap,
                          icon: const Icon(
                            PhosphorIconsBold.userCircle,
                            size: 18,
                            color: AppColors.textOnPrimary,
                          ),
                          label: Text(
                            'profile.view_profile'.tr(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ] else ...[
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _openAuthDialog(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      PhosphorIconsBold.lockKey,
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'auth_required.title'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'auth_required.description'.tr(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textOnPrimary
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      PhosphorIconsBold.caretRight,
                      size: 18,
                      color: AppColors.textOnPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openAuthDialog(BuildContext context) {
    if (onSignInTap == null &&
        onSignUpTap == null &&
        onGoogleSignInTap == null) {
      return;
    }
    final rootContext = context;
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: MediaQuery.of(sheetCtx).viewInsets,
          child: SignInRequiredCard(
            onSignIn: () {
              Navigator.of(sheetCtx).pop();
              onSignInTap?.call();
            },
            onCreateAccount: () {
              Navigator.of(sheetCtx).pop();
              onSignUpTap?.call();
            },
            onGoogleSignIn: onGoogleSignInTap == null
                ? null
                : () {
                    Navigator.of(sheetCtx).pop();
                    onGoogleSignInTap?.call();
                  },
            padding: const EdgeInsets.all(24),
          ),
        ),
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

class _DrawerActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DrawerActionTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium,
      ),
      onTap: onTap,
    );
  }
}

class _DrawerAction {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DrawerAction({
    required this.icon,
    required this.label,
    this.onTap,
  });
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
            PhosphorIconsBold.caretDown,
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
                    PhosphorIconsBold.globeHemisphereEast,
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
