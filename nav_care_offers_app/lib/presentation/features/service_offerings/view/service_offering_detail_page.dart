import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offering_detail_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offering_reviews_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offering_reviews_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/service_offering_review_card.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offerings_cubit.dart';
import 'package:nav_care_offers_app/data/service_offerings/service_offerings_repository.dart';
import 'package:nav_care_offers_app/data/reviews/service_offering_reviews/service_offering_reviews_repository.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/view/service_offering_form_page.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/network_image.dart';

class ServiceOfferingDetailPage extends StatelessWidget {
  const ServiceOfferingDetailPage({
    super.key,
    required this.offeringId,
    this.initial,
    this.hospitalId,
    this.useHospitalToken = true,
    this.allowDelete = false,
  });

  final String offeringId;
  final ServiceOffering? initial;
  final String? hospitalId;
  final bool useHospitalToken;
  final bool allowDelete;

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ServiceOfferingDetailCubit(
            sl<ServiceOfferingsRepository>(),
            offeringId: offeringId,
            initial: initial,
            useHospitalToken: useHospitalToken,
          )..refresh(),
        ),
        BlocProvider(
          create: (_) => ServiceOfferingReviewsCubit(
            repository: sl<ServiceOfferingReviewsRepository>(),
          )..loadReviews(offeringId: offeringId),
        ),
      ],
      child: _DetailView(
        baseUrl: baseUrl,
        hospitalId: hospitalId,
        allowDelete: allowDelete,
        useHospitalToken: useHospitalToken,
      ),
    );
  }
}

class _DetailView extends StatefulWidget {
  const _DetailView({
    required this.baseUrl,
    required this.hospitalId,
    required this.allowDelete,
    required this.useHospitalToken,
  });

  final String baseUrl;
  final String? hospitalId;
  final bool allowDelete;
  final bool useHospitalToken;

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  bool _isDescriptionExpanded = false;

  String? _resolvePath(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    try {
      return Uri.parse(widget.baseUrl).resolve(path).toString();
    } catch (_) {
      return path;
    }
  }

  String _localizedDescription(ServiceOffering offering, String locale) {
    final candidates = <String?>[];
    switch (locale) {
      case 'ar':
        candidates.addAll([
          offering.descriptionAr,
          offering.descriptionEn,
          offering.descriptionFr,
          offering.descriptionSp,
        ]);
        break;
      case 'fr':
        candidates.addAll([
          offering.descriptionFr,
          offering.descriptionEn,
          offering.descriptionAr,
          offering.descriptionSp,
        ]);
        break;
      case 'sp':
      case 'es':
        candidates.addAll([
          offering.descriptionSp,
          offering.descriptionEn,
          offering.descriptionFr,
          offering.descriptionAr,
        ]);
        break;
      default:
        candidates.addAll([
          offering.descriptionEn,
          offering.descriptionFr,
          offering.descriptionAr,
          offering.descriptionSp,
        ]);
        break;
    }
    return candidates.firstWhere(
      (value) => value != null && value.trim().isNotEmpty,
      orElse: () => '',
    )!;
  }

  String _providerDescription(ServiceOffering offering, String locale) {
    final candidates = <String?>[];
    switch (locale) {
      case 'ar':
        candidates.addAll([
          offering.provider.bioAr,
          offering.provider.bioEn,
          offering.provider.bioFr,
          offering.provider.bioSp
        ]);
        break;
      case 'fr':
        candidates.addAll([
          offering.provider.bioFr,
          offering.provider.bioEn,
          offering.provider.bioAr,
          offering.provider.bioSp
        ]);
        break;
      case 'sp':
      case 'es':
        candidates.addAll([
          offering.provider.bioSp,
          offering.provider.bioEn,
          offering.provider.bioFr,
          offering.provider.bioAr
        ]);
        break;
      default:
        candidates.addAll([
          offering.provider.bioEn,
          offering.provider.bioFr,
          offering.provider.bioAr,
          offering.provider.bioSp
        ]);
        break;
    }
    return candidates.firstWhere(
      (value) => value != null && value.trim().isNotEmpty,
      orElse: () => '',
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceOfferingDetailCubit, ServiceOfferingDetailState>(
      listenWhen: (prev, curr) =>
          prev.failure != curr.failure ||
          prev.offering != curr.offering ||
          prev.isDeleted != curr.isDeleted,
      listener: (context, state) {
        if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.failure!.message ?? 'unknown_error'.tr(),
              ),
            ),
          );
        }
        if (state.offering != null) {
          _maybeOfferingsCubit(context)?.updateOffering(state.offering!);
        }
        if (state.isDeleted) {
          Navigator.of(context).pop('deleted');
        }
      },
      child:
          BlocBuilder<ServiceOfferingDetailCubit, ServiceOfferingDetailState>(
        builder: (context, state) {
          final offering = state.offering;
          if (offering == null && state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (offering == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text('service_offerings.detail.title'.tr()),
              ),
              body: Center(
                child: Text(
                  state.failure?.message ??
                      'service_offerings.detail.not_found'.tr(),
                ),
              ),
            );
          }

          final locale = context.locale.languageCode;
          final coverImage = offering.images.isNotEmpty
              ? _resolvePath(offering.images.first)
              : _resolvePath(offering.service.image);
          final providerAvatar = _resolvePath(
            offering.provider.profilePicture ??
                offering.provider.user.profilePicture ??
                offering.provider.cover,
          );
          final providerName = offering.provider.user.name;
          final providerSpecialty =
              offering.provider.specialty ?? offering.providerType;
          final providerDescription = _providerDescription(offering, locale);
          final providerRating = offering.provider.rating ?? 0;
          final serviceTitle = offering.localizedName(locale);
          final price = offering.price;
          final rating = offering.provider.rating ?? 0;
          final description = _localizedDescription(offering, locale);
          final hasDescription = description.trim().isNotEmpty;

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            body: Column(
              children: [
                _TopPreview(
                  imageUrl: coverImage,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceTitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 10),
                        BlocBuilder<ServiceOfferingReviewsCubit,
                            ServiceOfferingReviewsState>(
                          builder: (context, reviewsState) {
                            final reviewsCount =
                                reviewsState.pagination?.total ??
                                    reviewsState.reviews.length;
                            return Row(
                              children: [
                                _RatingStars(rating: rating),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${reviewsCount} ${'reviews'.tr()})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.6),
                                      ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _SolidActionButton(
                                label: 'service_offerings.detail.edit'.tr(),
                                icon: Icons.edit_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () => _openEdit(
                                  context,
                                  widget.hospitalId,
                                  offering,
                                ),
                              ),
                            ),
                            if (widget.allowDelete) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SolidActionButton(
                                  label:
                                      'service_offerings.detail.delete'.tr(),
                                  icon: Icons.delete_outline_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                  onPressed: state.isDeleting
                                      ? null
                                      : () => _confirmDelete(context),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 22),
                        _ProviderHighlight(
                          avatar: providerAvatar,
                          name: providerName,
                          specialty: providerSpecialty,
                          description: providerDescription,
                          rating: providerRating,
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Icon(Icons.price_change_outlined,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'service_offerings.detail.price'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              price > 0
                                  ? '\$${price.toStringAsFixed(2)}'
                                  : '--',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (hasDescription) ...[
                          Text(
                            'services.detail.description'.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            description,
                            maxLines: _isDescriptionExpanded ? null : 5,
                            overflow: _isDescriptionExpanded
                                ? TextOverflow.visible
                                : TextOverflow.fade,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  height: 1.35,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.8),
                                ),
                          ),
                          if (!_isDescriptionExpanded &&
                              description.length > 160)
                            TextButton.icon(
                              onPressed: () =>
                                  setState(() => _isDescriptionExpanded = true),
                              icon: const Icon(
                                  Icons.keyboard_arrow_right_rounded),
                              label: Text('services.detail.read_more'.tr()),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        ],
                        const SizedBox(height: 24),
                        _ServiceOfferingReviewsSection(
                          offeringId: state.offeringId,
                          baseUrl: widget.baseUrl,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ServiceOfferingsCubit? _maybeOfferingsCubit(BuildContext context) {
    try {
      return context.read<ServiceOfferingsCubit>();
    } catch (_) {
      return null;
    }
  }

  void _openEdit(
    BuildContext context,
    String? hospitalId,
    ServiceOffering offering,
  ) {
    Future<ServiceOffering?> openEditor() {
      if (hospitalId != null && hospitalId.isNotEmpty) {
        final route =
            '/hospitals/$hospitalId/service-offerings/${offering.id}/edit';
        return context.push(route, extra: offering).then((value) {
          return value is ServiceOffering ? value : null;
        });
      }
      return Navigator.of(context).push<ServiceOffering>(
        MaterialPageRoute(
          builder: (_) => ServiceOfferingFormPage(
            hospitalId: '',
            initial: offering,
            useHospitalToken: widget.useHospitalToken,
          ),
        ),
      );
    }

    openEditor().then((value) {
      if (value is ServiceOffering) {
        context.read<ServiceOfferingDetailCubit>().replace(value);
        _maybeOfferingsCubit(context)?.updateOffering(value);
        context.pop(value);
      }
    });
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('service_offerings.detail.delete_title'.tr()),
        content: Text('service_offerings.detail.delete_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      context.read<ServiceOfferingDetailCubit>().deleteOffering();
    }
  }
}

class _TopPreview extends StatelessWidget {
  const _TopPreview({
    required this.imageUrl,
    required this.onBack,
  });

  final String? imageUrl;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor),
                ),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? NetworkImageWrapper(
                          imageUrl: imageUrl,
                          fit: BoxFit.fill,
                          fallback: Icon(
                            PhosphorIconsBold.stethoscope,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                          shimmerChild: Container(
                              color: theme.colorScheme.surfaceVariant),
                        )
                      : Icon(
                          PhosphorIconsBold.stethoscope,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderHighlight extends StatelessWidget {
  const _ProviderHighlight({
    required this.avatar,
    required this.name,
    required this.specialty,
    required this.description,
    required this.rating,
  });

  final String? avatar;
  final String name;
  final String specialty;
  final String description;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
          ),
          child: (avatar == null || avatar!.isEmpty)
              ? Icon(Icons.person_rounded,
                  color: theme.colorScheme.onSurface, size: 32)
              : ClipOval(
                  child: NetworkImageWrapper(
                    imageUrl: avatar,
                    fit: BoxFit.cover,
                    fallback: Icon(
                      Icons.person_rounded,
                      color: theme.colorScheme.onSurface,
                      size: 32,
                    ),
                    shimmerChild:
                        Container(color: theme.colorScheme.surfaceVariant),
                  ),
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (rating > 0) ...[
                    const Icon(Icons.star_rounded,
                        size: 16, color: Color(0xFFFFC107)),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (description.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFFFC107);

    Icon _iconForIndex(int index) {
      final position = index + 1;
      if (rating >= position - 0.25) {
        return const Icon(Icons.star_rounded, size: 18, color: color);
      }
      if (rating >= position - 0.75) {
        return const Icon(Icons.star_half_rounded, size: 18, color: color);
      }
      return const Icon(Icons.star_border_rounded, size: 18, color: color);
    }

    return Row(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 4),
          child: _iconForIndex(index),
        ),
      ),
    );
  }
}

class _ServiceOfferingReviewsSection extends StatefulWidget {
  const _ServiceOfferingReviewsSection({
    required this.offeringId,
    required this.baseUrl,
  });

  final String offeringId;
  final String baseUrl;

  @override
  State<_ServiceOfferingReviewsSection> createState() =>
      _ServiceOfferingReviewsSectionState();
}

class _ServiceOfferingReviewsSectionState
    extends State<_ServiceOfferingReviewsSection> {
  static const int _initialVisible = 3;
  bool _showAll = false;

  @override
  void didUpdateWidget(covariant _ServiceOfferingReviewsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_showAll &&
        context.read<ServiceOfferingReviewsCubit>().state.reviews.length <=
            _initialVisible) {
      _showAll = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'service_offerings.reviews.title'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<ServiceOfferingReviewsCubit, ServiceOfferingReviewsState>(
          builder: (context, state) {
            if (state.status == ServiceOfferingReviewsStatus.loading &&
                state.reviews.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == ServiceOfferingReviewsStatus.failure &&
                state.reviews.isEmpty) {
              final errorText =
                  (state.message ?? 'service_offerings.reviews.error').tr();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errorText,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => context
                        .read<ServiceOfferingReviewsCubit>()
                        .loadReviews(offeringId: widget.offeringId),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text('service_offerings.reviews.retry'.tr()),
                  ),
                ],
              );
            }

            if (state.reviews.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'service_offerings.reviews.empty'.tr(),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => context
                        .read<ServiceOfferingReviewsCubit>()
                        .loadReviews(offeringId: widget.offeringId),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text('service_offerings.reviews.retry'.tr()),
                  ),
                ],
              );
            }

            final visibleReviews = _showAll
                ? state.reviews
                : state.reviews.take(_initialVisible).toList();
            final canShowLess =
                _showAll && state.reviews.length > _initialVisible;
            final canShowMore =
                (!_showAll && state.reviews.length > _initialVisible) ||
                    state.hasMore;

            return Column(
              children: [
                ...visibleReviews
                    .map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ServiceOfferingReviewCard(
                          review: review,
                          baseUrl: widget.baseUrl,
                        ),
                      ),
                    )
                    .toList(),
                if (canShowMore || state.isLoadingMore) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: state.isLoadingMore
                          ? null
                          : () {
                              setState(() => _showAll = true);
                              if (state.hasMore) {
                                context
                                    .read<ServiceOfferingReviewsCubit>()
                                    .loadMore();
                              }
                            },
                      icon: state.isLoadingMore
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.expand_more_rounded),
                      label: Text('service_offerings.reviews.load_more'.tr()),
                    ),
                  ),
                ],
                if (canShowLess) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _showAll = false),
                      icon: const Icon(Icons.expand_less_rounded),
                      label: Text('service_offerings.reviews.show_less'.tr()),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: onRetry,
              child: Text('service_offerings.reviews.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolidActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _SolidActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
