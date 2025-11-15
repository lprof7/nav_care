import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';

import '../../../view/recent_service_offerings_page.dart';
import '../viewmodel/recent_service_offerings_cubit.dart';
import '../viewmodel/recent_service_offerings_state.dart';

class RecentServiceOfferingsSection extends StatelessWidget {
  const RecentServiceOfferingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RecentServiceOfferingsCubit>()..loadOfferings(),
      child: const _RecentServiceOfferingsBody(),
    );
  }
}

class _RecentServiceOfferingsBody extends StatelessWidget {
  const _RecentServiceOfferingsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentServiceOfferingsCubit,
        RecentServiceOfferingsState>(
      builder: (context, state) {
        switch (state.status) {
          case RecentServiceOfferingsStatus.loading:
            return const _RecentServiceOfferingsLoading();
          case RecentServiceOfferingsStatus.failure:
            return _RecentServiceOfferingsError(
              message:
                  state.message ?? 'home.recent_service_offerings.error'.tr(),
            );
          case RecentServiceOfferingsStatus.loaded:
            if (state.offerings.isEmpty) {
              return _RecentServiceOfferingsEmpty(
                message: 'home.recent_service_offerings.empty'.tr(),
              );
            }
            return _RecentServiceOfferingsContent(offerings: state.offerings);
          case RecentServiceOfferingsStatus.initial:
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class _RecentServiceOfferingsContent extends StatelessWidget {
  final List<ServiceOfferingModel> offerings;

  const _RecentServiceOfferingsContent({required this.offerings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'home.recent_service_offerings.title'.tr(),
            actionLabel: 'home.recent_service_offerings.see_more'.tr(),
            onTap: () => _openSeeMore(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: offerings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final offering = offerings[index];
                return _RecentServiceOfferingCard(offering: offering);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openSeeMore(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecentServiceOfferingsPage(offerings: offerings),
      ),
    );
  }
}

class _RecentServiceOfferingCard extends StatelessWidget {
  final ServiceOfferingModel offering;

  const _RecentServiceOfferingCard({required this.offering});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final locale = context.locale.languageCode;
    final serviceName = offering.service.nameForLocale(locale);
    final providerName = offering.provider.user.name.isNotEmpty
        ? offering.provider.user.name
        : 'home.recent_service_offerings.unknown_provider'.tr();
    final specialty = offering.provider.specialty;
    final cover = _resolveImage(offering.service.image, baseUrl);
    final avatar =
        _resolveImage(offering.provider.user.profilePicture, baseUrl);

    return SizedBox(
      width: 260,
      height: 280,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _OfferingCoverImage(path: cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.75),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            providerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      backgroundImage:
                          avatar != null ? NetworkImage(avatar) : null,
                      child: avatar == null
                          ? const Icon(Icons.person_rounded, size: 24)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (specialty.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                specialty,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if ((offering.provider.rating ?? 0) > 0)
                      _Badge(
                        label: offering.provider.rating!.toStringAsFixed(1),
                        icon: Icons.star_rounded,
                        background: theme.colorScheme.secondaryContainer,
                        foreground: theme.colorScheme.onSecondaryContainer,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferingCoverImage extends StatelessWidget {
  final String? path;

  const _OfferingCoverImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: const Icon(Icons.medical_services_rounded, size: 42),
      );
    }

    if (path!.startsWith('http')) {
      return Image.network(
        path!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Theme.of(context).colorScheme.surfaceVariant,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_rounded, size: 36),
        ),
      );
    }

    return Image.asset(
      path!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_rounded, size: 36),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _RecentServiceOfferingsLoading extends StatelessWidget {
  const _RecentServiceOfferingsLoading();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 180,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, __) {
                return Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(24),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentServiceOfferingsError extends StatelessWidget {
  final String message;

  const _RecentServiceOfferingsError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _RecentServiceOfferingsEmpty extends StatelessWidget {
  final String message;

  const _RecentServiceOfferingsEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? background;
  final Color? foreground;

  const _Badge({
    required this.label,
    this.icon,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = background ?? theme.colorScheme.surfaceContainerHighest;
    final fg = foreground ?? theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String? _resolveImage(String? path, String baseUrl) {
  if (path == null || path.isEmpty) {
    return null;
  }
  if (path.startsWith('http')) {
    return path;
  }
  try {
    final uri = Uri.parse(baseUrl);
    return uri.resolve(path).toString();
  } catch (_) {
    return path;
  }
}
