import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/services/models/doctor_service.dart';
import 'package:nav_care_offers_app/presentation/features/home/viewmodel/doctor_services_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DoctorServicesCubit>(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? theme.colorScheme.surfaceContainerLow : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'shell.nav_home'.tr(),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'home.welcome_message'.tr(),
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          _HomeInfoCard(
            title: 'home.services_manage.title'.tr(),
            description: 'home.services_manage.subtitle'.tr(),
            icon: Icons.medical_services_outlined,
            color: theme.colorScheme.primaryContainer,
            iconColor: theme.colorScheme.onPrimaryContainer,
            onTap: () =>
                context.read<DoctorServicesCubit>().fetchServices(active: true),
          ),
          const SizedBox(height: 16),
          _HomeInfoCard(
            title: 'home.appointments.title'.tr(),
            description: 'home.appointments.subtitle'.tr(),
            icon: Icons.calendar_today_outlined,
            color: theme.colorScheme.secondaryContainer,
            iconColor: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(height: 16),
          const _ServicesSection(),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home.quick_actions.title'.tr(),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickActionChip(
                      label: 'home.quick_actions.add_offer'.tr(),
                      icon: Icons.add_circle_outline,
                    ),
                    _QuickActionChip(
                      label: 'home.quick_actions.manage_calendar'.tr(),
                      icon: Icons.schedule_outlined,
                    ),
                    _QuickActionChip(
                      label: 'home.quick_actions.view_reports'.tr(),
                      icon: Icons.bar_chart_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  const _HomeInfoCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Directionality.of(context) == TextDirection.LTR
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: iconColor,
            ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? theme.colorScheme.surfaceContainerLow : Colors.white;

    return BlocBuilder<DoctorServicesCubit, DoctorServicesState>(
      builder: (context, state) {
        Widget child;

        if (state is DoctorServicesLoading) {
          child = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'home.services_manage.loading'.tr(),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        } else if (state is DoctorServicesFailure) {
          child = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'home.services_manage.error'.tr(),
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 12),
              Text(
                state.message,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: () => context
                      .read<DoctorServicesCubit>()
                      .fetchServices(active: true),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('home.services_manage.retry'.tr()),
                ),
              ),
            ],
          );
        } else if (state is DoctorServicesSuccess) {
          if (state.services.isEmpty) {
            child = Text(
              'home.services_manage.empty'.tr(),
              style: theme.textTheme.bodyMedium,
            );
          } else {
            child = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home.services_manage.list_title'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...state.services.take(5).map(
                      (service) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ServiceTile(service: service),
                      ),
                    ),
                if (state.services.length > 5)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      'home.services_manage.more'.tr(
                        namedArgs: {
                          'count': (state.services.length - 5).toString(),
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            );
          }
        } else {
          child = Text(
            'home.services_manage.prompt'.tr(),
            style: theme.textTheme.bodyMedium,
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});

  final DoctorService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeCode = context.locale.languageCode;

    final name = _resolveServiceName(service.service, localeCode);
    final description = _resolveServiceDescription(service, localeCode);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            image: service.service.image != null
                ? DecorationImage(
                    image: NetworkImage(service.service.image!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: service.service.image == null
              ? Icon(
                  Icons.medical_services_outlined,
                  color: theme.colorScheme.primary,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description ?? '—',
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (service.price != null)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              service.price!.toStringAsFixed(2),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  String _resolveServiceName(ServiceInfo info, String localeCode) {
    switch (localeCode) {
      case 'ar':
        return info.nameAr ??
            info.nameEn ??
            info.nameFr ??
            info.nameSp ??
            info.id;
      case 'fr':
        return info.nameFr ??
            info.nameEn ??
            info.nameAr ??
            info.nameSp ??
            info.id;
      case 'es':
      case 'sp':
        return info.nameSp ??
            info.nameEn ??
            info.nameFr ??
            info.nameAr ??
            info.id;
      default:
        return info.nameEn ??
            info.nameAr ??
            info.nameFr ??
            info.nameSp ??
            info.id;
    }
  }

  String? _resolveServiceDescription(DoctorService service, String localeCode) {
    switch (localeCode) {
      case 'ar':
        return service.descriptionAr ??
            service.descriptionEn ??
            service.descriptionFr ??
            service.descriptionSp;
      case 'fr':
        return service.descriptionFr ??
            service.descriptionEn ??
            service.descriptionAr ??
            service.descriptionSp;
      case 'es':
      case 'sp':
        return service.descriptionSp ??
            service.descriptionEn ??
            service.descriptionFr ??
            service.descriptionAr;
      default:
        return service.descriptionEn ??
            service.descriptionAr ??
            service.descriptionFr ??
            service.descriptionSp;
    }
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _QuickActionChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark
        ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
        : theme.colorScheme.surfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
