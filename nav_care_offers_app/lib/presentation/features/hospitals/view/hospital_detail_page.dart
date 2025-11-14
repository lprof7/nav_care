import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_detail_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';


class HospitalDetailPage extends StatelessWidget {
  final String hospitalId;
  final Hospital? initial;

  const HospitalDetailPage({
    super.key,
    required this.hospitalId,
    this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final repository = sl<HospitalsRepository>();
    final hospital = initial ?? repository.findById(hospitalId);

    if (hospital == null) {
      return _MissingHospitalView(hospitalId: hospitalId);
    }

    return BlocProvider(
      create: (_) => sl<HospitalDetailCubit>(param1: hospital)
        ..refreshFromRepository()
        ..getHospitalToken(),
      child: const _HospitalDetailView(),
    );
  }
}

class _HospitalDetailView extends StatelessWidget {
  const _HospitalDetailView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<HospitalDetailCubit, HospitalDetailState>(
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          messenger.showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        } else if (state.successMessageKey != null) {
          messenger.showSnackBar(
            SnackBar(content: Text(state.successMessageKey!.tr())),
          );
        }
        if (state.isDeleted) {
          context.pop('deleted');
        }
      },
      builder: (context, state) {
        final hospital = state.hospital;

        return Scaffold(
          appBar: AppBar(
            title: Text('hospitals.detail.app_bar'.tr(
              args: [hospital.displayName ?? hospital.name],
            )),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ImagesSection(images: hospital.images),
                const SizedBox(height: 20),
                Text(
                  hospital.displayName ?? hospital.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_resolveDescription(
                      context.locale.languageCode,
                      hospital,
                    ) !=
                    null)
                  Text(
                    _resolveDescription(
                          context.locale.languageCode,
                          hospital,
                        ) ??
                        '',
                    style: theme.textTheme.bodyLarge,
                  ),
                const SizedBox(height: 20),
                _InfoTile(
                  icon: Icons.local_hospital_outlined,
                  label: 'hospitals.detail.facility_type'.tr(),
                  value: hospital.facilityType
                      .translationKey('hospitals.facility_type')
                      .tr(),
                ),
                if (hospital.phones.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.phone_outlined,
                    label: 'hospitals.detail.phone'.tr(),
                    value: hospital.phones.join(' · '),
                  ),
                ],
                if (hospital.coordinates != null) ...[
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.location_on_outlined,
                    label: 'hospitals.detail.coordinates'.tr(),
                    value: '(${hospital.coordinates!.latitude.toStringAsFixed(4)}, '
                        '${hospital.coordinates!.longitude.toStringAsFixed(4)})',
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            _openManage(context, hospital, 'clinics'),
                        icon: const Icon(Icons.maps_home_work_outlined),
                        label: Text('hospitals.detail.manage_clinics'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _openManage(context, hospital, 'doctors'),
                        icon: const Icon(Icons.groups_2_outlined),
                        label: Text('hospitals.detail.manage_doctors'.tr()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (hospital.clinics.isNotEmpty) ...[
                  _SectionTitle(title: 'hospitals.detail.clinics_title'.tr()),
                  const SizedBox(height: 12),
                  ...hospital.clinics.map(
                    (clinic) => _MiniCard(
                      title: clinic.name,
                      subtitle: clinic.description,
                      leading: Icons.local_hospital,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (hospital.doctors.isNotEmpty) ...[
                  _SectionTitle(title: 'hospitals.detail.doctors_title'.tr()),
                  const SizedBox(height: 12),
                  ...hospital.doctors.map(
                    (doctor) => _MiniCard(
                      title: doctor.user.name,
                      subtitle: doctor.specialty,
                      leading: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isDeleting
                          ? null
                          : () => _openEdit(context, hospital),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text('hospitals.detail.edit'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: state.isDeleting
                          ? 'hospitals.detail.deleting'.tr()
                          : 'hospitals.detail.delete'.tr(),
                      color: theme.colorScheme.error,
                      textColor: theme.colorScheme.onError,
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.onError,
                      ),
                      onPressed: state.isDeleting
                          ? null
                          : () => _confirmDelete(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String? _resolveDescription(String locale, Hospital hospital) {
    switch (locale) {
      case 'ar':
        return hospital.descriptionAr ?? hospital.descriptionEn;
      case 'fr':
        return hospital.descriptionFr ??
            hospital.descriptionEn ??
            hospital.descriptionAr;
      default:
        return hospital.descriptionEn ??
            hospital.descriptionFr ??
            hospital.descriptionAr;
    }
  }

  void _openEdit(BuildContext context, Hospital hospital) {
    final router = GoRouter.of(context);
    final cubit = context.read<HospitalDetailCubit>();
    router.push('/hospitals/${hospital.id}/edit', extra: hospital).then((value) {
      if (value is Hospital) {
        cubit.updateHospital(value);
      }
    });
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('hospitals.detail.delete_confirm_title'.tr()),
        content: Text('hospitals.detail.delete_confirm_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('hospitals.detail.delete_cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('hospitals.detail.delete_confirm'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final cubit = context.read<HospitalDetailCubit>();
      await cubit.deleteHospital();
    }
  }

  void _openManage(
    BuildContext context,
    Hospital hospital,
    String target,
  ) {
    context.push(
      target == 'clinics'
          ? '/hospitals/${hospital.id}/clinics'
          : '/hospitals/${hospital.id}/doctors',
      extra: {
        'hospital': hospital,
        'target': target,
      },
    );
  }
}

class _ImagesSection extends StatelessWidget {
  final List<String> images;

  const _ImagesSection({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.photo_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: images.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final image = images[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                image,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData leading;

  const _MiniCard({
    required this.title,
    this.subtitle,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(leading, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingHospitalView extends StatelessWidget {
  final String hospitalId;

  const _MissingHospitalView({required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('hospitals.detail.app_bar'.tr(args: ['# $hospitalId'])),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'hospitals.detail.not_found'.tr(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
