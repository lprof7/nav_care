import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/services/services_remote_service.dart';
import '../../../../../../data/services/services_repository.dart';
import '../viewmodel/featured_services_cubit.dart';
import '../viewmodel/featured_services_state.dart';
import '../../../../../../data/services/models/service_model.dart';
import '../../../view/featured_services_page.dart';

class FeaturedServicesSection extends StatelessWidget {
  const FeaturedServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeaturedServicesCubit(
        repository: ServicesRepository(
          remoteService: ServicesRemoteService(),
        ),
      )..loadFeaturedServices(),
      child: const _FeaturedServicesBody(),
    );
  }
}

class _FeaturedServicesBody extends StatelessWidget {
  const _FeaturedServicesBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeaturedServicesCubit, FeaturedServicesState>(
      builder: (context, state) {
        if (state.status == FeaturedServicesStatus.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == FeaturedServicesStatus.failure) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Text(
              state.message ?? 'home.featured_services.error'.tr(),
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
              _FeaturedHeader(
                onSeeMore: () => _openSeeMore(context, state.services),
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
                    return _ServiceCard(service: service);
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
        builder: (_) => FeaturedServicesPage(services: services),
      ),
    );
  }
}

class _FeaturedHeader extends StatelessWidget {
  final VoidCallback onSeeMore;

  const _FeaturedHeader({required this.onSeeMore});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          'home.featured_services.title'.tr(),
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onSeeMore,
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text('home.featured_services.see_more'.tr()),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final localeCode = context.locale.languageCode;
    final name = service.nameForLanguage(localeCode);

    return SizedBox(
      width: 160,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
