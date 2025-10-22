import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/services/models/service_model.dart';
import '../../../../../../data/services/services_remote_service.dart';
import '../../../../../../data/services/services_repository.dart';
import '../../../view/recent_services_page.dart';
import '../viewmodel/recent_services_cubit.dart';
import '../viewmodel/recent_services_state.dart';

class RecentServicesSection extends StatelessWidget {
  const RecentServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecentServicesCubit(
        repository: ServicesRepository(
          remoteService: ServicesRemoteService(),
        ),
      )..loadRecentServices(),
      child: const _RecentServicesBody(),
    );
  }
}

class _RecentServicesBody extends StatelessWidget {
  const _RecentServicesBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentServicesCubit, RecentServicesState>(
      builder: (context, state) {
        if (state.status == RecentServicesStatus.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == RecentServicesStatus.failure) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Text(
              state.message ?? 'home.recent_services.error'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        if (state.services.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(
                title: 'home.recent_services.title'.tr(),
                actionLabel: 'home.recent_services.see_more'.tr(),
                onTap: () => _openSeeMore(context, state.services),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.services.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final service = state.services[index];
                    return _RecentServiceCard(service: service);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSeeMore(BuildContext context, List<ServiceModel> services) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecentServicesPage(services: services),
      ),
    );
  }
}

class _RecentServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _RecentServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final localeCode = context.locale.languageCode;
    final name = service.nameForLanguage(localeCode);
    final description = service.descriptionForLocale(localeCode);

    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {},
                child: Image.asset(
                  service.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_rounded),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}
