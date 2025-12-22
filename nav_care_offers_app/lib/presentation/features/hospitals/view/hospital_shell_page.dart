import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/core/routing/app_router.dart';
import 'package:nav_care_offers_app/data/appointments/models/appointment_model.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/invitations/hospital_invitations_repository.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/reviews/hospital_reviews/models/hospital_review_model.dart';
import 'package:nav_care_offers_app/presentation/features/appointments/viewmodel/appointments_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/appointments/viewmodel/appointments_state.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/widgets/invite_doctor_sheet.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_detail_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_reviews_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_reviews_state.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/invite_doctor_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/shell/viewmodel/nav_shell_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/doctor_grid_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/hospital_detail_cards.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/invitation_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/hospital_review_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/service_offering_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/appointment_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/hospital_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/hospital_detail_components.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_app_bar.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_destination.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_nav_bar.dart';
import 'hospital_detail_page.dart' show HospitalDetailsSummaryView, HospitalDetailPage;

/// Hospital app shell with bottom navigation (no drawer).
/// Tabs: Clinics, Doctors (with invitations), Service offerings, Appointments, Profile.
class HospitalShellPage extends StatefulWidget {
  final Hospital hospital;

  const HospitalShellPage({
    super.key,
    required this.hospital,
  });

  @override
  State<HospitalShellPage> createState() => _HospitalShellPageState();
}

class _HospitalShellPageState extends State<HospitalShellPage> {
  bool _appointmentsLoaded = false;

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavShellCubit()),
        BlocProvider(create: (_) => sl<AppointmentsCubit>()),
        BlocProvider(
          create: (_) => sl<HospitalReviewsCubit>()
            ..loadReviews(hospitalId: widget.hospital.id),
        ),
        BlocProvider(
          create: (_) =>
              sl<HospitalDetailCubit>(param1: widget.hospital)..loadDetails(),
        ),
      ],
      child: BlocListener<HospitalDetailCubit, HospitalDetailState>(
        listenWhen: (prev, curr) =>
            prev.hospitalToken != curr.hospitalToken ||
            prev.isFetchingToken != curr.isFetchingToken,
        listener: (context, state) {
          if (!_appointmentsLoaded &&
              !state.isFetchingToken &&
              (state.hospitalToken?.isNotEmpty ?? false)) {
            _appointmentsLoaded = true;
            context.read<AppointmentsCubit>().getMyHospitalAppointments();
          }
        },
        child: BlocBuilder<NavShellCubit, NavShellState>(
          builder: (context, navState) {
            final detailState = context.watch<HospitalDetailCubit>().state;
            print("detail state offerings ${detailState.offerings.length}");
            final destinations =
                _buildDestinations(context, detailState, baseUrl);

            return Scaffold(
              appBar: NavShellAppBar(
                useBackButton: true,
                onBackTap: () => context.go(AppRoute.home.path),
                notificationCount: 0,
                onNotificationsTap: () => context.push('/notifications'),
              ),
              body:
                  _buildBody(detailState, destinations, navState.currentIndex),
              bottomNavigationBar: NavShellNavBar(
                currentIndex: navState.currentIndex,
                destinations: destinations,
                onTap: (index) => _onDestinationSelected(context, index),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: _buildFab(
                  context, navState.currentIndex, detailState, baseUrl),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    HospitalDetailState detailState,
    List<NavShellDestination> destinations,
    int currentIndex,
  ) {
    if (detailState.status == HospitalDetailStatus.initial ||
        (detailState.status == HospitalDetailStatus.loading &&
            detailState.hospitalToken == null &&
            detailState.clinics.isEmpty &&
            detailState.doctors.isEmpty &&
            detailState.offerings.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    return IndexedStack(
      index: currentIndex,
      children: destinations.map((d) => d.content).toList(),
    );
  }

  List<NavShellDestination> _buildDestinations(BuildContext innerContext,
      HospitalDetailState detailState, String baseUrl) {
    final hospital = detailState.hospital;
    final reviewsState = innerContext.watch<HospitalReviewsCubit>().state;
    final shellContext = innerContext;

    return [
      NavShellDestination(
        label: 'hospitals.detail.tabs.clinics'.tr(),
        icon: Icons.local_hospital_rounded,
        content: ClinicsTabContent(
          clinics: detailState.clinics,
          fallbackClinics: hospital.clinics,
          baseUrl: baseUrl,
          status: detailState.status,
          onReload: () => shellContext
              .read<HospitalDetailCubit>()
              .loadDetails(refresh: true),
          onOpenClinic: (clinic) => _openClinicAsHospital(shellContext, clinic),
        ),
      ),
      NavShellDestination(
        label: 'hospitals.detail.tabs.doctors'.tr(),
        icon: Icons.people_alt_rounded,
        content: DoctorsAndInvitesTab(
          doctors: detailState.doctors,
          fallbackDoctors: hospital.doctors,
          invitations: detailState.invitations,
          baseUrl: baseUrl,
          status: detailState.status,
          onReload: () => shellContext
              .read<HospitalDetailCubit>()
              .loadDetails(refresh: true),
          onManage: () => _openManage(shellContext, hospital, 'doctors'),
          onInvite: () => _openInviteDoctor(shellContext, baseUrl, detailState),
        ),
      ),
      NavShellDestination(
        label: 'hospitals.detail.tabs.offerings'.tr(),
        icon: Icons.medical_services_rounded,
        content: OfferingsTabContent(
          offerings: detailState.offerings,
          baseUrl: baseUrl,
          status: detailState.status,
          onReload: () => shellContext
              .read<HospitalDetailCubit>()
              .loadDetails(refresh: true),
          onManage: () => _openServiceOfferings(shellContext, hospital),
          onCreate: () => _openOfferingCreation(shellContext, hospital.id),
          onOpenDetail: (offering) =>
              _openOfferingDetail(shellContext, hospital.id, offering),
        ),
      ),
      NavShellDestination(
        label: 'shell.nav_appointments'.tr(),
        icon: Icons.calendar_today_rounded,
        content: HospitalAppointmentsTab(
          isFetchingToken: detailState.isFetchingToken,
        ),
      ),
      NavShellDestination(
        label: 'shell.nav_profile'.tr(),
        icon: Icons.person_rounded,
        content: HospitalDetailsSummaryView(
          hospital: hospital,
          clinicsCount: detailState.clinics.isNotEmpty
              ? detailState.clinics.length
              : hospital.clinics.length,
          doctorsCount: detailState.doctors.isNotEmpty
              ? detailState.doctors.length
              : hospital.doctors.length,
          offeringsCount: detailState.offerings.length,
          baseUrl: baseUrl,
          reviewsState: reviewsState,
          isReviewsLoadingMore: reviewsState.isLoadingMore,
          onReviewsReload: () =>
              shellContext.read<HospitalReviewsCubit>().refresh(),
          onManageClinics: () => _openManage(shellContext, hospital, 'clinics'),
          onManageDoctors: () => _openManage(shellContext, hospital, 'doctors'),
          onManageOfferings: () => _openServiceOfferings(shellContext, hospital),
          onEdit: () => _openEdit(shellContext, hospital),
          onDelete: detailState.isDeleting
              ? null
              : () => _confirmDelete(shellContext, hospital),
          isDeleting: detailState.isDeleting,
          status: detailState.status,
          errorMessage: detailState.errorMessage,
        ),
      ),
    ];
  }

  Widget _buildFab(BuildContext context, int index, HospitalDetailState state,
      String baseUrl) {
    final hospital = state.hospital;
    final map = <int, Widget>{
      0: ElevatedButton.icon(
        onPressed: () => _openCreateClinic(context, hospital),
        icon: const Icon(Icons.add_rounded),
        label: Text('hospitals.actions.add_clinic'.tr()),
      ),
      1: ElevatedButton.icon(
        onPressed: () => _openInviteDoctor(context, baseUrl, state),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text('hospitals.detail.invite_doctor'.tr()),
      ),
      2: ElevatedButton.icon(
        onPressed: () => _openOfferingCreation(context, hospital.id),
        icon: const Icon(Icons.add_rounded),
        label: Text('hospitals.actions.add_offering'.tr()),
      ),
    };

    return map[index] != null
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: double.infinity, child: map[index]!),
          )
        : const SizedBox.shrink();
  }

  Future<void> _onDestinationSelected(BuildContext context, int index) async {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state.status == AuthStatus.authenticated) {
      await authCubit.verifyTokenValidity();
      if (authCubit.state.status != AuthStatus.authenticated) return;
    }
    context.read<NavShellCubit>().setTab(index);
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

  void _openServiceOfferings(BuildContext context, Hospital hospital) {
    context
        .push('/hospitals/${hospital.id}/service-offerings', extra: hospital)
        .then((_) =>
            context.read<HospitalDetailCubit>().loadDetails(refresh: true));
  }

  void _openOfferingCreation(BuildContext context, String hospitalId) {
    final route = '/hospitals/$hospitalId/service-offerings/new';
    context.push(route).then((_) {
      context.read<HospitalDetailCubit>().loadDetails(refresh: true);
    });
  }

  void _openOfferingDetail(
    BuildContext context,
    String hospitalId,
    ServiceOffering offering,
  ) {
    final route =
        '/hospitals/$hospitalId/service-offerings/${offering.id}/detail';
    context.push(route, extra: offering).then((_) {
      context.read<HospitalDetailCubit>().loadDetails(refresh: true);
    });
  }

  void _openCreateClinic(BuildContext context, Hospital hospital) {
    context.push('/hospitals/${hospital.id}/clinics/new').then((_) {
      context.read<HospitalDetailCubit>().loadDetails(refresh: true);
    });
  }

  void _openClinicAsHospital(BuildContext context, ClinicModel clinic) {
    final hospital = clinic.toHospital();
    context.push('/clinics/${hospital.id}/app', extra: hospital);
  }

  void _openInviteDoctor(
    BuildContext context,
    String baseUrl,
    HospitalDetailState state,
  ) {
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

  void _openDoctorDetail(
    BuildContext context,
    DoctorModel doctor,
    HospitalDetailState state,
  ) {
    context.pushNamed(
      AppRoute.doctorDetail.name,
      pathParameters: {'doctorId': doctor.id},
      extra: {
        'doctor': doctor,
        'hospitalId': state.hospital.id,
        'hospitalDoctors': state.doctors,
        'invitations': state.invitations,
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
        cubit.loadDetails(refresh: true);
      }
    });
  }

  Future<void> _confirmDelete(BuildContext context, Hospital hospital) async {
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
              FilledButton.icon(
                onPressed: () => Navigator.of(ctx).pop(true),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                label: Text('hospitals.detail.delete_confirm'.tr()),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(ctx).pop(false),
                icon: const Icon(Icons.close_rounded),
                label: Text('hospitals.detail.delete_cancel'.tr()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cancelTextColor,
                ),
              ),
            ],
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<HospitalDetailCubit>().deleteHospital();
    }
  }
}

class ClinicsTabContent extends StatelessWidget {
  final List<ClinicModel> clinics;
  final List<HospitalClinic> fallbackClinics;
  final String baseUrl;
  final HospitalDetailStatus status;
  final VoidCallback onReload;
  final void Function(ClinicModel clinic) onOpenClinic;

  const ClinicsTabContent({
    super.key,
    required this.clinics,
    required this.fallbackClinics,
    required this.baseUrl,
    required this.status,
    required this.onReload,
    required this.onOpenClinic,
  });

  @override
  Widget build(BuildContext context) {
    final items = clinics.isNotEmpty
        ? clinics
        : fallbackClinics
            .map(
              (c) => ClinicModel(
                id: c.id,
                name: c.name,
                images: c.images,
                description: c.description,
                address: null,
                phones: c.phones,
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
            Text('hospitals.detail.clinics_empty'.tr()),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onReload,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('hospitals.actions.retry'.tr()),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onReload(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final clinic = items[index];
          final image = clinic.images.isNotEmpty
              ? _resolveImage(clinic.images.first, baseUrl)
              : null;
          return HospitalCard(
            title: clinic.name,
            subtitle:
                clinic.description ?? 'hospitals.detail.no_description'.tr(),
            facilityLabel: 'hospitals.facility_type.clinic'.tr(),
            phoneLabel: clinic.phones.join(' | '),
            imageUrl: image,
            onTap: () => onOpenClinic(clinic),
          );
        },
      ),
    );
  }
}

class DoctorsAndInvitesTab extends StatefulWidget {
  final List<DoctorModel> doctors;
  final List<Doctor> fallbackDoctors;
  final List<HospitalInvitation> invitations;
  final String baseUrl;
  final HospitalDetailStatus status;
  final VoidCallback onReload;
  final VoidCallback onManage;
  final VoidCallback onInvite;

  const DoctorsAndInvitesTab({
    super.key,
    required this.doctors,
    required this.fallbackDoctors,
    required this.invitations,
    required this.baseUrl,
    required this.status,
    required this.onReload,
    required this.onManage,
    required this.onInvite,
  });

  @override
  State<DoctorsAndInvitesTab> createState() => _DoctorsAndInvitesTabState();
}

class _DoctorsAndInvitesTabState extends State<DoctorsAndInvitesTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _query = '';
  final Set<String> _cancellingIds = {};
  final Set<String> _cancelledIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancelInvitation(
    BuildContext context,
    HospitalInvitation invitation,
  ) async {
    if (_cancellingIds.contains(invitation.id)) return;
    setState(() => _cancellingIds.add(invitation.id));

    final result = await sl<HospitalInvitationsRepository>()
        .cancelInvitation(invitationId: invitation.id);

    if (!mounted) return;

    result.fold(
      onFailure: (failure) {
        setState(() => _cancellingIds.remove(invitation.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      onSuccess: (_) {
        setState(() {
          _cancellingIds.remove(invitation.id);
          _cancelledIds.add(invitation.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الغاء الدعوة')),
        );
        widget.onReload();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final indicatorColor = theme.colorScheme.primary;
    final unselectedColor = isDark
        ? theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
        : Colors.grey.shade600;

    return Column(
      children: [
        TabBar(
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
            Tab(text: 'hospitals.detail.tabs.doctors'.tr()),
            Tab(text: 'hospitals.detail.tabs.invitations'.tr()),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDoctorsTab(),
              _buildInvitationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorsTab() {
    final doctors = widget.doctors.isNotEmpty
        ? widget.doctors
        : widget.fallbackDoctors.map((d) => d.toDoctorModel()).toList();

    if (widget.status == HospitalDetailStatus.loading && doctors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filterDoctors(doctors, _query);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => widget.onReload(),
            child: filtered.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      Center(
                          child: Text('hospitals.detail.doctors_empty'.tr())),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: widget.onInvite,
                          child: Text('hospitals.detail.invite_doctor'.tr()),
                        ),
                      ),
                    ],
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.64,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doctor = filtered[index];
                      return DoctorGridCard(
                        title: doctor.displayName,
                        subtitle: doctor.specialty ?? 'doctor'.tr(),
                        imageUrl: doctor.cover != null
                            ? _resolveImage(doctor.cover!, widget.baseUrl)
                            : null,
                        rating: doctor.rating,
                        buttonLabel: 'hospitals.actions.view_details'.tr(),
                        onPressed: () => _openDoctor(context, doctor),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvitationsTab() {
    if (widget.status == HospitalDetailStatus.loading &&
        widget.invitations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('hospitals.detail.invitations_empty'.tr()),
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.onInvite,
              child: Text('hospitals.detail.invite_doctor'.tr()),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: widget.invitations.length,
      itemBuilder: (context, index) {
        final inv = widget.invitations[index];
        final doctorName = inv.inviteeDoctor?.displayName.isNotEmpty == true
            ? inv.inviteeDoctor!.displayName
            : inv.inviteeDoctor?.userId ?? '?';
        final effectiveStatus =
            _cancelledIds.contains(inv.id) ? 'cancelled' : inv.status;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InvitationCard(
            doctorName: doctorName,
            status: effectiveStatus,
            invitedBy: inv.invitedByName,
            onCancel: effectiveStatus == 'pending'
                ? () => _cancelInvitation(context, inv)
                : null,
            isCancelling: _cancellingIds.contains(inv.id),
          ),
        );
      },
    );
  }

  List<DoctorModel> _filterDoctors(List<DoctorModel> doctors, String query) {
    if (query.trim().isEmpty) return doctors;
    final lower = query.toLowerCase();
    return doctors
        .where((d) =>
            d.displayName.toLowerCase().contains(lower) ||
            (d.specialty ?? '').toLowerCase().contains(lower))
        .toList();
  }

  void _openDoctor(BuildContext context, DoctorModel doctor) {
    context.pushNamed(
      AppRoute.doctorDetail.name,
      pathParameters: {'doctorId': doctor.id},
      extra: doctor,
    );
  }
}

class OfferingsTabContent extends StatelessWidget {
  final List<ServiceOffering> offerings;
  final String baseUrl;
  final HospitalDetailStatus status;
  final VoidCallback onReload;
  final VoidCallback onManage;
  final VoidCallback onCreate;
  final void Function(ServiceOffering) onOpenDetail;

  const OfferingsTabContent({
    super.key,
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
    if (status == HospitalDetailStatus.loading && offerings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (offerings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('hospitals.detail.offerings_empty'.tr()),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: onReload,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('hospitals.actions.retry'.tr()),
                ),
                TextButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add_rounded),
                  label: Text('hospitals.actions.add_offering'.tr()),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onReload(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: offerings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final offering = offerings[index];
          final locale = context.locale.languageCode;
          final title = offering.localizedName(locale);
          final priceText = offering.price > 0
              ? 'service_offerings.list.price'
                  .tr(namedArgs: {'price': offering.price.toStringAsFixed(2)})
              : null;
          final subtitle = offering.descriptionEn ??
              offering.descriptionAr ??
              offering.descriptionFr ??
              offering.descriptionSp ??
              'service_offerings.detail.no_description'.tr();
          final image = _resolveImage(
            offering.images.isNotEmpty
                ? offering.images.first
                : (offering.service.image ??
                    offering.provider.cover ??
                    offering.provider.profilePicture ??
                    offering.provider.user.profilePicture),
            baseUrl,
          );
          return ServiceOfferingCard(
            title: title,
            subtitle: subtitle,
            priceLabel: priceText,
            imageUrl: image,
            baseUrl: baseUrl,
            onTap: () => onOpenDetail(offering),
          );
        },
      ),
    );
  }
}

class HospitalAppointmentsTab extends StatelessWidget {
  final bool isFetchingToken;

  const HospitalAppointmentsTab({
    super.key,
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

class HospitalProfileTab extends StatelessWidget {
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

  const HospitalProfileTab({
    super.key,
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
              HospitalDetailSectionCard(
                icon: Icons.manage_accounts_rounded,
                title: 'hospitals.actions.manage'.tr(),
                child: Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onManageClinics,
                      icon: const Icon(Icons.local_hospital_rounded),
                      label: Text('hospitals.detail.tabs.clinics'.tr()),
                    ),
                    OutlinedButton.icon(
                      onPressed: onManageDoctors,
                      icon: const Icon(Icons.people_alt_rounded),
                      label: Text('hospitals.detail.tabs.doctors'.tr()),
                    ),
                    OutlinedButton.icon(
                      onPressed: onManageOfferings,
                      icon: const Icon(Icons.medical_services_rounded),
                      label: Text('hospitals.detail.tabs.offerings'.tr()),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded),
                      label: Text('hospitals.actions.edit'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: isDeleting
                          ? Text('hospitals.detail.deleting'.tr())
                          : Text('hospitals.actions.delete'.tr()),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
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
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text('hospitals.actions.retry'.tr()),
          ),
        ],
      ),
    );
  }
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

String? _resolveImage(String? image, String baseUrl) {
  if (image == null || image.isEmpty) return null;
  if (image.startsWith('http')) return image;
  try {
    return Uri.parse(baseUrl).resolve(image).toString();
  } catch (_) {
    return '$baseUrl/$image';
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

const _allowedAppointmentStatuses = [
  'pending',
  'confirmed',
  'completed',
  'cancelled',
];
