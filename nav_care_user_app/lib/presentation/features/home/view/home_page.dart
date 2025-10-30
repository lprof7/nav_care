import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../sections/ads/view/ads_section.dart';
import '../sections/recent_services/view/recent_services_section.dart';
import '../sections/featured_services/view/featured_services_section.dart';
import '../sections/hospitals_choice/view/hospitals_choice_section.dart';
import '../sections/doctors_choice/view/doctors_choice_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: const [
        _BecomeDoctorBanner(),
        AdsSectionView(),
        FeaturedServicesSection(),
        HospitalsChoiceSection(),
        DoctorsChoiceSection(),
        RecentServicesSection(),
      ],
    );
  }
}

class _BecomeDoctorBanner extends StatelessWidget {
  const _BecomeDoctorBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.2),
              colorScheme.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.35),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 360;
            return isWide
                ? Row(
                    children: [
                      Expanded(child: _BannerText(theme)),
                      const SizedBox(width: 16),
                      _BannerButton(colorScheme),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BannerText(theme),
                      const SizedBox(height: 12),
                      _BannerButton(colorScheme),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _BannerText extends StatelessWidget {
  final ThemeData theme;

  const _BannerText(this.theme);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'home.banner.become_doctor.title'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'home.banner.become_doctor.subtitle'.tr(),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _BannerButton extends StatelessWidget {
  final ColorScheme colorScheme;

  const _BannerButton(this.colorScheme);

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.arrow_forward_rounded),
      label: Text('home.banner.become_doctor.cta'.tr()),
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
