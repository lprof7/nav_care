import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';
import 'package:nav_care_user_app/presentation/features/authentication/session/auth_session_cubit.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/viewmodel/service_offering_detail_cubit.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/viewmodel/service_offering_detail_state.dart';
import 'package:nav_care_user_app/presentation/shared/ui/molecules/sign_in_required_card.dart';

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
    return BlocProvider(
      create: (_) => sl<ServiceOfferingDetailCubit>()..load(resolvedId),
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
          final providerAvatar = _resolvePath(offering.provider.profilePicture);
          final providerName = offering.provider.name;
          final providerSpecialty = offering.provider.specialty;
          final serviceTitle = offering.service.nameForLocale(locale);

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
                          ...List.generate(
                            5,
                            (_) => const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Color(0xFFFFC107),
                              ),
                            ),
                          ),
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
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: SignInRequiredCard(
            onSignIn: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(dialogContext).pop();
              showModalBottomSheet(
                context: rootContext,
                isScrollControlled: true,
                builder: (context) => SignInRequiredCard(
                  onSignIn: () {
                    Navigator.of(context).pop();
                    context.go('/signin');
                  },
                  onCreateAccount: () {
                    Navigator.of(context).pop();
                    context.go('/signup');
                  },
                  onGoogleSignIn: () {},
                ),
              );
            },
            onCreateAccount: () {
              Navigator.of(dialogContext).pop();
              rootContext.go('/signup');
            },
            onGoogleSignIn: () {},
          ),
        );
      },
    );
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
                            Icons.medical_services_rounded,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.medical_services_rounded,
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
  });

  final String? avatar;
  final String name;
  final String specialty;

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              specialty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
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
