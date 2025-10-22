import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/hospitals/models/hospital_model.dart';

class HospitalDetailsPage extends StatelessWidget {
  const HospitalDetailsPage({super.key, required this.hospital});

  final HospitalModel hospital;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final locale = context.locale.languageCode;
    final description = hospital.descriptionForLocale(locale);
    final overviewLabel = _localizedLabel(
      locale: locale,
      arabic: 'Overview',
      french: 'Apercu',
      english: 'Overview',
      spanish: 'Descripcion general',
    );
    final addressLabel = _localizedLabel(
      locale: locale,
      arabic: 'Address',
      french: 'Adresse',
      english: 'Address',
      spanish: 'Direccion',
    );
    final coordinatesLabel = _localizedLabel(
      locale: locale,
      arabic: 'Coordinates',
      french: 'Coordonnees',
      english: 'Coordinates',
      spanish: 'Coordenadas',
    );
    final mediaLabel = _localizedLabel(
      locale: locale,
      arabic: 'Media',
      french: 'Medias',
      english: 'Media',
      spanish: 'Medios',
    );
    final emptyDescriptionMessage = _localizedLabel(
      locale: locale,
      arabic: 'No information is available at the moment.',
      french: 'Aucune information disponible pour le moment.',
      english: 'No information is available at the moment.',
      spanish: 'No hay informacion disponible por el momento.',
    );
    final facilityLabel = hospital.field.trim().isNotEmpty
        ? hospital.field
        : hospital.facilityType;
    final hasLocation = hospital.latitude != null && hospital.longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hospital.name.isNotEmpty
              ? hospital.name
              : 'home.hospitals_choice.title'.tr(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HospitalMediaGallery(
              images: hospital.images,
              baseUrl: baseUrl,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ChipBadge(
                            icon: Icons.local_hospital_rounded,
                            label: facilityLabel,
                          ),
                          if (hospital.rating > 0)
                            _ChipBadge(
                              icon: Icons.star_rounded,
                              label: hospital.rating.toStringAsFixed(1),
                              iconColor: Colors.amber,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              overviewLabel,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              description.isNotEmpty ? description : emptyDescriptionMessage,
              style: theme.textTheme.bodyLarge,
            ),
            if (hospital.address.trim().isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                addressLabel,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hospital.address,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            if (hasLocation) ...[
              const SizedBox(height: 24),
              Text(
                coordinatesLabel,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.public_rounded),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lat: ${hospital.latitude?.toStringAsFixed(4)}, '
                      'Lng: ${hospital.longitude?.toStringAsFixed(4)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            if (hospital.videos.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                mediaLabel,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...hospital.videos.map(
                (video) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_fill_rounded, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          video,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HospitalMediaGallery extends StatelessWidget {
  const _HospitalMediaGallery({
    required this.images,
    required this.baseUrl,
  });

  final List<String> images;
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    final resolved = images
        .map((path) => _resolveImagePath(path, baseUrl))
        .whereType<String>()
        .toList(growable: false);

    if (resolved.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: _HospitalImage(
          path: null,
          icon: Icons.medical_services_outlined,
        ),
      );
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _HospitalImage(path: resolved.first),
          ),
        ),
        if (resolved.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: resolved.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final imagePath = resolved[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(
                            index == 0 ? 0.8 : 0.3,
                          ),
                          width: index == 0 ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _HospitalImage(path: imagePath),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  static String? _resolveImagePath(String raw, String baseUrl) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http')) return value;
    if (value.startsWith('assets/')) return value;

    if (baseUrl.isEmpty) return value;
    try {
      return Uri.parse(baseUrl).resolve(value).toString();
    } catch (_) {
      return value;
    }
  }
}

class _HospitalImage extends StatelessWidget {
  const _HospitalImage({required this.path, this.icon = Icons.local_hospital});

  final String? path;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget placeholder({IconData? customIcon}) {
      return Container(
        color: theme.colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(
          customIcon ?? icon,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (path == null || path!.isEmpty) {
      return placeholder(customIcon: Icons.medical_services_rounded);
    }

    if (path!.startsWith('http')) {
      return Image.network(
        path!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return placeholder(customIcon: Icons.local_hospital_rounded);
        },
        errorBuilder: (context, error, stackTrace) =>
            placeholder(customIcon: Icons.broken_image_outlined),
      );
    }

    return Image.asset(
      path!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          placeholder(customIcon: Icons.broken_image_outlined),
    );
  }
}

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor ?? theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: iconColor ?? theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

String _localizedLabel({
  required String locale,
  required String arabic,
  required String french,
  required String english,
  String? spanish,
}) {
  switch (locale) {
    case 'ar':
      return arabic;
    case 'fr':
      return french;
    case 'sp':
    case 'es':
      return spanish ?? english;
    default:
      return english;
  }
}
