import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ShellOnboardingPage extends StatelessWidget {
  final String title;
  final String name;
  final VoidCallback onContinue;

  const ShellOnboardingPage({
    super.key,
    required this.title,
    required this.name,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.apartment_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'shell.onboarding.welcome'.tr(namedArgs: {'name': name}),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onContinue,
                child: Text('shell.onboarding.continue'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
