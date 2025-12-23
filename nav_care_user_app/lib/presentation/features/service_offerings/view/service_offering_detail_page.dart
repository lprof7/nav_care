import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';
import 'package:nav_care_user_app/presentation/features/authentication/session/auth_session_cubit.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/view/service_offering_add_review_page.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/viewmodel/service_offering_detail_cubit.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/viewmodel/service_offering_detail_state.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/viewmodel/service_offering_reviews_cubit.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/viewmodel/service_offering_reviews_state.dart';
import 'package:nav_care_user_app/presentation/shared/ui/molecules/sign_in_required_card.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/service_offering_card.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/service_offering_review_card.dart';

class ServiceOfferingDetailPage extends StatelessWidget {
  const ServiceOfferingDetailPage({
    super.key,
    required this.item,
    required this.baseUrl,
    this.offeringId,
  });

  final SearchResultItem item;
  final String baseUrl;
  final String? offeringId;

  @override
  Widget build(BuildContext context) {
    final resolvedId = offeringId ?? item.id;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ServiceOfferingDetailCubit>()..load(resolvedId),
        ),
        BlocProvider(
          create: (_) => sl<ServiceOfferingReviewsCubit>()
            ..loadReviews(offeringId: resolvedId),
        ),
      ],
      child: _DetailView(
        item: item,
        baseUrl: baseUrl,
        offeringId: resolvedId,
      ),
    );
  }
}

class _DetailView extends StatefulWidget {
  const _DetailView({
    required this.item,
    required this.baseUrl,
    required this.offeringId,
  });

  final SearchResultItem item;
  final String baseUrl;
  final String offeringId;

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  bool _isDescriptionExpanded = false;
  bool _isFavorite = false;

  String? _resolvePath(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    try {
      return Uri.parse(widget.baseUrl).resolve(path).toString();
    } catch (_) {
      return path;
    }
  }

  String _fallbackDescription(String locale, ServiceOfferingModel? offering) {
    String? description;
    switch (locale) {
      case 'ar':
        description = offering?.descriptionAr;
        break;
      case 'fr':
        description = offering?.descriptionFr;
        break;
      case 'sp':
      case 'es':
        description = offering?.descriptionSp;
        break;
      default:
        description = offering?.descriptionEn;
        break;
    }
    return description?.isNotEmpty == true
        ? description!
        : widget.item.description.isNotEmpty
            ? widget.item.description
            : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ServiceOfferingDetailCubit, ServiceOfferingDetailState>(
        builder: (context, state) {
          final isLoading =
              state.status == ServiceOfferingDetailStatus.loading &&
                  state.offering == null;
          final isFailure = state.status == ServiceOfferingDetailStatus.failure;
          final offering = state.offering;
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (isFailure && offering == null) {
            final message = state.message ?? 'services.offerings.error'.tr();
            return _ErrorView(
              message: message,
              onRetry: () => context
                  .read<ServiceOfferingDetailCubit>()
                  .load(widget.offeringId),
            );
          }

          if (offering == null) {
            // This case should ideally not be reached if loading and failure are handled.
            return const Center(child: Text("Service offering not available."));
          }
          final locale = context.locale.languageCode;
          final coverImage = offering.images.isNotEmpty
              ? _resolvePath(offering.images.first)
              : _resolvePath(offering.service.image);
          final providerAvatar = _resolvePath(
            offering.provider.profilePicture ?? offering.provider.cover,
          );
          final providerName = offering.provider.name;
          final providerSpecialty = offering.provider.specialty.isNotEmpty
              ? offering.provider.specialty
              : offering.providerType;
          final providerDescription =
              offering.provider.descriptionForLocale(locale);
          final providerRating = offering.provider.rating;
          final providerReviews = offering.provider.reviewsCount;
          final serviceTitle = offering.nameForLocale(locale);

          final price = offering.price;
          final rating = offering.provider.rating ?? 0;
          final reviewsCount = offering.provider.reviewsCount;
          final description =
              _fallbackDescription(context.locale.languageCode, offering);

          final hasDescription = description.trim().isNotEmpty;

          return Column(
            children: [
              _TopPreview(
                imageUrl: coverImage,
                onBack: () => Navigator.of(context).maybePop(),
                isFavorite: _isFavorite,
                onToggleFavorite: () =>
                    setState(() => _isFavorite = !_isFavorite),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _RatingStars(rating: rating),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${reviewsCount} ${'reviews'.tr()})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _ProviderHighlight(
                        avatar: providerAvatar,
                        name: providerName,
                        specialty: providerSpecialty,
                        description: providerDescription,
                        rating: providerRating,
                        reviewsCount: providerReviews,
                      ),
                      const SizedBox(height: 26),
                      if (hasDescription) ...[
                        Text(
                          'services.detail.description'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.35,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.8),
                          ),
                        ),
                      if (!_isDescriptionExpanded && description.length > 160)
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _isDescriptionExpanded = true),
                          icon:
                              const Icon(Icons.keyboard_arrow_right_rounded),
                          label: Text('services.detail.read_more'.tr()),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _ServiceOfferingReviewsSection(
                        offeringId: widget.offeringId,
                        baseUrl: widget.baseUrl,
                        onAddReview: () => _handleAddReview(context),
                      ),
                      const SizedBox(height: 24),
                      _RelatedOfferings(
                        baseUrl: widget.baseUrl,
                        offeringId: widget.offeringId,
                      ),
                    ],
                  ),
                ),
              ),
              _BottomBar(
                price: price,
                onBook: () => _handleAppointmentTap(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleAppointmentTap(BuildContext context) {
    final authState = context.read<AuthSessionCubit>().state;
    if (!authState.isAuthenticated) {
      _showSignInPrompt(context);
      return;
    }
    context.push('/appointments/create', extra: widget.item.id);
  }

  void _showSignInPrompt(BuildContext context) {
    final rootContext = context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: MediaQuery.of(sheetContext).viewInsets,
          child: SignInRequiredCard(
            onSignIn: () {
              Navigator.of(sheetContext).pop();
              rootContext.go('/signin');
            },
            onCreateAccount: () {
              Navigator.of(sheetContext).pop();
              rootContext.go('/signup');
            },
            onGoogleSignIn: () {},
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddReview(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ServiceOfferingReviewsCubit>(),
          child: const ServiceOfferingAddReviewPage(),
        ),
      ),
    );
    if (result == true) {
      context.read<ServiceOfferingDetailCubit>().load(widget.offeringId);
      context.read<ServiceOfferingReviewsCubit>().refresh();
    }
  }
}

class _TopPreview extends StatelessWidget {
  const _TopPreview({
    required this.imageUrl,
    required this.onBack,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final String? imageUrl;
  final VoidCallback onBack;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

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
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => Icon(
                            PhosphorIconsBold.stethoscope,
                            size: 48,
                            color: colorScheme.primary,
                          ),
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
    required this.reviewsCount,
  });

  final String? avatar;
  final String name;
  final String specialty;
  final String description;
  final double? rating;
  final int reviewsCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: theme.colorScheme.surface,
          backgroundImage: (avatar != null && avatar!.isNotEmpty)
              ? NetworkImage(avatar!)
              : null,
          child: (avatar == null || avatar!.isEmpty)
              ? Icon(Icons.person_rounded,
                  color: theme.colorScheme.onSurface, size: 32)
              : null,
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
                  if (rating != null) ...[
                    const Icon(Icons.star_rounded,
                        size: 16, color: Color(0xFFFFC107)),
                    const SizedBox(width: 4),
                    Text(
                      rating!.toStringAsFixed(1),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (reviewsCount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${reviewsCount})',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.black54),
                      ),
                    ],
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.price,
    required this.onBook,
  });

  final double? price;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              price != null ? '\$${price!}' : '—',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: onBook,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text('services.detail.make_appointment'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatedOfferings extends StatelessWidget {
  const _RelatedOfferings({
    required this.baseUrl,
    required this.offeringId,
  });

  final String baseUrl;
  final String offeringId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ServiceOfferingDetailCubit, ServiceOfferingDetailState>(
      builder: (context, state) {
        final hasItems = state.relatedOfferings.isNotEmpty;
        final isInitialLoading =
            state.relatedStatus == RelatedOfferingsStatus.loading && !hasItems;
        final isLoadingMore =
            state.relatedStatus == RelatedOfferingsStatus.loading && hasItems;
        if (isInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if ((state.relatedStatus == RelatedOfferingsStatus.failure &&
                !hasItems) ||
            state.relatedOfferings.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'services.detail.related_items'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 0.60,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.relatedOfferings.length,
              itemBuilder: (context, index) {
                final offering = state.relatedOfferings[index];
                return _RelatedOfferingCard(
                  offering: offering,
                  baseUrl: baseUrl,
                );
              },
            ),
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.hasMoreRelated)
              Center(
                child: TextButton(
                  onPressed: () => context
                      .read<ServiceOfferingDetailCubit>()
                      .loadMoreRelated(offeringId),
                  child: Text('home.featured_services.see_more'.tr()),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ServiceOfferingReviewsSection extends StatefulWidget {
  const _ServiceOfferingReviewsSection({
    required this.offeringId,
    required this.baseUrl,
    required this.onAddReview,
  });

  final String offeringId;
  final String baseUrl;
  final VoidCallback onAddReview;

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
    final addButton = Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: widget.onAddReview,
        icon: const Icon(Icons.rate_review_rounded),
        label: Text('service_offerings.reviews.add_button'.tr()),
      ),
    );

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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addButton,
                  const SizedBox(height: 4),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (state.status == ServiceOfferingReviewsStatus.failure &&
                state.reviews.isEmpty) {
              final errorText =
                  (state.message ?? 'service_offerings.reviews.error')
                      .replaceFirst('Exception: ', '')
                      .tr();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addButton,
                  const SizedBox(height: 4),
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
                  addButton,
                  const SizedBox(height: 4),
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
                !_showAll && state.reviews.length > _initialVisible ||
                    state.hasMore;

            return Column(
              children: [
                addButton,
                const SizedBox(height: 4),
                ...visibleReviews
                    .map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ServiceOfferingReviewCard(
                          review: review,
                          baseUrl: widget.baseUrl,
                          onTap: () {},
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

class _RelatedOfferingCard extends StatelessWidget {
  const _RelatedOfferingCard({
    required this.offering,
    required this.baseUrl,
  });

  final ServiceOfferingModel offering;
  final String baseUrl;

  String? _resolvePath(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    try {
      return Uri.parse(baseUrl).resolve(path).toString();
    } catch (_) {
      return path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final coverImage = offering.images.isNotEmpty
        ? _resolvePath(offering.images.first)
        : _resolvePath(offering.service.image);
    final serviceTitle = offering.nameForLocale(locale);
    final providerName = offering.provider.name;
    final price = offering.price;

    return ServiceOfferingCard(
      title: serviceTitle,
      subtitle: providerName,
      imageUrl: coverImage,
      priceLabel: price != null ? '\$${price.toStringAsFixed(2)}' : null,
      onTap: () {
        // Navigate to the detail page of the related offering
        context.push(
          '/service-offering/${offering.id}',
          extra: {
            'item': SearchResultItem(
              id: offering.id,
              title: serviceTitle,
              subtitle: providerName,
              imagePath: coverImage ?? '',
              rating: offering.provider.rating ?? 0,
              description: '',
              type: SearchResultType.serviceOffering,
            ),
            'baseUrl': baseUrl,
          },
        );
      },
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
              child: Text('services.offerings.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
