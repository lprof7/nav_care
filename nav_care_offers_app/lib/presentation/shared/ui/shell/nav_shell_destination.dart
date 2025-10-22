import 'package:flutter/material.dart';

class NavShellDestination {
  final String label;
  final IconData icon;
  final Widget content;
  final String? badgeLabel;

  const NavShellDestination({
    required this.label,
    required this.icon,
    required this.content,
    this.badgeLabel,
  });
}
