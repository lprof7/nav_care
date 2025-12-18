import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'nav_shell_destination.dart';

class NavShellNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavShellDestination> destinations;

  const NavShellNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SalomonBottomBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: destinations
              .map(
                (destination) => SalomonBottomBarItem(
                  icon: Icon(destination.icon),
                  title: Text(destination.label),
                  selectedColor: colorScheme.primary,
                  unselectedColor:
                      theme.textTheme.bodyMedium?.color ?? colorScheme.secondary,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
