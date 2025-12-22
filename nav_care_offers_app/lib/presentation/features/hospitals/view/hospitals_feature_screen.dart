import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_list_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/hospital_card.dart';

class HospitalsFeatureScreen extends StatelessWidget {
  const HospitalsFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<HospitalListCubit>()..fetchHospitals(page: 1, limit: 10),
      child: const _HospitalsListView(),
    );
  }
}

class _HospitalsListView extends StatelessWidget {
  const _HospitalsListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'hospitals.list.title'.tr(),
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'hospitals.list.subtitle'.tr(),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<HospitalListCubit, HospitalListState>(
                builder: (context, state) {
                  if (state is HospitalListLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is HospitalListFailure) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: () => context
                          .read<HospitalListCubit>()
                          .fetchHospitals(page: 1, limit: 10),
                    );
                  }
                  if (state is HospitalListEmpty) {
                    return _EmptyView(
                      messageKey: state.messageKey,
                      onReload: () => context
                          .read<HospitalListCubit>()
                          .fetchHospitals(page: 1, limit: 10),
                    );
                  }
                  if (state is HospitalListSuccess) {
                    final hospitals = List<Hospital>.from(state.hospitals);
                    if (hospitals.isEmpty) {
                      return _EmptyView(
                        messageKey: 'hospitals.list.empty',
                        onReload: () => context
                            .read<HospitalListCubit>()
                            .fetchHospitals(page: 1, limit: 10),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => context
                          .read<HospitalListCubit>()
                          .fetchHospitals(page: 1, limit: 10),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (ctx, index) {
                          final hospital = hospitals[index];
                          return HospitalCard(
                            title: _resolveName(hospital),
                            subtitle: _resolveDescription(
                              context.locale.languageCode,
                              hospital,
                            ),
                            facilityLabel: _facilityLabel(context, hospital),
                            phoneLabel: hospital.phones.join(' · '),
                            imageUrl: hospital.images.isNotEmpty
                                ? hospital.images.first
                                : null,
                            onTap: () => _openDetail(context, hospital),
                            footer: _buildFooter(context, hospital),
                          );
                        },
                        separatorBuilder: (ctx, _) =>
                            const SizedBox(height: 20),
                        itemCount: hospitals.length,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            const SizedBox(height: 24),
            SafeArea(
              top: false,
              child: AppButton(
                text: 'hospitals.actions.add'.tr(),
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _openCreate(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveName(Hospital hospital) {
    if (hospital.displayName != null && hospital.displayName!.isNotEmpty) {
      return hospital.displayName!;
    }
    return hospital.name;
  }

  String? _resolveDescription(String locale, Hospital hospital) {
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

  String _facilityLabel(BuildContext context, Hospital hospital) {
    final key = hospital.facilityType.translationKey('hospitals.facility_type');
    return key.tr();
  }

  List<Widget> _buildFooter(BuildContext context, Hospital hospital) {
    final chips = <Widget>[];
    return chips;
  }

  void _openCreate(BuildContext context) {
    final router = GoRouter.of(context);
    final cubit = context.read<HospitalListCubit>();
    router.push('/hospitals/new').then((value) {
      if (value is Hospital) {
        cubit.refreshFromCache();
      }
    });
  }

  void _openDetail(BuildContext context, Hospital hospital) {
    final router = GoRouter.of(context);
    final cubit = context.read<HospitalListCubit>();
    final route = hospital.facilityType == FacilityType.clinic
        ? '/clinics/${hospital.id}/app'
        : '/hospitals/${hospital.id}/app';
    router.push(route, extra: hospital).then((value) {
      if (value == true) {
        cubit.fetchHospitals(page: 1, limit: 10); // Refresh all hospitals
      } else if (value == 'deleted') {
        cubit.removeHospital(hospital.id);
      }
    });
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.surfaceContainerHighest;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String messageKey;
  final VoidCallback onReload;

  const _EmptyView({
    required this.messageKey,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_hospital_outlined,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              messageKey.tr(),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('hospitals.actions.reload'.tr()),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayMessage =
        message.startsWith('hospitals.') ? message.tr() : message;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              displayMessage,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('hospitals.actions.retry'.tr()),
          ),
        ],
      ),
    );
  }
}
