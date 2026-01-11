import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/core/utils/responsive_grid.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';
import 'package:nav_care_user_app/data/service_offerings/service_offerings_repository.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/view/service_offering_detail_page.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/service_offering_card.dart';

class DoctorServiceOfferingsSection extends StatefulWidget {
  final String providerId;

  const DoctorServiceOfferingsSection({super.key, required this.providerId});

  @override
  State<DoctorServiceOfferingsSection> createState() =>
      _DoctorServiceOfferingsSectionState();
}

class _DoctorServiceOfferingsSectionState
    extends State<DoctorServiceOfferingsSection> {
  late Future<List<ServiceOfferingModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ServiceOfferingModel>> _load() {
    return sl<ServiceOfferingsRepository>()
        .getProviderServiceOfferings(providerId: widget.providerId, limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final locale = context.locale.languageCode;
    return FutureBuilder<List<ServiceOfferingModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'services.offerings.error'.tr(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => setState(() => _future = _load()),
                  child: Text('services.offerings.retry'.tr()),
                ),
              ],
            ),
          );
        }
        final offerings = snapshot.data!;
        if (offerings.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'services.offerings.empty'.tr(),
              textAlign: TextAlign.center,
            ),
          );
        }
        const double rang = 40;
        final crossAxisCount = responsiveGridColumns(
          MediaQuery.sizeOf(context).width,
          crossAxisSpacing: 12,
          rang: rang,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'services.offerings.title'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.6,
                ),
                itemCount: offerings.length,
                itemBuilder: (context, index) {
                  final offering = offerings[index];
                  final serviceName = offering.nameForLocale(locale);
                  final providerName = offering.provider.name;
                  final specialty = offering.provider.specialty;
                  final cover = offering.images.isNotEmpty
                      ? _resolveImage(offering.images.first, baseUrl)
                      : _resolveImage(offering.service.image, baseUrl);
                  final priceLabel = offering.price != null
                      ? 'services.offerings.price'.tr(namedArgs: {
                          'price': offering.price!.toStringAsFixed(2)
                        })
                      : null;
                  final badge = specialty.trim().isNotEmpty ? specialty : null;
                  final item =
                      _toSearchResult(offering, baseUrl, locale: locale);

                  return ServiceOfferingCard(
                    title: serviceName,
                    subtitle: providerName,
                    badgeLabel: badge,
                    priceLabel: priceLabel,
                    imageUrl: cover,
                    buttonLabel: 'hospitals.detail.cta.view_service'.tr(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ServiceOfferingDetailPage(
                            item: item,
                            baseUrl: baseUrl,
                            offeringId: offering.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
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
  final serviceName = offering.nameForLocale(locale);
  final image = offering.images.isNotEmpty
      ? _resolveImage(offering.images.first, baseUrl)
      : _resolveImage(offering.service.image, baseUrl);
  final avatar = _resolveImage(offering.provider.profilePicture, baseUrl);
  return SearchResultItem(
    id: offering.id,
    type: SearchResultType.serviceOffering,
    title: serviceName,
    subtitle: offering.provider.name,
    description: offering.provider.specialty,
    rating: offering.rating,
    price: offering.price,
    imagePath: image,
    secondaryImagePath: avatar,
    location: const SearchLocation(),
    extra: {
      'service': {
        '_id': offering.service.id,
        'name_en': offering.service.nameEn,
        'name_fr': offering.service.nameFr,
        'name_ar': offering.service.nameAr,
        'name_sp': offering.service.nameSp,
        'image': offering.service.image,
      },
      'offering': {
        '_id': offering.id,
        'name_en': offering.nameEn,
        'name_fr': offering.nameFr,
        'name_ar': offering.nameAr,
        'name_sp': offering.nameSp,
      },
      'provider': {
        '_id': offering.provider.id,
        'user': {
          '_id': offering.provider.id,
          'name': offering.provider.name,
          'profilePicture': offering.provider.profilePicture,
        },
        'specialty': offering.provider.specialty,
        'rating': offering.provider.rating,
      },
    },
  );
}
