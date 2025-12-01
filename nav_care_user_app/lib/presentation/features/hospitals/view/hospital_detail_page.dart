import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_user_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_user_app/data/hospitals/models/hospital_model.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';
import 'package:nav_care_user_app/presentation/features/hospitals/viewmodel/hospital_detail_cubit.dart';
import 'package:nav_care_user_app/presentation/features/hospitals/viewmodel/hospital_detail_state.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/doctor_grid_card.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/hospital_detail_cards.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/service_offering_card.dart';
import 'package:nav_care_user_app/presentation/shared/ui/molecules/hospital_detail_components.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/view/service_offering_detail_page.dart';
import 'package:nav_care_user_app/presentation/features/doctors/view/doctor_detail_page.dart';

class HospitalDetailPage extends StatelessWidget {
  final String hospitalId;
  final HospitalModel? initial;

  const HospitalDetailPage({
    super.key,
    required this.hospitalId,
    this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<HospitalDetailCubit>();
        if (initial != null) {
          cubit.emit(cubit.state.copyWith(hospital: initial));
        }
        cubit.load(hospitalId);
        return cubit;
      },
      child: _HospitalDetailView(hospitalId: hospitalId),
    );
  }
}

class _HospitalDetailView extends StatefulWidget {
  final String hospitalId;
  const _HospitalDetailView({required this.hospitalId});

  @override
  State<_HospitalDetailView> createState() {
    return _HospitalDetailViewState();
  }
}

class _HospitalDetailViewState extends State<_HospitalDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyText(String text, String feedback) {
    Clipboard.setData(ClipboardData(text: text));
    if (feedback.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feedback),
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _copyText(url, 'Could not launch URL. Copied to clipboard.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HospitalDetailCubit, HospitalDetailState>(
      builder: (context, state) {
        final hospital = state.hospital;
        final theme = Theme.of(context);
        final baseUrl = sl<AppConfig>().api.baseUrl;

        if (state.status == HospitalDetailStatus.loading && hospital == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == HospitalDetailStatus.failure && hospital == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('hospitals.detail.title'.tr()),
            ),
            body: _ErrorView(
              message: state.message ?? 'hospitals.detail.error'.tr(),
              onRetry: () =>
                  context.read<HospitalDetailCubit>().load(widget.hospitalId),
            ),
          );
        }

        if (hospital == null) return const SizedBox.shrink();

        final clinicsCount = state.clinics.length;
        final doctorsCount = state.doctors.length;
        final offeringsCount = state.offerings.length;
        final facility =
            hospital.field.isNotEmpty ? hospital.field : hospital.facilityType;
        final cover = hospital.primaryImage(baseUrl: baseUrl);
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
            Tab(text: 'hospitals.detail.tabs.offerings'.tr()),
          ],
        );

        return Scaffold(
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
                    icon: const Icon(Icons.more_horiz_rounded),
                    onPressed: () {},
                  ),
                ],
                titleSpacing: 0,
                title: Text(
                  innerBoxIsScrolled
                      ? hospital.name
                      : 'hospitals.detail.title'.tr(),
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
                    Container(
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
                            primaryActionLabel:
                                'hospitals.detail.actions.contact'.tr(),
                            secondaryActionLabel:
                                'hospitals.detail.actions.call'.tr(),
                            onPrimaryTap: hospital.phone.isNotEmpty
                                ? () =>
                                    _launchUrl('sms:${hospital.phone.first}')
                                : null,
                            onSecondaryTap: hospital.phone.isNotEmpty
                                ? () =>
                                    _launchUrl('tel:${hospital.phone.first}')
                                : null,
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
                  onLaunchUrl: _launchUrl,
                ),
                _ClinicsTab(
                  clinics: state.clinics,
                  baseUrl: baseUrl,
                  isLoading: state.status == HospitalDetailStatus.loading &&
                      state.clinics.isEmpty,
                  onRetry: () => context
                      .read<HospitalDetailCubit>()
                      .load(widget.hospitalId),
                ),
                _DoctorsTab(
                  doctors: state.doctors,
                  baseUrl: baseUrl,
                  isLoading: state.status == HospitalDetailStatus.loading &&
                      state.doctors.isEmpty,
                  onRetry: () => context
                      .read<HospitalDetailCubit>()
                      .load(widget.hospitalId),
                ),
                _OfferingsTab(
                  offerings: state.offerings,
                  baseUrl: baseUrl,
                  isLoading: state.status == HospitalDetailStatus.loading &&
                      state.offerings.isEmpty,
                  onRetry: () => context
                      .read<HospitalDetailCubit>()
                      .load(widget.hospitalId),
                ),
              ],
            ),
          ),
        );
      },
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
  final HospitalModel hospital;
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
          title: hospital.name,
          subtitle: facility,
          rating: hospital.rating,
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

class _DetailsTab extends StatelessWidget {
  final HospitalModel hospital;
  final int clinicsCount;
  final int doctorsCount;
  final int offeringsCount;

  const _DetailsTab({
    required this.hospital,
    required this.clinicsCount,
    required this.doctorsCount,
    required this.offeringsCount,
    required this.onLaunchUrl,
  });

  final void Function(String) onLaunchUrl;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final description = hospital.descriptionForLocale(locale);
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              HospitalDetailSectionCard(
                icon: Icons.info_rounded,
                title: 'hospitals.detail.about'.tr(),
                child: Text(
                  description.isNotEmpty
                      ? description
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
                      icon: Icons.star_rounded,
                      label: 'hospitals.detail.stats.rating'.tr(),
                      value: hospital.rating > 0
                          ? hospital.rating.toStringAsFixed(1)
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
                      title: 'address'.tr(),
                      value:
                          hospital.address.isNotEmpty ? hospital.address : null,
                      placeholderKey: 'hospitals.detail.no_description',
                    ),
                    if (hospital.socialMedia.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      HospitalInfoRow(
                        icon: Icons.group_rounded,
                        title: 'hospitals.detail.social_media'.tr(),
                        value: null,
                        placeholderKey: 'hospitals.detail.no_description',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: hospital.socialMedia
                            .map((link) => SocialMediaIcon(
                                  type: link.type,
                                  onTap: () => onLaunchUrl(link.link),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ClinicsTab extends StatelessWidget {
  final List<ClinicModel> clinics;
  final bool isLoading;
  final String baseUrl;
  final VoidCallback onRetry;

  const _ClinicsTab({
    required this.clinics,
    required this.baseUrl,
    required this.isLoading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && clinics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (clinics.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'hospitals.detail.clinics_empty'.tr(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text('services.offerings.retry'.tr()),
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
            child: _FiltersRow(),
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
                final clinic = clinics[index];
                final image = clinic.images.isNotEmpty
                    ? _resolveImage(clinic.images.first, baseUrl)
                    : null;
                final subtitle = clinic.description ??
                    'hospitals.detail.no_description'.tr();
                return InfoGridCard(
                  title: clinic.name,
                  subtitle: subtitle,
                  badgeLabel: 'hospitals.detail.tabs.clinics'.tr(),
                  priceLabel: null,
                  imageUrl: image,
                  buttonLabel: 'hospitals.detail.cta.view_clinic'.tr(),
                  onPressed: () {},
                );
              },
              childCount: clinics.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _DoctorsTab extends StatefulWidget {
  final List<DoctorModel> doctors;
  final bool isLoading;
  final String baseUrl;
  final VoidCallback onRetry;

  const _DoctorsTab({
    required this.doctors,
    required this.isLoading,
    required this.baseUrl,
    required this.onRetry,
  });

  @override
  State<_DoctorsTab> createState() => _DoctorsTabState();
}

class _DoctorsTabState extends State<_DoctorsTab> {
  String _query = '';

  List<DoctorModel> get _filteredDoctors {
    if (_query.trim().isEmpty) return widget.doctors;
    final lower = _query.toLowerCase();
    return widget.doctors
        .where((doctor) =>
            doctor.displayName.toLowerCase().contains(lower) ||
            doctor.specialty.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.doctors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.doctors.isEmpty) {
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
              onPressed: widget.onRetry,
              child: Text('services.offerings.retry'.tr()),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredDoctors;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              TextField(
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
              const SizedBox(height: 10),
              _FiltersRow(),
            ]),
          ),
        ),
        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text('hospitals.detail.doctors_empty'.tr()),
            ),
          )
        else
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
                  final avatar = doctor.avatarImage(baseUrl: widget.baseUrl) ??
                      doctor.coverImage(baseUrl: widget.baseUrl);
                  return DoctorGridCard(
                    title: doctor.displayName,
                    subtitle: doctor.specialty,
                    imageUrl: avatar,
                    rating: doctor.rating > 0 ? doctor.rating : null,
                    buttonLabel: 'hospitals.detail.cta.view_profile'.tr(),
                    isSaved: false,
                    onToggleSave: () {},
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DoctorDetailPage(doctorId: doctor.id),
                        ),
                      );
                    },
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
  final List<ServiceOfferingModel> offerings;
  final bool isLoading;
  final String baseUrl;
  final VoidCallback onRetry;

  const _OfferingsTab({
    required this.offerings,
    required this.baseUrl,
    required this.isLoading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    if (isLoading && offerings.isEmpty) {
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
            TextButton(
              onPressed: onRetry,
              child: Text('services.offerings.retry'.tr()),
            ),
          ],
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          sliver: SliverToBoxAdapter(child: _FiltersRow()),
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
                final serviceName = offering.service.nameForLocale(locale);
                final price = offering.price != null
                    ? 'services.offerings.price'.tr(namedArgs: {
                        'price': offering.price!.toStringAsFixed(2)
                      })
                    : '';
                final image = _resolveImage(offering.service.image, baseUrl);
                return ServiceOfferingCard(
                  title: serviceName,
                  subtitle: 'hospitals.detail.offerings_subtitle'.tr(),
                  badgeLabel: 'hospitals.detail.tabs.offerings'.tr(),
                  priceLabel: price,
                  imageUrl: image,
                  buttonLabel: 'hospitals.detail.cta.view_service'.tr(),
                  onTap: () {
                    final item =
                        _toSearchResult(offering, baseUrl, locale: locale);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ServiceOfferingDetailPage(
                          item: item,
                          baseUrl: baseUrl,
                          offeringId: offering.id,
                        ),
                      ),
                    );
                  },
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
            child: Text('services.offerings.retry'.tr()),
          ),
        ],
      ),
    );
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

SearchResultItem _toSearchResult(
  ServiceOfferingModel offering,
  String baseUrl, {
  required String locale,
}) {
  final serviceName = offering.service.nameForLocale(locale);
  final image = _resolveImage(offering.service.image, baseUrl);
  final avatar = _resolveImage(offering.provider.user.profilePicture, baseUrl);
  return SearchResultItem(
    id: offering.id,
    type: SearchResultType.serviceOffering,
    title: serviceName,
    subtitle: offering.provider.user.name,
    description: offering.provider.specialty,
    rating: offering.provider.rating,
    price: offering.price,
    imagePath: image,
    secondaryImagePath: avatar,
    location: const SearchLocation(),
    extra: {
      'service': {
        '_id': offering.service.id,
        'name_en': offering.service.nameEn,
        'name_fr': offering.service.nameFr,
        'name_ar': offering.service.nameAr,
        'name_sp': offering.service.nameSp,
        'image': offering.service.image,
      },
      'provider': {
        '_id': offering.provider.id,
        'user': {
          '_id': offering.provider.user.id,
          'name': offering.provider.user.name,
          'email': offering.provider.user.email,
          'profilePicture': offering.provider.user.profilePicture,
        },
        'specialty': offering.provider.specialty,
        'rating': offering.provider.rating,
      },
    },
  );
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
