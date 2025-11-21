import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/view/service_offerings_by_service_page.dart';

import '../../../../data/services/models/service_model.dart';

class FeaturedServicesPage extends StatelessWidget {
  final List<ServiceModel> services;

  const FeaturedServicesPage({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('home.featured_services.title'.tr()),
      ),
      body: services.isEmpty
          ? Center(
              child: Text(
                'home.featured_services.empty'.tr(),
                style: textTheme.bodyLarge,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final name =
                    service.nameForLanguage(context.locale.languageCode);
                final imagePath = service.imageUrl(baseUrl);

                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _openService(context, service),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: imagePath == null
                              ? Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                      Icons.image_not_supported_rounded),
                                )
                              : Image.network(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                          Icons.image_not_supported_rounded),
                                    );
                                  },
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
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

  void _openService(BuildContext context, ServiceModel service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceOfferingsByServicePage(service: service),
      ),
    );
  }
}
