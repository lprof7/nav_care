import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/appointments/models/appointment_model.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/core/routing/app_router.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/presentation/features/appointments/viewmodel/appointments_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/appointments/viewmodel/appointments_state.dart';
import 'package:intl/intl.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_detail_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/invite_doctor_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/widgets/invite_doctor_sheet.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/widgets/invitations_tab.dart';
import 'package:nav_care_offers_app/data/reviews/hospital_reviews/models/hospital_review_model.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/doctor_grid_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/hospital_detail_cards.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/hospital_review_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/add_service_offering_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/service_offering_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/hospital_detail_components.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/appointment_card.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_reviews_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_reviews_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/network_image.dart';

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
      create: (_) => sl<HospitalDetailCubit>(param1: hospital)..loadDetails(),
      child: BlocProvider(
        create: (_) =>
            sl<HospitalReviewsCubit>()..loadReviews(hospitalId: hospitalId),
        child: _HospitalDetailView(hospitalId: hospitalId),
      ),
    );
  }
}

class _HospitalDetailView extends StatefulWidget {
  final String hospitalId;
  const _HospitalDetailView({required this.hospitalId});

  @override
  State<_HospitalDetailView> createState() => _HospitalDetailViewState();
}

class _HospitalDetailViewState extends State<_HospitalDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isSaved = false;
  late final AppointmentsCubit _appointmentsCubit;
  bool _appointmentsLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _appointmentsCubit = sl<AppointmentsCubit>();
  }

  @override
  void dispose() {
    _appointmentsCubit.close();
    _tabController.dispose();
    super.dispose();
  }

  void _reload() {
    _appointmentsLoaded = false;
    context.read<HospitalDetailCubit>().loadDetails(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
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
          context.go(AppRoute.home.path);
          return;
        }
        if (!_appointmentsLoaded &&
            !state.isFetchingToken &&
            (state.hospitalToken?.isNotEmpty ?? false)) {
          _appointmentsLoaded = true;
          _appointmentsCubit.getMyHospitalAppointments();
        }
      },
      builder: (context, state) {
        final hospital = state.hospital;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final baseUrl = sl<AppConfig>().api.baseUrl;
        final reviewsState = context.watch<HospitalReviewsCubit>().state;

        final clinicsCount = state.clinics.isNotEmpty
            ? state.clinics.length
            : hospital.clinics.length;
        final doctorsCount = state.doctors.isNotEmpty
            ? state.doctors.length
            : hospital.doctors.length;
        final offeringsCount = state.offerings.length;
        final facility = hospital.facilityType
            .translationKey('hospitals.facility_type')
            .tr();
        final cover = hospital.images.isNotEmpty
            ? _resolveImage(hospital.images.first, baseUrl)
            : null;
        final indicatorColor = theme.colorScheme.primary;
        final unselectedColor = isDark
            ? theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
            : Colors.grey.shade600;
        final tabBar = TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicatorPadding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          indicator: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.circular(12),
          ),
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: unselectedColor,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          tabs: [
            Tab(text: 'hospitals.detail.tabs.details'.tr()),
            Tab(text: 'hospitals.detail.tabs.clinics'.tr()),
            Tab(text: 'hospitals.detail.tabs.doctors'.tr()),
            Tab(text: 'shell.nav_appointments'.tr()),
            Tab(text: 'hospitals.detail.tabs.invitations'.tr()),
            Tab(text: 'hospitals.detail.tabs.offerings'.tr()),
          ],
        );

        return BlocProvider.value(
            value: _appointmentsCubit,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final didPop = await navigator.maybePop();
                    if (!didPop && context.mounted) {
                      context.go(AppRoute.home.path);
                    }
                  },
                ),
                title: Text(hospital.displayName ?? hospital.name),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return _buildFloatingActionButton(context, state, baseUrl);
                  },
                ),
              ),
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 240,
                          width: double.infinity,
                          child: _HeroBackdropLayer(imageUrl: cover),
                        ),
                        SizedBox(
                          height: 300,
                          child: Transform.translate(
                            offset: const Offset(0, -72),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _HeroForegroundLayer(
                                hospital: hospital,
                                facility: facility,
                                imageUrl: cover,
                                clinicsCount: clinicsCount,
                                doctorsCount: doctorsCount,
                                offeringsCount: offeringsCount,
                                primaryActionLabel:
                                    'hospitals.detail.edit'.tr(),
                                secondaryActionLabel: state.isDeleting
                                    ? 'hospitals.detail.deleting'.tr()
                                    : 'hospitals.detail.delete'.tr(),
                                onPrimaryTap: () =>
                                    _openEdit(context, hospital),
                                onSecondaryTap: state.isDeleting
                                    ? null
                                    : () => _confirmDelete(context),
                                isSaved: _isSaved,
                                onToggleSave: () =>
                                    setState(() => _isSaved = !_isSaved),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      _DecoratedTabBar(tabBar: tabBar),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _DetailsTab(
                      hospital: hospital,
                      clinicsCount: clinicsCount,
                      doctorsCount: doctorsCount,
                      offeringsCount: offeringsCount,
                      baseUrl: baseUrl,
                      reviewsState: reviewsState,
                      isReviewsLoadingMore: reviewsState.isLoadingMore,
                      onReviewsReload: () =>
                          context.read<HospitalReviewsCubit>().refresh(),
                      onManageClinics: () =>
                          _openManage(context, hospital, 'clinics'),
                      onManageDoctors: () =>
                          _openManage(context, hospital, 'doctors'),
                      onManageOfferings: () =>
                          _openServiceOfferings(context, hospital),
                      onEdit: () => _openEdit(context, hospital),
                      onDelete: state.isDeleting
                          ? null
                          : () => _confirmDelete(context),
                      isDeleting: state.isDeleting,
                      status: state.status,
                      errorMessage: state.errorMessage,
                    ),
                    _ClinicsTab(
                      clinics: state.clinics,
                      fallbackClinics: hospital.clinics,
                      baseUrl: baseUrl,
                      status: state.status,
                      onReload: _reload,
                      onManage: () => _openManage(context, hospital, 'clinics'),
                      onCreate: () => _openCreateClinic(context, hospital),
                    ),
                    _DoctorsTab(
                      doctors: state.doctors,
                      fallbackDoctors: hospital.doctors,
                      baseUrl: baseUrl,
                      status: state.status,
                      onReload: _reload,
                      onManage: () => _openManage(context, hospital, 'doctors'),
                    ),
                    _HospitalAppointmentsTab(
                      isFetchingToken: state.isFetchingToken,
                    ),
                    InvitationsTab(
                      invitations: state.invitations,
                      status: state.status,
                      baseUrl: baseUrl,
                      onReload: _reload,
                    ),
                    _OfferingsTab(
                      offerings: state.offerings,
                      baseUrl: baseUrl,
                      status: state.status,
                      onReload: _reload,
                      onManage: () => _openServiceOfferings(context, hospital),
                      onCreate: () => _openCreation(context, hospital.id),
                      onOpenDetail: (offering) =>
                          _openOfferingDetail(context, hospital.id, offering),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  void _openEdit(BuildContext context, Hospital hospital) {
    final router = GoRouter.of(context);
    final cubit = context.read<HospitalDetailCubit>();
    router
        .push('/hospitals/${hospital.id}/edit', extra: hospital)
        .then((value) {
      if (value == true) {
        _reload();
      } else if (value is Hospital) {
        cubit.updateHospital(value);
        _reload();
      }
    });
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final cancelTextColor =
            theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          title: Text('hospitals.detail.delete_confirm_title'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('hospitals.detail.delete_confirm_message'.tr()),
              const SizedBox(height: 18),
              AppButton(
                text: 'hospitals.detail.delete_confirm'.tr(),
                color: theme.colorScheme.error,
                textColor: theme.colorScheme.onError,
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'hospitals.detail.delete_cancel'.tr(),
                color: theme.colorScheme.surfaceVariant,
                textColor: cancelTextColor,
                icon: Icon(Icons.close_rounded, color: cancelTextColor),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ],
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final cubit = context.read<HospitalDetailCubit>();
      await cubit.deleteHospital();
    }
  }

  void _openInviteDoctor(BuildContext context, String baseUrl) {
    final state = context.read<HospitalDetailCubit>().state;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return BlocProvider(
          create: (_) => sl<InviteDoctorCubit>()..load(),
          child: InviteDoctorSheet(
            baseUrl: baseUrl,
            onOpenDetail: (doctor) {
              Navigator.of(ctx).pop();
              _openDoctorDetail(context, doctor, state);
            },
          ),
        );
      },
    );
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
    ).then((_) => _reload());
  }

  void _openDoctorDetail(
    BuildContext context,
    DoctorModel doctor,
    HospitalDetailState state,
  ) {
    context.push(
      '/doctors/${doctor.id}/detail',
      extra: {
        'doctor': doctor,
        'hospitalId': state.hospital.id,
        'hospitalDoctors': state.doctors,
        'invitations': state.invitations,
      },
    );
  }

  void _openServiceOfferings(BuildContext context, Hospital hospital) {
    context
        .push('/hospitals/${hospital.id}/service-offerings', extra: hospital)
        .then((_) => _reload());
  }

  void _openCreation(BuildContext context, String hospitalId) {
    final route = '/hospitals/$hospitalId/service-offerings/new';
    context.push(route).then((_) => _reload());
  }

  void _openOfferingDetail(
    BuildContext context,
    String hospitalId,
    ServiceOffering offering,
  ) {
    final route =
        '/hospitals/$hospitalId/service-offerings/${offering.id}/detail';
    context.push(route, extra: offering).then((_) => _reload());
  }

  void _openCreateClinic(BuildContext context, Hospital hospital) {
    context
        .push('/hospitals/${hospital.id}/clinics/new')
        .then((_) => _reload());
  }

  Widget _buildFloatingActionButton(
      BuildContext context, HospitalDetailState state, String baseUrl) {
    final hospital = state.hospital;
    final fab = <int, Widget>{
      1: ElevatedButton.icon(
        onPressed: () => _openCreateClinic(context, hospital),
        icon: const Icon(Icons.add_rounded),
        label: Text('hospitals.actions.add_clinic'.tr()),
      ),
      2: ElevatedButton.icon(
        onPressed: () => _openInviteDoctor(context, baseUrl),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text('hospitals.detail.invite_doctor'.tr()),
      ),
      5: ElevatedButton.icon(
        onPressed: () => _openCreation(context, hospital.id),
        icon: const Icon(Icons.add_rounded),
        label: Text('hospitals.actions.add_offering'.tr()),
      ),
    };

    final selectedFab = fab[_tabController.index];

    if (selectedFab == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: selectedFab,
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final Hospital hospital;
  final int clinicsCount;
  final int doctorsCount;
  final int offeringsCount;
  final String baseUrl;
  final HospitalReviewsState reviewsState;
  final bool isReviewsLoadingMore;
  final VoidCallback onReviewsReload;
  final VoidCallback onManageClinics;
  final VoidCallback onManageDoctors;
  final VoidCallback onManageOfferings;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isDeleting;
  final HospitalDetailStatus status;
  final String? errorMessage;

  const _DetailsTab({
    required this.hospital,
    required this.clinicsCount,
    required this.doctorsCount,
    required this.offeringsCount,
    required this.baseUrl,
    required this.reviewsState,
    required this.isReviewsLoadingMore,
    required this.onReviewsReload,
    required this.onManageClinics,
    required this.onManageDoctors,
    required this.onManageOfferings,
    required this.onEdit,
    this.onDelete,
    this.isDeleting = false,
    required this.status,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final description = _resolveDescription(locale, hospital);
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (status == HospitalDetailStatus.failure &&
                  (errorMessage ?? '').isNotEmpty) ...[
                _ErrorView(
                  message: errorMessage ?? 'hospitals.list.error_generic'.tr(),
                  onRetry: () =>
                      context.read<HospitalDetailCubit>().loadDetails(),
                ),
                const SizedBox(height: 16),
              ],
              HospitalDetailSectionCard(
                icon: Icons.info_rounded,
                title: 'hospitals.detail.about'.tr(),
                child: Text(
                  description?.isNotEmpty == true
                      ? description!
                      : 'hospitals.detail.no_description'.tr(),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 12),
              HospitalDetailSectionCard(
                icon: Icons.auto_awesome_mosaic_rounded,
                title: 'hospitals.detail.overview'.tr(),
                spacing: 10,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                  HospitalStatCard(
                    icon: PhosphorIconsBold.buildings,
                    label: 'hospitals.detail.stats.clinics'.tr(),
                    value: clinicsCount.toString(),
                  ),
                    HospitalStatCard(
                      icon: Icons.people_alt_rounded,
                      label: 'hospitals.detail.stats.doctors'.tr(),
                      value: doctorsCount.toString(),
                    ),
                  HospitalStatCard(
                    icon: PhosphorIconsBold.stethoscope,
                    label: 'hospitals.detail.stats.offerings'.tr(),
                    value: offeringsCount.toString(),
                  ),
                    HospitalStatCard(
                      icon: Icons.local_phone_rounded,
                      label: 'hospitals.detail.phone'.tr(),
                      value: hospital.phones.join(' | ').isNotEmpty
                          ? hospital.phones.join(' | ')
                          : '--',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              HospitalDetailSectionCard(
                icon: Icons.contact_phone_rounded,
                title: 'hospitals.detail.contact'.tr(),
                spacing: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HospitalInfoRow(
                      icon: Icons.place_rounded,
                      title: 'hospitals.form.address'.tr(),
                      value: hospital.address,
                      placeholderKey: 'hospitals.detail.no_description',
                    ),
                    const SizedBox(height: 10),
                    HospitalInfoRow(
                      icon: Icons.group_rounded,
                      title: 'hospitals.detail.facility_type'.tr(),
                      value: hospital.facilityType
                          .translationKey('hospitals.facility_type')
                          .tr(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _HospitalReviewsSection(
                reviews: reviewsState.reviews,
                status: reviewsState.status,
                isLoadingMore: isReviewsLoadingMore,
                baseUrl: baseUrl,
                onReload: onReviewsReload,
                onLoadMore: () =>
                    context.read<HospitalReviewsCubit>().loadMore(),
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Compact view that shows only the details tab content (no AppBar/TabBar).
class HospitalDetailsSummaryView extends StatelessWidget {
  final Hospital hospital;
  final int clinicsCount;
  final int doctorsCount;
  final int offeringsCount;
  final String baseUrl;
  final HospitalReviewsState reviewsState;
  final bool isReviewsLoadingMore;
  final VoidCallback onReviewsReload;
  final Future<void> Function() onRefresh;
  final VoidCallback onManageClinics;
  final VoidCallback onManageDoctors;
  final VoidCallback onManageOfferings;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isDeleting;
  final HospitalDetailStatus status;
  final String? errorMessage;

  const HospitalDetailsSummaryView({
    super.key,
    required this.hospital,
    required this.clinicsCount,
    required this.doctorsCount,
    required this.offeringsCount,
    required this.baseUrl,
    required this.reviewsState,
    required this.isReviewsLoadingMore,
    required this.onReviewsReload,
    required this.onRefresh,
    required this.onManageClinics,
    required this.onManageDoctors,
    required this.onManageOfferings,
    required this.onEdit,
    this.onDelete,
    this.isDeleting = false,
    required this.status,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final facility =
        hospital.facilityType.translationKey('hospitals.facility_type').tr();
    final cover = hospital.images.isNotEmpty
        ? _resolveImage(hospital.images.first, baseUrl)
        : null;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: _HeroBackdropLayer(imageUrl: cover),
                ),
                SizedBox(
                  height: 280,
                  child: Transform.translate(
                    offset: const Offset(0, -72),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _HeroForegroundLayer(
                        hospital: hospital,
                        facility: facility,
                        imageUrl: cover,
                        clinicsCount: clinicsCount,
                        doctorsCount: doctorsCount,
                        offeringsCount: offeringsCount,
                        primaryActionLabel: 'hospitals.detail.edit'.tr(),
                        secondaryActionLabel: onDelete == null
                            ? null
                            : isDeleting
                                ? 'hospitals.detail.deleting'.tr()
                                : 'hospitals.detail.delete'.tr(),
                        onPrimaryTap: onEdit,
                        onSecondaryTap: onDelete,
                        isSaved: false,
                        onToggleSave: () {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          ..._buildDetailsSlivers(
            context: context,
            hospital: hospital,
            clinicsCount: clinicsCount,
            doctorsCount: doctorsCount,
            offeringsCount: offeringsCount,
            baseUrl: baseUrl,
            reviewsState: reviewsState,
            isReviewsLoadingMore: isReviewsLoadingMore,
            onReviewsReload: onReviewsReload,
            onManageClinics: onManageClinics,
            onManageDoctors: onManageDoctors,
            onManageOfferings: onManageOfferings,
            onEdit: onEdit,
            onDelete: onDelete,
            isDeleting: isDeleting,
            status: status,
            errorMessage: errorMessage,
          ),
        ],
      ),
    );
  }
}

class _ClinicsTab extends StatelessWidget {
  final List<ClinicModel> clinics;
  final List<HospitalClinic> fallbackClinics;
  final String baseUrl;
  final HospitalDetailStatus status;
  final VoidCallback onReload;
  final VoidCallback onManage;
  final VoidCallback onCreate;

  const _ClinicsTab({
    required this.clinics,
    required this.fallbackClinics,
    required this.baseUrl,
    required this.status,
    required this.onReload,
    required this.onManage,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final List<_ClinicCardData> items = clinics.isNotEmpty
        ? clinics
            .map(
              (clinic) => _ClinicCardData(
                name: clinic.name,
                description: clinic.description ??
                    'hospitals.detail.no_description'.tr(),
                imageUrl: clinic.images.isNotEmpty ? clinic.images.first : null,
              ),
            )
            .toList()
        : fallbackClinics
            .map(
              (clinic) => _ClinicCardData(
                name: clinic.name,
                description: clinic.description ??
                    'hospitals.detail.no_description'.tr(),
                imageUrl: clinic.images.isNotEmpty ? clinic.images.first : null,
              ),
            )
            .toList();

    if (status == HospitalDetailStatus.loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'hospitals.detail.clinics_empty'.tr(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: onReload,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('hospitals.actions.retry'.tr()),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add_rounded),
                  label: Text('hospitals.actions.add'.tr()),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                IconButton(
                  onPressed: onReload,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.66,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final clinic = items[index];
                final image = _resolveImage(clinic.imageUrl, baseUrl);
                return InfoGridCard(
                  title: clinic.name,
                  subtitle: clinic.description,
                  badgeLabel: 'hospitals.detail.tabs.clinics'.tr(),
                  priceLabel: null,
                  imageUrl: image,
                  buttonLabel: 'hospitals.actions.reload'.tr(),
                  onPressed: onManage,
                );
              },
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }
}

List<Widget> _buildDetailsSlivers({
  required BuildContext context,
  required Hospital hospital,
  required int clinicsCount,
  required int doctorsCount,
  required int offeringsCount,
  required String baseUrl,
  required HospitalReviewsState reviewsState,
  required bool isReviewsLoadingMore,
  required VoidCallback onReviewsReload,
  required VoidCallback onManageClinics,
  required VoidCallback onManageDoctors,
  required VoidCallback onManageOfferings,
  required VoidCallback onEdit,
  required VoidCallback? onDelete,
  required bool isDeleting,
  required HospitalDetailStatus status,
  required String? errorMessage,
}) {
  final locale = context.locale.languageCode;
  final description = _resolveDescription(locale, hospital);
  final theme = Theme.of(context);

  return [
    SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (status == HospitalDetailStatus.failure &&
              (errorMessage ?? '').isNotEmpty) ...[
            _ErrorView(
              message: errorMessage ?? 'hospitals.list.error_generic'.tr(),
              onRetry: () => context.read<HospitalDetailCubit>().loadDetails(),
            ),
            const SizedBox(height: 16),
          ],
          HospitalDetailSectionCard(
            icon: Icons.info_rounded,
            title: 'hospitals.detail.about'.tr(),
            child: Text(
              description?.isNotEmpty == true
                  ? description!
                  : 'hospitals.detail.no_description'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          HospitalDetailSectionCard(
            icon: Icons.auto_awesome_mosaic_rounded,
            title: 'hospitals.detail.overview'.tr(),
            spacing: 10,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                HospitalStatCard(
                  icon: PhosphorIconsBold.buildings,
                  label: 'hospitals.detail.stats.clinics'.tr(),
                  value: clinicsCount.toString(),
                ),
                HospitalStatCard(
                  icon: Icons.people_alt_rounded,
                  label: 'hospitals.detail.stats.doctors'.tr(),
                  value: doctorsCount.toString(),
                ),
                HospitalStatCard(
                  icon: PhosphorIconsBold.stethoscope,
                  label: 'hospitals.detail.stats.offerings'.tr(),
                  value: offeringsCount.toString(),
                ),
                HospitalStatCard(
                  icon: Icons.local_phone_rounded,
                  label: 'hospitals.detail.phone'.tr(),
                  value: hospital.phones.join(' | ').isNotEmpty
                      ? hospital.phones.join(' | ')
                      : '--',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          HospitalDetailSectionCard(
            icon: Icons.contact_phone_rounded,
            title: 'hospitals.detail.contact'.tr(),
            spacing: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HospitalInfoRow(
                  icon: Icons.place_rounded,
                  title: 'hospitals.form.address'.tr(),
                  value: hospital.address,
                  placeholderKey: 'hospitals.detail.no_description',
                ),
                const SizedBox(height: 10),
                HospitalInfoRow(
                  icon: Icons.group_rounded,
                  title: 'hospitals.detail.facility_type'.tr(),
                  value: hospital.facilityType
                      .translationKey('hospitals.facility_type')
                      .tr(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _HospitalReviewsSection(
            reviews: reviewsState.reviews,
            status: reviewsState.status,
            isLoadingMore: isReviewsLoadingMore,
            baseUrl: baseUrl,
            onReload: onReviewsReload,
            onLoadMore: () => context.read<HospitalReviewsCubit>().loadMore(),
          ),
        ]),
      ),
    ),
  ];
}

class _DoctorsTab extends StatefulWidget {
  final List<DoctorModel> doctors;
  final List<Doctor> fallbackDoctors;
  final String baseUrl;
  final HospitalDetailStatus status;
  final VoidCallback onReload;
  final VoidCallback onManage;

  const _DoctorsTab({
    required this.doctors,
    required this.fallbackDoctors,
    required this.baseUrl,
    required this.status,
    required this.onReload,
    required this.onManage,
  });

  @override
  State<_DoctorsTab> createState() => _DoctorsTabState();
}

class _DoctorsTabState extends State<_DoctorsTab> {
  String _query = '';

  List<_DoctorCardData> get _allDoctors {
    if (widget.doctors.isNotEmpty) {
      return widget.doctors
          .map((doctor) => _DoctorCardData(doctor: doctor))
          .toList();
    }
    return widget.fallbackDoctors
        .map((doctor) => _DoctorCardData(doctor: doctor.toDoctorModel()))
        .toList();
  }

  List<_DoctorCardData> get _filteredDoctors {
    final doctors = _allDoctors;
    if (_query.trim().isEmpty) return doctors;
    final lower = _query.toLowerCase();
    return doctors
        .where((doctorData) =>
            doctorData.doctor.displayName.toLowerCase().contains(lower) ||
            (doctorData.doctor.specialty ?? '').toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == HospitalDetailStatus.loading &&
        widget.doctors.isEmpty &&
        widget.fallbackDoctors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filteredDoctors;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: 'hospitals.detail.search_doctors'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Builder(
            builder: (context) {
              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'hospitals.detail.doctors_empty'.tr(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: widget.onReload,
                        child: Text('hospitals.actions.retry'.tr()),
                      ),
                    ],
                  ),
                );
              }
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.60,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doctorData = filtered[index];
                          final doctor = doctorData.doctor;
                          return DoctorGridCard(
                            title: doctor.displayName,
                            subtitle: doctor.specialty ?? 'doctor'.tr(),
                            imageUrl: doctor.cover != null
                                ? _resolveImage(doctor.cover!, widget.baseUrl)
                                : null,
                            rating: doctor.rating,
                            buttonLabel: 'hospitals.actions.view_details'.tr(),
                            onPressed: () => _openDoctorDetail(context, doctor),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _openDoctorDetail(BuildContext context, DoctorModel doctor) {
    context.pushNamed(
      AppRoute.doctorDetail.name,
      pathParameters: {'doctorId': doctor.id},
      extra: doctor,
    );
  }
}

class _HospitalAppointmentsTab extends StatelessWidget {
  final bool isFetchingToken;

  const _HospitalAppointmentsTab({
    required this.isFetchingToken,
  });

  @override
  Widget build(BuildContext context) {
    if (isFetchingToken) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocConsumer<AppointmentsCubit, AppointmentsState>(
      listener: (context, state) {
        state.whenOrNull(
          updateSuccess: (_, __) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'appointments.messages.update_success'.tr(),
                ),
              ),
            );
          },
          updateFailure: (_, failure) {
            final fallback = 'appointments.messages.update_failure'.tr();
            final message =
                failure.message.isNotEmpty ? failure.message : fallback;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
        );
      },
      builder: (context, state) {
        final cubit = context.read<AppointmentsCubit>();
        return state.maybeWhen(
          success: (appointmentList) => _AppointmentsListSection(
            appointmentList: appointmentList,
            isProcessing: false,
            onRefresh: () => cubit.getMyHospitalAppointments(),
            onAppointmentTap: (appointment) =>
                _showHospitalAppointmentEditor(context, appointment),
          ),
          failure: (failure) => _AppointmentsErrorView(
            message: failure.message ?? 'unknown_error'.tr(),
            onRetry: () => cubit.getMyHospitalAppointments(),
          ),
          processing: (appointmentList) => _AppointmentsListSection(
            appointmentList: appointmentList,
            isProcessing: true,
            onRefresh: () => cubit.getMyHospitalAppointments(),
            onAppointmentTap: (appointment) =>
                _showHospitalAppointmentEditor(context, appointment),
          ),
          updateSuccess: (appointmentList, _) => _AppointmentsListSection(
            appointmentList: appointmentList,
            isProcessing: false,
            onRefresh: () => cubit.getMyHospitalAppointments(),
            onAppointmentTap: (appointment) =>
                _showHospitalAppointmentEditor(context, appointment),
          ),
          updateFailure: (appointmentList, __) => _AppointmentsListSection(
            appointmentList: appointmentList,
            isProcessing: false,
            onRefresh: () => cubit.getMyHospitalAppointments(),
            onAppointmentTap: (appointment) =>
                _showHospitalAppointmentEditor(context, appointment),
          ),
          orElse: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _AppointmentsListSection extends StatelessWidget {
  final AppointmentListModel appointmentList;
  final bool isProcessing;
  final Future<void> Function() onRefresh;
  final void Function(AppointmentModel) onAppointmentTap;

  const _AppointmentsListSection({
    required this.appointmentList,
    required this.isProcessing,
    required this.onRefresh,
    required this.onAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (appointmentList.appointments.isEmpty) {
      return _AppointmentsEmptyView(onReload: onRefresh);
    }

    final listView = RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemBuilder: (ctx, index) {
          final appointment = appointmentList.appointments[index];
          return AppointmentCard(
            appointment: appointment,
            onTap: () => onAppointmentTap(appointment),
            onEditStatus: () => onAppointmentTap(appointment),
          );
        },
        separatorBuilder: (ctx, _) => const SizedBox(height: 16),
        itemCount: appointmentList.appointments.length,
      ),
    );

    if (!isProcessing) return listView;

    return Stack(
      children: [
        listView,
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: LinearProgressIndicator(),
        ),
      ],
    );
  }
}

class _AppointmentsEmptyView extends StatelessWidget {
  final Future<void> Function() onReload;

  const _AppointmentsEmptyView({required this.onReload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'home.appointments.empty'.tr(),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('hospitals.actions.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _AppointmentsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AppointmentsErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('hospitals.actions.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentDateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _AppointmentDateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}

Future<void> _showHospitalAppointmentEditor(
  BuildContext context,
  AppointmentModel appointment,
) async {
  final start = DateTime.tryParse(appointment.startTime);
  final end = DateTime.tryParse(appointment.endTime);

  if (start == null || end == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('appointments.validation.invalid_dates'.tr())),
    );
    return;
  }

  final cubit = context.read<AppointmentsCubit>();
  DateTime selectedStart = start.toLocal();
  DateTime selectedEnd = end.toLocal();
  String selectedStatus = appointment.status;
  final statuses = List<String>.from(_allowedAppointmentStatuses);
  if (!statuses.contains(selectedStatus)) {
    statuses.insert(0, selectedStatus);
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'appointments.edit.title'.tr(),
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _AppointmentDateField(
                    label: 'appointments.edit.start_label'.tr(),
                    value: _formatFieldDate(sheetContext, selectedStart),
                    onTap: () async {
                      final newDate =
                          await _pickDateTime(sheetContext, selectedStart);
                      if (newDate != null) {
                        setSheetState(() {
                          selectedStart = newDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _AppointmentDateField(
                    label: 'appointments.edit.end_label'.tr(),
                    value: _formatFieldDate(sheetContext, selectedEnd),
                    onTap: () async {
                      final newDate =
                          await _pickDateTime(sheetContext, selectedEnd);
                      if (newDate != null) {
                        setSheetState(() {
                          selectedEnd = newDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'appointments.edit.status_label'.tr(),
                    ),
                    items: statuses
                        .map((status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text('appointments.status.$status'.tr()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() {
                        selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: Text('appointments.edit.cancel'.tr()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (!selectedEnd.isAfter(selectedStart)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'appointments.validation.invalid_range'
                                        .tr(),
                                  ),
                                ),
                              );
                              return;
                            }

                            Navigator.of(sheetContext).pop();
                            cubit.updateAppointment(
                              appointmentId: appointment.id,
                              startTime: selectedStart.toUtc(),
                              endTime: selectedEnd.toUtc(),
                              status: selectedStatus,
                              useHospitalToken: true,
                            );
                          },
                          child: Text('appointments.edit.submit'.tr()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<DateTime?> _pickDateTime(BuildContext context, DateTime initial) async {
  final firstDate = DateTime(initial.year - 1);
  final lastDate = DateTime(initial.year + 2);

  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: firstDate,
    lastDate: lastDate,
  );
  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
  );
  if (time == null) return null;

  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}

String _formatFieldDate(BuildContext context, DateTime dateTime) {
  final locale = context.locale.languageCode;
  final dateFormat = DateFormat.yMMMd(locale);
  final timeFormat = DateFormat.Hm(locale);
  return '${dateFormat.format(dateTime)} \u2013 ${timeFormat.format(dateTime)}';
}

const _allowedAppointmentStatuses = [
  'pending',
  'confirmed',
  'completed',
  'cancelled',
];

class _OfferingsTab extends StatelessWidget {
  final List<ServiceOffering> offerings;
  final String baseUrl;
  final HospitalDetailStatus status;
  final VoidCallback onReload;
  final VoidCallback onManage;
  final VoidCallback onCreate;
  final void Function(ServiceOffering) onOpenDetail;

  const _OfferingsTab({
    required this.offerings,
    required this.baseUrl,
    required this.status,
    required this.onReload,
    required this.onManage,
    required this.onCreate,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    if (status == HospitalDetailStatus.loading && offerings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (offerings.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'hospitals.detail.offerings_empty'.tr(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onReload,
            child: Text('service_offerings.list.retry'.tr()),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.6,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return AddServiceOfferingCard(onTap: onCreate);
                      },
                      childCount: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return AddServiceOfferingCard(onTap: onCreate);
                }
                final offering = offerings[index - 1];
                final serviceName = offering.localizedName(locale);
                final price = offering.price > 0
                    ? 'service_offerings.list.price'.tr(
                        namedArgs: {'price': offering.price.toStringAsFixed(2)},
                      )
                    : '';
                final image = _resolveImage(
                  offering.images.isNotEmpty
                      ? offering.images.first
                      : offering.service.image,
                  baseUrl,
                );
                final rating = offering.provider.rating;
                return ServiceOfferingCard(
                  title: serviceName,
                  subtitle: 'hospitals.detail.offerings_subtitle'.tr(),
                  badgeLabel: 'hospitals.detail.tabs.offerings'.tr(),
                  priceLabel: price,
                  imageUrl: image,
                  baseUrl: baseUrl,
                  rating: rating,
                  buttonLabel: 'hospitals.detail.cta.view_service'.tr(),
                  onTap: () => onOpenDetail(offering),
                );
              },
              childCount: offerings.length + 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroBackdropLayer extends StatelessWidget {
  final String? imageUrl;

  const _HeroBackdropLayer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        _HeroImageLayer(imageUrl: imageUrl),
        const _HeroGradientLayer(),
        _HeroEdgeHighlight(color: theme.colorScheme.surface),
      ],
    );
  }
}

class _HeroImageLayer extends StatelessWidget {
  final String? imageUrl;

  const _HeroImageLayer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (imageUrl != null) {
      return NetworkImageWrapper(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        fallback: Container(
          color: theme.colorScheme.surfaceVariant,
          alignment: Alignment.center,
          child: const Icon(PhosphorIconsBold.buildings, size: 48),
        ),
        shimmerChild: Container(color: theme.colorScheme.surfaceVariant),
      );
    }
    return Container(
      color: theme.colorScheme.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(PhosphorIconsBold.buildings, size: 48),
    );
  }
}

class _HeroGradientLayer extends StatelessWidget {
  const _HeroGradientLayer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.22),
            Colors.black.withOpacity(0.65),
          ],
        ),
      ),
    );
  }
}

class _HeroEdgeHighlight extends StatelessWidget {
  final Color color;
  const _HeroEdgeHighlight({required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              color,
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroForegroundLayer extends StatelessWidget {
  final Hospital hospital;
  final String facility;
  final String? imageUrl;
  final int clinicsCount;
  final int doctorsCount;
  final int offeringsCount;
  final String primaryActionLabel;
  final String? secondaryActionLabel;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  const _HeroForegroundLayer({
    required this.hospital,
    required this.facility,
    required this.imageUrl,
    required this.clinicsCount,
    required this.doctorsCount,
    required this.offeringsCount,
    required this.primaryActionLabel,
    this.secondaryActionLabel,
    required this.isSaved,
    this.onPrimaryTap,
    this.onSecondaryTap,
    this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 18,
          left: 12,
          child: _HeroAccentCircle(
            color: theme.colorScheme.primary.withOpacity(0.14),
            size: 110,
          ),
        ),
        Positioned(
          right: -26,
          bottom: -34,
          child: _HeroAccentCircle(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            size: 150,
          ),
        ),
        HospitalOverviewCard(
          title: hospital.displayName ?? hospital.name,
          subtitle: facility,
          rating: hospital.rating ?? 0,
          imageUrl: imageUrl,
          stats: [
            HospitalOverviewStat(
              label: 'hospitals.detail.stats.clinics'.tr(),
              value: clinicsCount.toString(),
            ),
            HospitalOverviewStat(
              label: 'hospitals.detail.stats.doctors'.tr(),
              value: doctorsCount.toString(),
            ),
            HospitalOverviewStat(
              label: 'hospitals.detail.stats.offerings'.tr(),
              value: offeringsCount.toString(),
            ),
          ],
          primaryActionLabel: primaryActionLabel,
          secondaryActionLabel: secondaryActionLabel,
          onPrimaryTap: onPrimaryTap,
          onSecondaryTap: onSecondaryTap,
          isSaved: isSaved,
          onToggleSave: onToggleSave,
        ),
      ],
    );
  }
}

class _HeroAccentCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _HeroAccentCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _DecoratedTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabBar tabBar;

  const _DecoratedTabBar({required this.tabBar});

  @override
  Size get preferredSize => Size.fromHeight(tabBar.preferredSize.height + 18);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              isDark ? theme.colorScheme.surfaceVariant : Colors.grey.shade100,
              isDark ? theme.colorScheme.surface : Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: tabBar,
        ),
      ),
    );
  }
}

class _FiltersRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
            foregroundColor: theme.colorScheme.primary,
            elevation: 0,
          ),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: Text('hospitals.detail.filters'.tr()),
        ),
        const Spacer(),
        Text(
          'hospitals.detail.sorting'.tr(),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(width: 4),
        const Icon(Icons.expand_more_rounded, size: 20),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('hospitals.actions.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return false;
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

String? _resolveImage(String? path, String baseUrl) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  try {
    return Uri.parse(baseUrl).resolve(path).toString();
  } catch (_) {
    return path;
  }
}

class _DoctorCardData {
  final DoctorModel doctor;

  _DoctorCardData({
    required this.doctor,
  });
}

class _ClinicCardData {
  final String name;
  final String description;
  final String? imageUrl;

  _ClinicCardData({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

class _HospitalReviewsSection extends StatefulWidget {
  final List<HospitalReviewModel> reviews;
  final HospitalReviewsStatus status;
  final String baseUrl;
  final VoidCallback onReload;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;

  const _HospitalReviewsSection({
    required this.reviews,
    required this.status,
    required this.baseUrl,
    required this.onReload,
    required this.onLoadMore,
    required this.isLoadingMore,
  });

  @override
  State<_HospitalReviewsSection> createState() =>
      _HospitalReviewsSectionState();
}

class _HospitalReviewsSectionState extends State<_HospitalReviewsSection> {
  static const int _initialVisible = 3;
  bool _showAll = false;

  @override
  void didUpdateWidget(covariant _HospitalReviewsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_showAll && widget.reviews.length <= _initialVisible) {
      _showAll = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.status == HospitalReviewsStatus.loading &&
        widget.reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'service_offerings.reviews.title'.tr(),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (widget.status == HospitalReviewsStatus.failure &&
        widget.reviews.isEmpty) {
      final errorText = (context.read<HospitalReviewsCubit>().state.message ??
              'service_offerings.reviews.error')
          .tr();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'service_offerings.reviews.title'.tr(),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(errorText, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: widget.onReload,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('service_offerings.reviews.retry'.tr()),
          ),
        ],
      );
    }

    if (widget.reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'service_offerings.reviews.title'.tr(),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'service_offerings.reviews.empty'.tr(),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: widget.onReload,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('service_offerings.reviews.retry'.tr()),
          ),
        ],
      );
    }

    final visible = _showAll
        ? widget.reviews
        : widget.reviews.take(_initialVisible).toList();
    final canShowMore =
        (!_showAll && widget.reviews.length > _initialVisible) ||
            widget.isLoadingMore;
    final canShowLess = _showAll && widget.reviews.length > _initialVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'service_offerings.reviews.title'.tr(),
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...visible
            .map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HospitalReviewCard(
                  review: review,
                  baseUrl: widget.baseUrl,
                ),
              ),
            )
            .toList(),
        if (canShowMore ||
            (widget.status == HospitalReviewsStatus.loading &&
                widget.reviews.isNotEmpty))
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.isLoadingMore
                  ? null
                  : () {
                      setState(() => _showAll = true);
                      if (!widget.isLoadingMore) {
                        widget.onLoadMore();
                      }
                    },
              icon: widget.isLoadingMore
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more_rounded),
              label: Text('service_offerings.reviews.load_more'.tr()),
            ),
          ),
        if (canShowLess)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _showAll = false),
              icon: const Icon(Icons.expand_less_rounded),
              label: Text('service_offerings.reviews.show_less'.tr()),
            ),
          ),
      ],
    );
  }
}
