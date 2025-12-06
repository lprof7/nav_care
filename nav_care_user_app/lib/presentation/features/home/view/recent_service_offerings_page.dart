import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';

class RecentServiceOfferingsPage extends StatelessWidget {
  final List<ServiceOfferingModel> offerings;

  const RecentServiceOfferingsPage({super.key, required this.offerings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('home.recent_service_offerings.title'.tr()),
      ),
      body: offerings.isEmpty
          ? Center(
              child: Text(
                'home.recent_service_offerings.empty'.tr(),
                style: theme.textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: offerings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final offering = offerings[index];
                return _RecentServiceOfferingTile(offering: offering);
              },
            ),
    );
  }
}

class _RecentServiceOfferingTile extends StatelessWidget {
  final ServiceOfferingModel offering;

  const _RecentServiceOfferingTile({required this.offering});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final locale = context.locale.languageCode;
    final serviceName = offering.service.nameForLocale(locale);
    final providerName = offering.provider.name.isNotEmpty
        ? offering.provider.name
        : 'home.recent_service_offerings.unknown_provider'.tr();
    final specialty = offering.provider.specialty;
    final cover = _resolveImage(offering.service.image, baseUrl);
    final avatar = _resolveImage(offering.provider.profilePicture, baseUrl);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _OfferingCoverImage(path: cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Text(
                      serviceName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    backgroundImage:
                        avatar != null ? NetworkImage(avatar) : null,
                    child: avatar == null
                        ? const Icon(Icons.person_rounded, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          providerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (specialty.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              specialty,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if ((offering.provider.rating ?? 0) > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  offering.provider.rating!.toStringAsFixed(1),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    return Image.asset(
      path!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_rounded, size: 36),
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
    return Uri.parse(baseUrl).resolve(path).toString();
  } catch (_) {
    return path;
  }
}
