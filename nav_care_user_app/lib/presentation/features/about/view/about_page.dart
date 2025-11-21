import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/presentation/shared/theme/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final priorities = [
      _InfoTileData(
        icon: Icons.verified_rounded,
        title: 'about.priorities.quality.title'.tr(),
        description: 'about.priorities.quality.body'.tr(),
      ),
      _InfoTileData(
        icon: Icons.auto_awesome_rounded,
        title: 'about.priorities.reliability.title'.tr(),
        description: 'about.priorities.reliability.body'.tr(),
      ),
      _InfoTileData(
        icon: Icons.lock_rounded,
        title: 'about.priorities.security.title'.tr(),
        description: 'about.priorities.security.body'.tr(),
      ),
    ];

    final offers = [
      _InfoTileData(
        icon: Icons.dashboard_customize_rounded,
        title: 'about.offerings.diverse_listings.title'.tr(),
        description: 'about.offerings.diverse_listings.body'.tr(),
      ),
      _InfoTileData(
        icon: Icons.touch_app_rounded,
        title: 'about.offerings.user_experience.title'.tr(),
        description: 'about.offerings.user_experience.body'.tr(),
      ),
      _InfoTileData(
        icon: Icons.workspace_premium_rounded,
        title: 'about.offerings.subscriptions.title'.tr(),
        description: 'about.offerings.subscriptions.body'.tr(),
      ),
    ];

    final values = [
      _ValueChipData(
        label: 'about.values.community.title'.tr(),
        description: 'about.values.community.body'.tr(),
        icon: Icons.groups_rounded,
      ),
      _ValueChipData(
        label: 'about.values.customer_first.title'.tr(),
        description: 'about.values.customer_first.body'.tr(),
        icon: Icons.favorite_rounded,
      ),
      _ValueChipData(
        label: 'about.values.innovation.title'.tr(),
        description: 'about.values.innovation.body'.tr(),
        icon: Icons.lightbulb_rounded,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('about.title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroBanner(
              title: 'about.hero.title'.tr(),
              subtitle: 'about.hero.subtitle'.tr(),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'about.about_us.title'.tr(),
              body: 'about.about_us.body'.tr(),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'about.story.title'.tr(),
              body: 'about.story.body'.tr(),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'about.priorities.title'.tr(),
              body: 'about.priorities.body'.tr(),
              child: _InfoGrid(items: priorities),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'about.company.title'.tr(),
              body: 'about.company.body'.tr(),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'about.offerings.title'.tr(),
              body: 'about.offerings.body'.tr(),
              child: _InfoGrid(items: offers),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'about.values.title'.tr(),
              body: 'about.values.body'.tr(),
              child: _ValuesWrap(values: values),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: colorScheme.primary.withValues(alpha: 0.06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.health_and_safety_rounded,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'about.cta.title'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'about.cta.body'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeroBanner({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'about.title'.tr(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String body;
  final Widget? child;

  const _SectionCard({
    required this.title,
    required this.body,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.92),
              ),
            ),
            if (child != null) ...[
              const SizedBox(height: 14),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTileData {
  final IconData icon;
  final String title;
  final String description;

  _InfoTileData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _InfoGrid extends StatelessWidget {
  final List<_InfoTileData> items;

  const _InfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRTL = Directionality.of(context) == TextDirection.RTL;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 640;
        final itemWidth =
            isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: itemWidth,
                maxWidth: itemWidth,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.36),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            textAlign:
                                isWide ? TextAlign.start : TextAlign.start,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description,
                            textAlign: TextAlign.start,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ValueChipData {
  final String label;
  final String description;
  final IconData icon;

  _ValueChipData({
    required this.label,
    required this.description,
    required this.icon,
  });
}

class _ValuesWrap extends StatelessWidget {
  final List<_ValueChipData> values;

  const _ValuesWrap({required this.values});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: values.map((value) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value.icon,
                  color: colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
