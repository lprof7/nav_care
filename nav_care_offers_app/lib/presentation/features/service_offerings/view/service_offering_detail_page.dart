import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/service_offerings/service_offerings_repository.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offering_detail_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offerings_cubit.dart';

class ServiceOfferingDetailPage extends StatelessWidget {
  const ServiceOfferingDetailPage({
    super.key,
    required this.hospitalId,
    required this.offeringId,
    this.initial,
  });

  final String hospitalId;
  final String offeringId;
  final ServiceOffering? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceOfferingDetailCubit(
        sl<ServiceOfferingsRepository>(),
        offeringId: offeringId,
        initial: initial,
      )..refresh(),
      child: _ServiceOfferingDetailView(hospitalId: hospitalId),
    );
  }
}

class _ServiceOfferingDetailView extends StatelessWidget {
  const _ServiceOfferingDetailView({required this.hospitalId});

  final String hospitalId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiceOfferingDetailCubit, ServiceOfferingDetailState>(
      listener: (context, state) {
        if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.failure!.message ?? 'unknown_error'.tr())),
          );
        }
        if (state.offering != null) {
          BlocProvider.of<ServiceOfferingsCubit>(context)
              ?.updateOffering(state.offering!);
        }
      },
      builder: (context, state) {
        final offering = state.offering;
        if (offering == null && state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (offering == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('service_offerings.detail.title'.tr()),
            ),
            body: Center(
              child: Text(
                state.failure?.message ??
                    'service_offerings.detail.not_found'.tr(),
              ),
            ),
          );
        }

        final theme = Theme.of(context);
        final locale = context.locale.languageCode;
        final serviceName = offering.service.localizedName(locale);

        return Scaffold(
          appBar: AppBar(
            title: Text(serviceName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _openEdit(context, hospitalId, offering),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'service_offerings.detail.price'.tr(args: [
                    offering.price.toStringAsFixed(2),
                  ]),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _DetailTile(
                  icon: Icons.person_outline,
                  label: 'service_offerings.detail.provider'.tr(),
                  value: offering.provider.user.name,
                ),
                if (offering.provider.specialty != null) ...[
                  const SizedBox(height: 12),
                  _DetailTile(
                    icon: Icons.badge_outlined,
                    label: 'service_offerings.detail.specialty'.tr(),
                    value: offering.provider.specialty!,
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'service_offerings.detail.offers'.tr(),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (offering.offers.isEmpty)
                  Text(
                    'service_offerings.detail.no_offers'.tr(),
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: offering.offers
                        .map(
                          (offer) => Chip(
                            label: Text(offer),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 24),
                Text(
                  'service_offerings.detail.description'.tr(),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  offering.descriptionEn ??
                      offering.descriptionAr ??
                      offering.descriptionFr ??
                      offering.descriptionSp ??
                      'service_offerings.detail.no_description'.tr(),
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEdit(context, hospitalId, offering),
            label: Text('service_offerings.detail.edit'.tr()),
            icon: const Icon(Icons.edit_outlined),
          ),
        );
      },
    );
  }

  void _openEdit(
    BuildContext context,
    String hospitalId,
    ServiceOffering offering,
  ) {
    final route =
        '/hospitals/$hospitalId/service-offerings/${offering.id}/edit';
    context.push(route, extra: offering).then((value) {
      if (value is ServiceOffering) {
        context.read<ServiceOfferingDetailCubit>().replace(value);
        BlocProvider.of<ServiceOfferingsCubit>(context)?.updateOffering(value);
        context.pop(value);
      }
    });
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
