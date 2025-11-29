import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/viewmodel/clinics_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/viewmodel/clinics_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/hospital_card.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/spacing.dart';

class ClinicsListPage extends StatefulWidget {
  final String hospitalId;

  const ClinicsListPage({super.key, required this.hospitalId});

  @override
  State<ClinicsListPage> createState() => _ClinicsListPageState();
}

class _ClinicsListPageState extends State<ClinicsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ClinicsCubit>().getHospitalClinics(widget.hospitalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('hospitals.detail.manage_clinics'.tr()),
      ),
      body: _ClinicsListView(hospitalId: widget.hospitalId),
    );
  }
}

class _ClinicsListView extends StatelessWidget {
  final String hospitalId;
  const _ClinicsListView({required this.hospitalId});

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
              'hospitals.detail.clinics_title'.tr(),
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'hospitals.manage.clinics_description'.tr(),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<ClinicsCubit, ClinicsState>(
                builder: (context, state) {
                  if (state is ClinicsInitial || state is ClinicsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ClinicsFailure) {
                    final failure = state.failure;
                    return _ErrorView(
                      message: failure.message ?? 'unknown_error'.tr(),
                      onRetry: () => context
                          .read<ClinicsCubit>()
                          .getHospitalClinics(hospitalId),
                    );
                  }
                  if (state is ClinicsSuccess) {
                    final clinicList = state.clinicList;
                    if (clinicList.data.isEmpty) {
                      return _EmptyView(
                        messageKey: 'hospitals.manage.no_clinics_message',
                        onReload: () => context
                            .read<ClinicsCubit>()
                            .getHospitalClinics(hospitalId),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => context
                          .read<ClinicsCubit>()
                          .getHospitalClinics(hospitalId),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (ctx, index) {
                          final clinic = clinicList.data[index];
                          return HospitalCard(
                            title: clinic.name,
                            subtitle: _resolveDescription(
                                context.locale.languageCode, clinic),
                            facilityLabel:
                                'hospitals.facility_type.clinic'.tr(),
                            phoneLabel: clinic.phones.join(' · '),
                            imageUrl: clinic.images.isNotEmpty
                                ? clinic.images.first
                                : null,
                            onTap: () {
                              // TODO: Navigate to clinic detail page
                            },
                          );
                        },
                        separatorBuilder: (ctx, _) =>
                            const SizedBox(height: 20),
                        itemCount: clinicList.data.length,
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
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: AppButton(
                  text: 'hospitals.actions.add'.tr(),
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => _openCreate(context, hospitalId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _resolveDescription(String locale, ClinicModel clinic) {
    return clinic.description;
  }

  void _openCreate(BuildContext context, String hospitalId) {
    final router = GoRouter.of(context);
    router.push('/hospitals/$hospitalId/clinics/new');
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
            Icons.info_outline,
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
            Icons.error_outline,
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
