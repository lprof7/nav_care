import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/doctors/doctors_repository.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/invitations/hospital_invitations_repository.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';
import 'package:nav_care_offers_app/data/reviews/doctor_reviews/models/doctor_review_model.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/viewmodel/doctor_reviews_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/viewmodel/doctor_reviews_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/doctor_review_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/network_image.dart';

class DoctorDetailPage extends StatefulWidget {
  final String doctorId;
  final DoctorModel? initial;
  final String? hospitalId;
  final List<DoctorModel>? hospitalDoctors;
  final List<HospitalInvitation>? invitations;

  const DoctorDetailPage({
    super.key,
    required this.doctorId,
    this.initial,
    this.hospitalId,
    this.hospitalDoctors,
    this.invitations,
  });

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  late Future<DoctorModel> _future;
  bool _isSendingInvitation = false;
  bool _hasSentInvitation = false;
  bool _isCancellingInvitation = false;
  HospitalInvitation? _localInvitation;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DoctorModel> _load() async {
    if (widget.initial != null) return widget.initial!;
    final result = await sl<DoctorsRepository>().getDoctorById(widget.doctorId);
    return result.fold(
      onFailure: (failure) => throw Exception(failure.message),
      onSuccess: (doctor) => doctor,
    );
  }

  Future<void> _sendInvitation(
    BuildContext context,
    DoctorModel doctor,
  ) async {
    if (_isSendingInvitation) return;
    setState(() => _isSendingInvitation = true);

    final result = await sl<HospitalInvitationsRepository>().createInvitation(
      doctorId: doctor.id,
      purpose: 'doctor',
    );

    if (!mounted) return;

    result.fold(
      onFailure: (failure) {
        setState(() => _isSendingInvitation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      onSuccess: (invitation) {
        setState(() {
          _isSendingInvitation = false;
          _hasSentInvitation = true;
          _localInvitation = invitation;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم ارسال طلب انضمام')),
        );
      },
    );
  }

  Future<void> _cancelInvitation(
    BuildContext context,
    HospitalInvitation invitation,
  ) async {
    if (_isCancellingInvitation) return;
    setState(() => _isCancellingInvitation = true);

    final result = await sl<HospitalInvitationsRepository>()
        .cancelInvitation(invitationId: invitation.id);

    if (!mounted) return;

    result.fold(
      onFailure: (failure) {
        setState(() => _isCancellingInvitation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      onSuccess: (updated) {
        setState(() {
          _isCancellingInvitation = false;
          _hasSentInvitation = false;
          _localInvitation = updated;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الغاء الدعوة')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    return BlocProvider(
      create: (_) =>
          sl<DoctorReviewsCubit>()..loadReviews(doctorId: widget.doctorId),
      child: Builder(
        builder: (innerContext) => Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = _load();
              });
              await _future;
              innerContext.read<DoctorReviewsCubit>().refresh();
            },
            child: FutureBuilder<DoctorModel>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return _ErrorView(
                    message: 'hospitals.detail.doctors_empty'.tr(),
                    onRetry: () => setState(() {
                      _future = _load();
                    }),
                  );
                }

                final doctor = snapshot.data!;
                final reviewsState =
                    innerContext.watch<DoctorReviewsCubit>().state;
                final locale = context.locale.languageCode;
                final bio = doctor.bioForLocale(locale);
                final avatar = doctor.avatarImage(baseUrl: baseUrl) ??
                    doctor.coverImage(baseUrl: baseUrl);
                final cover = avatar ?? doctor.coverImage(baseUrl: baseUrl);
                final isMember = (widget.hospitalDoctors ?? [])
                    .any((d) => d.id == doctor.id || d.userId == doctor.userId);
                HospitalInvitation? invitation = _localInvitation;
                if (invitation == null) {
                  for (final inv in widget.invitations ?? []) {
                    if (inv.inviteeDoctor?.id == doctor.id) {
                      invitation = inv;
                      break;
                    }
                  }
                }
                final bool hasInvitationAlready = _hasSentInvitation ||
                    (invitation != null &&
                        invitation.status != 'rejected' &&
                        invitation.status != 'cancelled');
                final bool canSendInvitation =
                    !isMember && !_isSendingInvitation && !hasInvitationAlready;
                final bool canCancelInvitation = invitation != null &&
                    invitation.status == 'pending' &&
                    !_isCancellingInvitation;

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.of(innerContext).maybePop(),
                      ),
                      title: Text(
                        doctor.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _HeroImage(imageUrl: cover),
                          _SummaryCard(
                            doctor: doctor,
                            avatarUrl: avatar,
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            if (widget.hospitalId != null && !isMember)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: FilledButton(
                                  onPressed: canSendInvitation
                                      ? () =>
                                          _sendInvitation(innerContext, doctor)
                                      : null,
                                  child: _isSendingInvitation
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'hospitals.detail.invitation_send'
                                                  .tr(),
                                            ),
                                          ],
                                        )
                                      : Text(canSendInvitation
                                          ? 'hospitals.detail.invitation_send'
                                              .tr()
                                          : 'تم ارسال طلب انضمام'),
                                ),
                              ),
                            if (widget.hospitalId != null &&
                                !isMember &&
                                canCancelInvitation)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: OutlinedButton(
                                  onPressed: () => _cancelInvitation(
                                      innerContext, invitation!),
                                  child: _isCancellingInvitation
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text('الغاء الدعوة'),
                                          ],
                                        )
                                      : const Text('الغاء الدعوة'),
                                ),
                              ),
                            _Section(
                              icon: Icons.info_rounded,
                              title: 'hospitals.detail.about'.tr(),
                              child: Text(
                                bio.isNotEmpty
                                    ? bio
                                    : 'hospitals.detail.no_description'.tr(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _Section(
                              icon: Icons.contact_phone_rounded,
                              title: 'hospitals.detail.contact'.tr(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoRow(
                                    icon: Icons.email_rounded,
                                    label: doctor.email ?? '--',
                                  ),
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.phone_rounded,
                                    label: doctor.phone ?? '--',
                                  ),
                                ],
                              ),
                            ),
                            if (doctor.affiliations.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _Section(
                                icon: Icons.business_center_rounded,
                                title: 'hospitals.detail.stats.clinics'.tr(),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: doctor.affiliations
                                      .map(
                                        (aff) => Chip(
                                          label: Text(aff),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            DoctorReviewsSection(
                              reviews: reviewsState.reviews,
                              status: reviewsState.status,
                              baseUrl: baseUrl,
                              isLoadingMore: reviewsState.isLoadingMore,
                              onReload: () => innerContext
                                  .read<DoctorReviewsCubit>()
                                  .refresh(),
                              onLoadMore: () => innerContext
                                  .read<DoctorReviewsCubit>()
                                  .loadMore(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String? imageUrl;
  const _HeroImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImageWrapper(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  fallback: Container(
                    color: theme.colorScheme.surfaceVariant,
                    alignment: Alignment.center,
                    child: const Icon(Icons.person_rounded, size: 48),
                  ),
                  shimmerChild:
                      Container(color: theme.colorScheme.surfaceVariant),
                )
              : Container(
                  color: theme.colorScheme.surfaceVariant,
                  alignment: Alignment.center,
                  child: const Icon(Icons.person_rounded, size: 48),
                ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final DoctorModel doctor;
  final String? avatarUrl;

  const _SummaryCard({
    required this.doctor,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceVariant,
                ),
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? const Icon(Icons.person_rounded, size: 30)
                    : ClipOval(
                        child: NetworkImageWrapper(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                          fallback: const Icon(Icons.person_rounded, size: 30),
                          shimmerChild: Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating > 0
                              ? doctor.rating.toStringAsFixed(1)
                              : '--',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label.isNotEmpty ? label : '--',
            style: theme.textTheme.bodyMedium,
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
          const Icon(Icons.error_outline_rounded, size: 46, color: Colors.red),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('service_offerings.list.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class DoctorReviewsSection extends StatefulWidget {
  final List<DoctorReviewModel> reviews;
  final DoctorReviewsStatus status;
  final String baseUrl;
  final VoidCallback onReload;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;

  const DoctorReviewsSection({
    super.key,
    required this.reviews,
    required this.status,
    required this.baseUrl,
    required this.onReload,
    required this.onLoadMore,
    required this.isLoadingMore,
  });

  @override
  State<DoctorReviewsSection> createState() => _DoctorReviewsSectionState();
}

class _DoctorReviewsSectionState extends State<DoctorReviewsSection> {
  static const int _initialVisible = 3;
  bool _showAll = false;

  @override
  void didUpdateWidget(covariant DoctorReviewsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_showAll && widget.reviews.length <= _initialVisible) {
      _showAll = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.status == DoctorReviewsStatus.loading &&
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

    if (widget.status == DoctorReviewsStatus.failure &&
        widget.reviews.isEmpty) {
      final errorText = (context.read<DoctorReviewsCubit>().state.message ??
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
                child: DoctorReviewCard(
                  review: review,
                  baseUrl: widget.baseUrl,
                ),
              ),
            )
            .toList(),
        if (canShowMore ||
            (widget.status == DoctorReviewsStatus.loading &&
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
