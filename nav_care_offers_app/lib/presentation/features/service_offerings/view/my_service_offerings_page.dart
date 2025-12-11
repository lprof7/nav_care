import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/service_offerings/service_offerings_repository.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offerings_cubit.dart';

class MyServiceOfferingsPage extends StatefulWidget {
  const MyServiceOfferingsPage({super.key});

  @override
  State<MyServiceOfferingsPage> createState() => _MyServiceOfferingsPageState();
}

class _MyServiceOfferingsPageState extends State<MyServiceOfferingsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceOfferingsCubit(
        sl<ServiceOfferingsRepository>(),
        useHospitalToken: false,
      )..loadOfferings(),
      child: const _MyServiceOfferingsView(),
    );
  }
}

class _MyServiceOfferingsView extends StatelessWidget {
  const _MyServiceOfferingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('service_offerings.list.title'.tr()),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: BlocBuilder<ServiceOfferingsCubit, ServiceOfferingsState>(
            builder: (context, state) {
              if (state.isLoading && state.offerings.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.hasError && state.offerings.isEmpty) {
                return _MyOfferingsError(
                  message: state.failure?.message ?? 'unknown_error'.tr(),
                  onRetry: () => context
                      .read<ServiceOfferingsCubit>()
                      .loadOfferings(refresh: true),
                );
              }

              if (state.isEmpty) {
                return _MyOfferingsEmpty(
                  onReload: () => context
                      .read<ServiceOfferingsCubit>()
                      .loadOfferings(refresh: true),
                );
              }

              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () => context
                        .read<ServiceOfferingsCubit>()
                        .loadOfferings(refresh: true),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.offerings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final offering = state.offerings[index];
                        return _MyOfferingCard(offering: offering);
                      },
                    ),
                  ),
                  if (state.isLoading)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MyOfferingCard extends StatelessWidget {
  const _MyOfferingCard({required this.offering});

  final ServiceOffering offering;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;
    final serviceName = offering.localizedName(locale);
    final subtitle = 'service_offerings.list.price'.tr(
      namedArgs: {'price': offering.price.toStringAsFixed(2)},
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  offering.providerType,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            offering.descriptionEn ??
                offering.descriptionAr ??
                offering.descriptionFr ??
                offering.descriptionSp ??
                'service_offerings.detail.no_description'.tr(),
            style: theme.textTheme.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (offering.offers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: offering.offers
                  .map(
                    (label) => Chip(
                      label: Text(label),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MyOfferingsEmpty extends StatelessWidget {
  const _MyOfferingsEmpty({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medical_services_outlined,
              size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'service_offerings.list.empty'.tr(),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('service_offerings.list.reload'.tr()),
          ),
        ],
      ),
    );
  }
}

class _MyOfferingsError extends StatelessWidget {
  const _MyOfferingsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message.startsWith('service_offerings.')
                  ? message.tr()
                  : message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('service_offerings.list.retry'.tr()),
          ),
        ],
      ),
    );
  }
}
