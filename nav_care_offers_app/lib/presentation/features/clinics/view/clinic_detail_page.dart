import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/reviews/hospital_reviews/models/hospital_review_model.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/viewmodel/clinic_detail_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_reviews_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_reviews_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/hospital_detail_cards.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/hospital_review_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/hospital_detail_components.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/network_image.dart';

/// Compact view that shows only the details tab content (no AppBar/TabBar).
class ClinicDetailsSummaryView extends StatelessWidget {
  final Hospital hospital;
  final int doctorsCount;
  final int offeringsCount;
  final String baseUrl;
  final HospitalReviewsState reviewsState;
  final bool isReviewsLoadingMore;
  final VoidCallback onReviewsReload;
  final VoidCallback onManageDoctors;
  final VoidCallback onManageOfferings;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isDeleting;
  final ClinicDetailStatus status;
  final String? errorMessage;

  const ClinicDetailsSummaryView({
    super.key,
    required this.hospital,
    required this.doctorsCount,
    required this.offeringsCount,
    required this.baseUrl,
    required this.reviewsState,
    required this.isReviewsLoadingMore,
    required this.onReviewsReload,
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
    final facility =
        hospital.facilityType.translationKey('clinics.facility_type').tr();
    final cover = hospital.images.isNotEmpty
        ? _resolveImage(hospital.images.first, baseUrl)
        : null;

    return CustomScrollView(
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
                height: 300,
                child: Transform.translate(
                  offset: const Offset(0, -72),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _HeroForegroundLayer(
                      hospital: hospital,
                      facility: facility,
                      imageUrl: cover,
                      doctorsCount: doctorsCount,
                      offeringsCount: offeringsCount,
                      primaryActionLabel: 'clinics.detail.edit'.tr(),
                      secondaryActionLabel: isDeleting
                          ? 'clinics.detail.deleting'.tr()
                          : 'clinics.detail.delete'.tr(),
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
          doctorsCount: doctorsCount,
          offeringsCount: offeringsCount,
          baseUrl: baseUrl,
          reviewsState: reviewsState,
          isReviewsLoadingMore: isReviewsLoadingMore,
          onReviewsReload: onReviewsReload,
          onManageDoctors: onManageDoctors,
          onManageOfferings: onManageOfferings,
          onEdit: onEdit,
          onDelete: onDelete,
          isDeleting: isDeleting,
          status: status,
          errorMessage: errorMessage,
        ),
      ],
    );
  }
}

List<Widget> _buildDetailsSlivers({
  required BuildContext context,
  required Hospital hospital,
  required int doctorsCount,
  required int offeringsCount,
  required String baseUrl,
  required HospitalReviewsState reviewsState,
  required bool isReviewsLoadingMore,
  required VoidCallback onReviewsReload,
  required VoidCallback onManageDoctors,
  required VoidCallback onManageOfferings,
  required VoidCallback onEdit,
  required VoidCallback? onDelete,
  required bool isDeleting,
  required ClinicDetailStatus status,
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
          if (status == ClinicDetailStatus.failure &&
              (errorMessage ?? '').isNotEmpty) ...[
            _ErrorView(
              message: errorMessage ?? 'clinics.list.error_generic'.tr(),
              onRetry: () => context.read<ClinicDetailCubit>().loadDetails(),
            ),
            const SizedBox(height: 16),
          ],
          HospitalDetailSectionCard(
            icon: Icons.info_rounded,
            title: 'clinics.detail.about'.tr(),
            child: Text(
              description?.isNotEmpty == true
                  ? description!
                  : 'clinics.detail.no_description'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          HospitalDetailSectionCard(
            icon: Icons.auto_awesome_mosaic_rounded,
            title: 'clinics.detail.overview'.tr(),
            spacing: 10,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                HospitalStatCard(
                  icon: Icons.people_alt_rounded,
                  label: 'clinics.detail.stats.doctors'.tr(),
                  value: doctorsCount.toString(),
                ),
                HospitalStatCard(
                  icon: Icons.medical_services_rounded,
                  label: 'clinics.detail.stats.offerings'.tr(),
                  value: offeringsCount.toString(),
                ),
                HospitalStatCard(
                  icon: Icons.local_phone_rounded,
                  label: 'clinics.detail.phone'.tr(),
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
            title: 'clinics.detail.contact'.tr(),
            spacing: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HospitalInfoRow(
                  icon: Icons.place_rounded,
                  title: 'clinics.form.address'.tr(),
                  value: hospital.address,
                  placeholderKey: 'clinics.detail.no_description',
                ),
                const SizedBox(height: 10),
                HospitalInfoRow(
                  icon: Icons.group_rounded,
                  title: 'clinics.detail.facility_type'.tr(),
                  value: hospital.facilityType
                      .translationKey('clinics.facility_type')
                      .tr(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          HospitalDetailSectionCard(
            icon: Icons.manage_accounts_rounded,
            title: 'clinics.actions.manage'.tr(),
            child: Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onManageDoctors,
                  icon: const Icon(Icons.people_alt_rounded),
                  label: Text('clinics.detail.tabs.doctors'.tr()),
                ),
                OutlinedButton.icon(
                  onPressed: onManageOfferings,
                  icon: const Icon(Icons.medical_services_rounded),
                  label: Text('clinics.detail.tabs.offerings'.tr()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ClinicReviewsSection(
            reviews: reviewsState.reviews,
            status: reviewsState.status,
            isLoadingMore: isReviewsLoadingMore,
            baseUrl: baseUrl,
            onReload: onReviewsReload,
            onLoadMore: () => context.read<HospitalReviewsCubit>().loadMore(),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    ),
  ];
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
            child: Text('clinics.actions.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _ClinicReviewsSection extends StatefulWidget {
  final List<HospitalReviewModel> reviews;
  final HospitalReviewsStatus status;
  final String baseUrl;
  final VoidCallback onReload;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;

  const _ClinicReviewsSection({
    required this.reviews,
    required this.status,
    required this.baseUrl,
    required this.onReload,
    required this.onLoadMore,
    required this.isLoadingMore,
  });

  @override
  State<_ClinicReviewsSection> createState() => _ClinicReviewsSectionState();
}

class _ClinicReviewsSectionState extends State<_ClinicReviewsSection> {
  static const int _initialVisible = 3;
  bool _showAll = false;

  @override
  void didUpdateWidget(covariant _ClinicReviewsSection oldWidget) {
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

class _HeroBackdropLayer extends StatelessWidget {
  final String? imageUrl;

  const _HeroBackdropLayer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
      );
    }
    return NetworkImageWrapper(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      fallback: Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
    );
  }
}

class _HeroForegroundLayer extends StatelessWidget {
  final Hospital hospital;
  final String facility;
  final String? imageUrl;
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
          rating: hospital.rating ?? 0,
          imageUrl: imageUrl,
          stats: [
            HospitalOverviewStat(
              label: 'clinics.detail.stats.doctors'.tr(),
              value: doctorsCount.toString(),
            ),
            HospitalOverviewStat(
              label: 'clinics.detail.stats.offerings'.tr(),
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
