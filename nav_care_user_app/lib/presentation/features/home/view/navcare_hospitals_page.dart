import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/hospitals/models/hospital_model.dart';

class NavcareHospitalsPage extends StatelessWidget {
  final List<HospitalModel> hospitals;
  final String titleKey;
  final String emptyKey;

  const NavcareHospitalsPage({
    super.key,
    required this.hospitals,
    this.titleKey = 'home.hospitals_choice.title',
    this.emptyKey = 'home.hospitals_choice.empty',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleKey.tr()),
      ),
      body: hospitals.isEmpty
          ? Center(
              child: Text(
                emptyKey.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: hospitals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final hospital = hospitals[index];
                final description =
                    hospital.descriptionForLocale(context.locale.languageCode);
                final baseUrl = sl<AppConfig>().api.baseUrl;
                final image = hospital.primaryImage(baseUrl: baseUrl);
                final facilityLabel = hospital.field.trim().isNotEmpty
                    ? hospital.field
                    : hospital.facilityType;

                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _HospitalCoverImage(path: image),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.local_hospital_rounded,
                                          size: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          facilityLabel,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (hospital.rating > 0)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 18,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          hospital.rating.toStringAsFixed(1),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                hospital.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (hospital.address.trim().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 16,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        hospital.address,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _HospitalCoverImage extends StatelessWidget {
  final String? path;

  const _HospitalCoverImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget placeholder(
        {IconData icon = Icons.medical_services_rounded, double size = 48}) {
      return Container(
        color: theme.colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(icon, size: size),
      );
    }

    final imagePath = path;
    if (imagePath == null || imagePath.isEmpty) {
      return placeholder();
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder(icon: Icons.local_hospital_rounded, size: 40);
        },
        errorBuilder: (context, error, stackTrace) =>
            placeholder(icon: Icons.image_not_supported_rounded, size: 36),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          placeholder(icon: Icons.image_not_supported_rounded, size: 36),
    );
  }
}
