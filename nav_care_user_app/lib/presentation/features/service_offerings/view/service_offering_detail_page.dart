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

  Map<String, dynamic> get _service =>
      (widget.item.extra['service'] as Map?)?.cast<String, dynamic>() ?? {};

  Map<String, dynamic> get _provider =>
      (widget.item.extra['provider'] as Map?)?.cast<String, dynamic>() ?? {};

  Map<String, dynamic> get _providerUser =>
      (_provider['user'] as Map?)?.cast<String, dynamic>() ?? {};

  String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  String _fallbackText(List<String?> candidates, String fallback) {
    for (final value in candidates) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return fallback;
  }

  String _serviceTitle(BuildContext context) {
    final locale = context.locale.languageCode;
    final localizedName = _asString(_service['name_$locale']);
    if (localizedName != null && localizedName.isNotEmpty) return localizedName;
    return _fallbackText(
      [
        _asString(_service['name_en']),
        _asString(_service['name']),
        widget.item.title,
      ],
      widget.item.title,
    );
  }

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
    return description?.isNotEmpty == true ? description! : widget.item.description.isNotEmpty ? widget.item.description : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
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

          final coverImage = _resolvePath(offering?.service.image ??
              widget.item.imagePath ??
              _asString(_service['image']));
          final providerAvatar = _resolvePath(
              offering?.provider.user.profilePicture ??
                  _asString(_providerUser['profilePicture']));
          final providerName = _fallbackText(
            [
              offering?.provider.user.name,
              _asString(_providerUser['name']),
              widget.item.subtitle
            ],
            widget.item.subtitle,
          );
          final providerSpecialty = _fallbackText(
            [
              offering?.provider.specialty,
              _asString(_provider['specialty']),
              widget.item.description
            ],
            '',
          );
          final price = offering?.price ?? widget.item.price;
          final rating = offering?.provider.rating ?? widget.item.rating ?? 0;
          final reviewsCount = offering?.provider.reviewsCount ?? 0;
          final description = _fallbackDescription(context.locale.languageCode, offering);

          final hasDescription = description.trim().isNotEmpty;

          return SafeArea(
            child: Column(
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
                          _serviceTitle(context),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF1F3958),
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
                                color: const Color(0xFF1F3958),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${reviewsCount} ${'reviews'.tr()})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF8BA0B7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _ProviderHighlight(
                          avatar: providerAvatar,
                          name: providerName,
                          specialty: providerSpecialty.isNotEmpty
                              ? providerSpecialty
                              : 'services.offerings.title'.tr(),
                        ),
                        const SizedBox(height: 26),
                        if (hasDescription) ...[
                          Text(
                            'services.detail.description'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF1F3958),
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
                              color: const Color(0xFF4A6076),
                              height: 1.35,
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
            ),
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
              rootContext.go('/signin');
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
        color: Colors.white,
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
      child: Stack(
        children: [
          Center(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Positioned(
            top: 8,
            left: 4,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1F3958),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 12,
            child: Material(
              shape: const CircleBorder(),
              elevation: 3,
              color: Colors.white,
              child: IconButton(
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xFF00C26F),
                ),
              ),
            ),
          ),
        ],
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
          backgroundColor: const Color(0xFFE8EEF5),
          backgroundImage: (avatar != null && avatar!.isNotEmpty)
              ? NetworkImage(avatar!)
              : null,
          child: (avatar == null || avatar!.isEmpty)
              ? const Icon(Icons.person_rounded,
                  color: Color(0xFF1F3958), size: 32)
              : null,
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF1F3958),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              specialty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5E738E),
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
        color: Colors.white,
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
              price != null ? '\$${price!.toStringAsFixed(0)}' : '—',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF1F3958),
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
                  backgroundColor: const Color(0xFF2878F0),
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
