import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';
import 'package:nav_care_user_app/data/services/models/service_model.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/view/service_offering_detail_page.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/viewmodel/service_offerings_by_service_cubit.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/viewmodel/service_offerings_by_service_state.dart';

class ServiceOfferingsByServicePage extends StatelessWidget {
  final ServiceModel service;
  const ServiceOfferingsByServicePage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ServiceOfferingsByServiceCubit>()..loadOfferings(service.id),
      child: _ServiceOfferingsByServiceView(service: service),
    );
  }
}

class _ServiceOfferingsByServiceView extends StatelessWidget {
  final ServiceModel service;
  const _ServiceOfferingsByServiceView({required this.service});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final serviceName = service.nameForLanguage(locale);
    final theme = Theme.of(context);
    final description = service.descriptionForLocale(locale,
        fallback: 'services.details.no_description'.tr());

    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
      ),
      body: RefreshIndicator(
        onRefresh: () => context
            .read<ServiceOfferingsByServiceCubit>()
            .loadOfferings(service.id),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ServiceHeader(service: service),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            BlocBuilder<ServiceOfferingsByServiceCubit,
                ServiceOfferingsByServiceState>(
              builder: (context, state) {
                switch (state.status) {
                  case ServiceOfferingsByServiceStatus.loading:
                    return const _Loading();
                  case ServiceOfferingsByServiceStatus.failure:
                    return _Error(
                      message: state.message ?? 'services.offerings.error'.tr(),
                      onRetry: () => context
                          .read<ServiceOfferingsByServiceCubit>()
                          .loadOfferings(service.id),
                    );
                  case ServiceOfferingsByServiceStatus.success:
                    if (state.offerings.isEmpty) {
                      return _Empty(message: 'services.offerings.empty'.tr());
                    }
                    return _OfferingsList(offerings: state.offerings);
                  case ServiceOfferingsByServiceStatus.initial:
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceHeader extends StatelessWidget {
  final ServiceModel service;
  const _ServiceHeader({required this.service});

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final imagePath = service.imageUrl(baseUrl);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imagePath,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _ImagePlaceholder(theme: theme),
            ),
          )
        else
          _ImagePlaceholder(theme: theme),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final ThemeData theme;
  const _ImagePlaceholder({required this.theme});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_rounded),
    );
  }
}

class _OfferingsList extends StatelessWidget {
  final List<ServiceOfferingModel> offerings;
  const _OfferingsList({required this.offerings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final locale = context.locale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'services.offerings.title'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...offerings.map(
          (offering) {
            final serviceName = offering.service.nameForLocale(locale);
            final providerName = offering.provider.user.name;
            final cover = _resolveImage(offering.service.image, baseUrl);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: cover == null
                        ? Container(
                            color: theme.colorScheme.surfaceVariant,
                            alignment: Alignment.center,
                            child: const Icon(Icons.medical_services_rounded),
                          )
                        : Image.network(
                            cover,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: theme.colorScheme.surfaceVariant,
                              alignment: Alignment.center,
                              child:
                                  const Icon(Icons.image_not_supported_rounded),
                            ),
                          ),
                  ),
                ),
                title: Text(
                  serviceName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (offering.price != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'services.offerings.price'.tr(
                            namedArgs: {
                              'price': offering.price!.toStringAsFixed(2),
                            },
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  final item =
                      _toSearchResult(offering, baseUrl, locale: locale);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ServiceOfferingDetailPage(
                        item: item,
                        baseUrl: baseUrl,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 90,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _Error({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: onRetry,
          child: Text('services.offerings.retry'.tr()),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

String? _resolveImage(String? path, String baseUrl) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  try {
    return Uri.parse(baseUrl).resolve(path).toString();
  } catch (_) {
    return path;
  }
}

SearchResultItem _toSearchResult(
  ServiceOfferingModel offering,
  String baseUrl, {
  required String locale,
}) {
  final service = offering.service;
  final provider = offering.provider;
  final providerUser = provider.user;

  final serviceName = service.nameForLocale(locale);
  final image = _resolveImage(service.image, baseUrl);
  final avatar = _resolveImage(providerUser.profilePicture, baseUrl);

  return SearchResultItem(
    id: offering.id,
    type: SearchResultType.serviceOffering,
    title: serviceName,
    subtitle: providerUser.name,
    description: provider.specialty,
    rating: provider.rating,
    price: offering.price,
    imagePath: image,
    secondaryImagePath: avatar,
    location: const SearchLocation(),
    extra: {
      'service': {
        '_id': service.id,
        'name_en': service.nameEn,
        'name_fr': service.nameFr,
        'name_ar': service.nameAr,
        'name_sp': service.nameSp,
        'image': service.image,
      },
      'provider': {
        '_id': provider.id,
        'user': {
          '_id': providerUser.id,
          'name': providerUser.name,
          'email': providerUser.email,
          'profilePicture': providerUser.profilePicture,
        },
        'specialty': provider.specialty,
        'rating': provider.rating,
      },
    },
  );
}
