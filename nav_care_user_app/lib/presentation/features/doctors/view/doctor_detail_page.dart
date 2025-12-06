import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/doctors/doctors_repository.dart';
import 'package:nav_care_user_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_user_app/presentation/features/doctors/view/doctor_add_review_page.dart';
import 'package:nav_care_user_app/presentation/features/doctors/view/doctor_review_detail_page.dart';
import 'package:nav_care_user_app/presentation/features/doctors/view/widgets/doctor_reviews_section.dart';
import 'package:nav_care_user_app/presentation/features/doctors/viewmodel/doctor_reviews_cubit.dart';
import 'package:nav_care_user_app/presentation/features/doctors/viewmodel/doctor_reviews_state.dart';
import 'widgets/doctor_service_offerings_section.dart';

class DoctorDetailPage extends StatefulWidget {
  final String doctorId;
  final DoctorModel? initial;

  const DoctorDetailPage({super.key, required this.doctorId, this.initial});

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}


class _DoctorDetailPageState extends State<DoctorDetailPage> {
  late Future<DoctorModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DoctorModel> _load() async {
    if (widget.initial != null) return widget.initial!;
    return sl<DoctorsRepository>().getDoctorById(widget.doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<DoctorReviewsCubit>()..loadReviews(doctorId: widget.doctorId),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _future = _load();
            });
            await _future;
            context.read<DoctorReviewsCubit>().refresh();
          },
          child: FutureBuilder<DoctorModel>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return _ErrorView(
                  message: 'home.featured_doctors.error'.tr(),
                  onRetry: () => setState(() {
                    _future = _load();
                  }),
                );
              }

              final doctor = snapshot.data!;
              final locale = context.locale.languageCode;
              final bio = doctor.bioForLocale(locale);
              final baseUrl = sl<AppConfig>().api.baseUrl;
              final avatar = doctor.avatarImage(baseUrl: baseUrl) ??
                  doctor.coverImage(baseUrl: baseUrl);
              final cover = avatar ?? doctor.coverImage(baseUrl: baseUrl);
              final reviewsState = context.watch<DoctorReviewsCubit>().state;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    title: Text(doctor.displayName,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
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
                            icon: Icons.contact_mail_rounded,
                            title: 'contact.title'.tr(),
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
                          const SizedBox(height: 12),
                          _Section(
                              icon: Icons.rate_review_rounded,
                              title: 'doctors.reviews.title'.tr(),
                              child: DoctorReviewsSection(
                                reviews: reviewsState.reviews,
                                status: reviewsState.status,
                                message: reviewsState.message,
                                hasMore: reviewsState.hasMore,
                                isLoadingMore: reviewsState.isLoadingMore,
                                baseUrl: baseUrl,
                              onTap: (review) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DoctorReviewDetailPage(
                                      review: review,
                                    ),
                                  ),
                                );
                              },
                              onRetry: () => context
                                  .read<DoctorReviewsCubit>()
                                  .loadReviews(doctorId: widget.doctorId),
                              onLoadMore: () =>
                                  context.read<DoctorReviewsCubit>().loadMore(),
                              onAddReview: () async {
                                final result =
                                    await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<DoctorReviewsCubit>(),
                                      child: const DoctorAddReviewPage(),
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    _future = _load();
                                  });
                                  context.read<DoctorReviewsCubit>().refresh();
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          DoctorServiceOfferingsSection(providerId: doctor.id),
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
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceVariant,
                    alignment: Alignment.center,
                    child: const Icon(Icons.person_rounded, size: 48),
                  ),
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
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.surfaceVariant,
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage(avatarUrl!)
                    : null,
                onBackgroundImageError: (_, __) {},
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? const Icon(Icons.person_rounded, size: 30)
                    : null,
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
                        const SizedBox(width: 10),
                        Text(
                          '${doctor.rating} ${'reviews'.tr()}',
                          style: theme.textTheme.bodySmall,
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
            color: Colors.black.withOpacity(0.04),
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
          const SizedBox(height: 10),
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
            label,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
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
      ),
    );
  }
}
