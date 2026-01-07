import 'package:countup/countup.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/core/utils/responsive_grid.dart';

class StatsCardData {
  final String label;
  final int value;
  final IconData icon;
  final List<Color> colors;

  const StatsCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
  });
}

class StatsSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const StatsSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class StatsGrid extends StatelessWidget {
  final List<StatsCardData> items;
  final double targetTileWidth;
  final int minColumns;
  final int maxColumns;

  const StatsGrid({
    super.key,
    required this.items,
    this.targetTileWidth = 200,
    this.minColumns = 2,
    this.maxColumns = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = responsiveGridColumns(
          constraints.maxWidth,
          minColumns: minColumns,
          maxColumns: maxColumns,
          targetTileWidth: targetTileWidth,
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.2,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => StatsCard(data: items[index]),
        );
      },
    );
  }
}

class StatsCard extends StatelessWidget {
  final StatsCardData data;

  const StatsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = Colors.white;
    final subTextColor = Colors.white.withValues(alpha: 0.82);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.colors,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              data.icon,
              color: textColor.withValues(alpha: 0.9),
            ),
          ),
          const Spacer(),
          Countup(
            begin: 0,
            end: data.value.toDouble(),
            duration: const Duration(milliseconds: 1200),
            separator: ',',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class StatsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const StatsErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('stats.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
