import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_detail_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/invite_doctor_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/widgets/invite_doctor_sheet.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/widgets/invitations_tab.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/invitation_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/doctor_grid_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/hospital_detail_cards.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/service_offering_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/hospital_detail_components.dart';

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
      child: _HospitalDetailView(hospitalId: hospitalId),
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reload() {
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
          context.pop('deleted');
        }
      },
      builder: (context, state) {
        final hospital = state.hospital;
        final theme = Theme.of(context);
        final baseUrl = sl<AppConfig>().api.baseUrl;

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
        final tabBar = TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicatorPadding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          indicator: BoxDecoration(
            color: const Color(0xFF2E7CF6),
            borderRadius: BorderRadius.circular(12),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          tabs: [
            Tab(text: 'hospitals.detail.tabs.details'.tr()),
            Tab(text: 'hospitals.detail.tabs.clinics'.tr()),
            Tab(text: 'hospitals.detail.tabs.doctors'.tr()),
            Tab(text: 'hospitals.detail.tabs.invitations'.tr()),
            Tab(text: 'hospitals.detail.tabs.offerings'.tr()),
          ],
        );

        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _openInviteDoctor(context, baseUrl),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text('hospitals.detail.invite_doctor'.tr()),
              ),
            ),
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'hospitals.detail.edit'.tr(),
                    onPressed: state.isDeleting
                        ? null
                        : () => _openEdit(context, hospital),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded),
                    onPressed: () => _openManagementMenu(context, hospital),
                  ),
                ],
                titleSpacing: 0,
                title: Text(
                  innerBoxIsScrolled
                      ? (hospital.displayName ?? hospital.name)
                      : 'hospitals.list.title'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _HeroForegroundLayer(
                            hospital: hospital,
                            facility: facility,
                            imageUrl: cover,
                            clinicsCount: clinicsCount,
                            doctorsCount: doctorsCount,
                            offeringsCount: offeringsCount,
                            primaryActionLabel: 'hospitals.detail.edit'.tr(),
                            secondaryActionLabel: state.isDeleting
                                ? 'hospitals.detail.deleting'.tr()
                                : 'hospitals.detail.delete'.tr(),
                            onPrimaryTap: () => _openEdit(context, hospital),
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
                  onManageClinics: () =>
                      _openManage(context, hospital, 'clinics'),
                  onManageDoctors: () =>
                      _openManage(context, hospital, 'doctors'),
                  onManageOfferings: () =>
                      _openServiceOfferings(context, hospital),
                  onEdit: () => _openEdit(context, hospital),
                  onDelete:
                      state.isDeleting ? null : () => _confirmDelete(context),
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
                InvitationsTab(
                  invitations: state.invitations,
                  status: state.status,
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
        );
      },
    );
  }

  void _openManagementMenu(BuildContext context, Hospital hospital) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.maps_home_work_outlined),
                  title: Text('hospitals.detail.manage_clinics'.tr()),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openManage(context, hospital, 'clinics');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.groups_2_outlined),
                  title: Text('hospitals.detail.manage_doctors'.tr()),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openManage(context, hospital, 'doctors');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.design_services_outlined),
                  title: Text('hospitals.detail.manage_offerings'.tr()),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openServiceOfferings(context, hospital);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text('hospitals.detail.edit'.tr()),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openEdit(context, hospital);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    'hospitals.detail.delete'.tr(),
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _confirmDelete(context);
                  },
                ),
              ],
            ),
          ),
        );
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
        context.pop(true);
      } else if (value is Hospital) {
        cubit.updateHospital(value);
        _reload();
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

  void _openInviteDoctor(BuildContext context, String baseUrl) {
    final state = context.read<HospitalDetailCubit>().state;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return BlocProvider(
          create: (_) => sl<InviteDoctorCubit>()..load(limit: 50),
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
}

class _DetailsTab extends StatelessWidget {
  final Hospital hospital;
  final int clinicsCount;
  final int doctorsCount;
  final int offeringsCount;
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
    required this.onManageClinics,
    required this.onManageDoctors,
    required this.onManageOfferings,
    required this.onEdit,
    required this.onDelete,
    required this.isDeleting,
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
                      icon: Icons.local_hospital_rounded,
                      label: 'hospitals.detail.stats.clinics'.tr(),
                      value: clinicsCount.toString(),
                    ),
                    HospitalStatCard(
                      icon: Icons.people_alt_rounded,
                      label: 'hospitals.detail.stats.doctors'.tr(),
                      value: doctorsCount.toString(),
                    ),
                    HospitalStatCard(
                      icon: Icons.medical_services_rounded,
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
            ]),
          ),
        ),
      ],
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
                ElevatedButton.icon(
                  onPressed: onManage,
                  icon: const Icon(Icons.dashboard_customize_rounded),
                  label: Text('hospitals.detail.manage_clinics'.tr()),
                ),
                const Spacer(),
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
          .map(
            (doctor) => _DoctorCardData(
              name: doctor.displayName,
              subtitle: 'doctor'.tr(),
              imageUrl: null,
              rating: doctor.rating,
            ),
          )
          .toList();
    }
    return widget.fallbackDoctors
        .map(
          (doctor) => _DoctorCardData(
            name: doctor.user.name,
            subtitle: doctor.specialty ?? 'doctor'.tr(),
            imageUrl: doctor.cover,
            rating: doctor.rating,
          ),
        )
        .toList();
  }

  List<_DoctorCardData> get _filteredDoctors {
    final doctors = _allDoctors;
    if (_query.trim().isEmpty) return doctors;
    final lower = _query.toLowerCase();
    return doctors
        .where((doctor) =>
            doctor.name.toLowerCase().contains(lower) ||
            doctor.subtitle.toLowerCase().contains(lower))
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: widget.onManage,
                    icon: const Icon(Icons.manage_accounts_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _FiltersRow(),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.55,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final doctor = filtered[index];
                return DoctorGridCard(
                  title: doctor.name,
                  subtitle: doctor.subtitle,
                  imageUrl: doctor.imageUrl != null
                      ? _resolveImage(doctor.imageUrl!, widget.baseUrl)
                      : null,
                  rating: doctor.rating,
                  buttonLabel: 'hospitals.actions.reload'.tr(),
                  isSaved: false,
                  onToggleSave: () {},
                  onPressed: widget.onManage,
                );
              },
              childCount: filtered.length,
            ),
          ),
        ),
      ],
    );
  }
}

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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'hospitals.detail.offerings_empty'.tr(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: onReload,
                  child: Text('service_offerings.list.retry'.tr()),
                ),
                TextButton(
                  onPressed: onCreate,
                  child: Text('service_offerings.list.add'.tr()),
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
                ElevatedButton.icon(
                  onPressed: onManage,
                  icon: const Icon(Icons.view_list_rounded),
                  label: Text('service_offerings.list.title'.tr()),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onReload,
                  icon: const Icon(Icons.refresh_rounded),
                ),
                IconButton(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add_circle_outline),
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
              childAspectRatio: 0.55,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final offering = offerings[index];
                final serviceName = offering.service.localizedName(locale);
                final price = offering.price > 0
                    ? 'service_offerings.list.price'
                        .tr(args: [offering.price.toStringAsFixed(2)])
                    : '';
                final image = _resolveImage(offering.service.image, baseUrl);
                return ServiceOfferingCard(
                  title: serviceName,
                  subtitle: 'hospitals.detail.offerings_subtitle'.tr(),
                  badgeLabel: 'hospitals.detail.tabs.offerings'.tr(),
                  priceLabel: price,
                  imageUrl: image,
                  buttonLabel: 'hospitals.detail.cta.view_service'.tr(),
                  onTap: () => onOpenDetail(offering),
                );
              },
              childCount: offerings.length,
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
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: theme.colorScheme.surfaceVariant,
          alignment: Alignment.center,
          child: const Icon(Icons.local_hospital_rounded, size: 48),
        ),
      );
    }
    return Container(
      color: theme.colorScheme.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(Icons.local_hospital_rounded, size: 48),
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
  final String secondaryActionLabel;
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
    required this.secondaryActionLabel,
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
          rating: 0,
          imageUrl: imageUrl,
          stats: [
            HospitalOverviewStat(
              icon: Icons.local_hospital_rounded,
              label: 'hospitals.detail.stats.clinics'.tr(),
              value: clinicsCount.toString(),
            ),
            HospitalOverviewStat(
              icon: Icons.people_rounded,
              label: 'hospitals.detail.stats.doctors'.tr(),
              value: doctorsCount.toString(),
            ),
            HospitalOverviewStat(
              icon: Icons.medical_services_rounded,
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
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.grey.shade100,
              Colors.white,
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
  final String name;
  final String subtitle;
  final String? imageUrl;
  final double? rating;

  _DoctorCardData({
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
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
