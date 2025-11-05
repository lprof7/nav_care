import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';

import 'manage_target.dart';

class HospitalManagePlaceholderPage extends StatelessWidget {
  final Hospital hospital;
  final ManageTarget target;

  const HospitalManagePlaceholderPage({
    super.key,
    required this.hospital,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(target.translationKey().tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'hospitals.manage.title'.tr(args: [hospital.displayName ?? hospital.name]),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              target.descriptionKey().tr(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.construction_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'hospitals.manage.placeholder'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
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
