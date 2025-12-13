import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class NavShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String logoAssetPath;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSupportTap;
  final VoidCallback? onFavoritesTap;
  final VoidCallback? onNotificationsTap;
  final int notificationCount;

  const NavShellAppBar({
    super.key,
    this.logoAssetPath = 'assets/images/shell/navcare_logo.png',
    this.onMenuTap,
    this.onSupportTap,
    this.onFavoritesTap,
    this.onNotificationsTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _RoundedIconButton(
                icon: Icons.menu_rounded,
                onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Center(
                  child: Image.asset(
                    logoAssetPath,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _RoundedIconButton(
                    icon: Icons.notifications_none_rounded,
                    onPressed: onNotificationsTap,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      top: -4,
                      right: -2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          notificationCount > 9
                              ? '9+'
                              : notificationCount.toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}

class _RoundedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _RoundedIconButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
