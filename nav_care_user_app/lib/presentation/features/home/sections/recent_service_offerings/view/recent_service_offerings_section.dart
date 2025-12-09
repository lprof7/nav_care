import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/view/service_offering_detail_page.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/service_offering_card.dart';

import '../../../view/recent_service_offerings_page.dart';
import '../viewmodel/recent_service_offerings_cubit.dart';
import '../viewmodel/recent_service_offerings_state.dart';

class RecentServiceOfferingsSection extends StatelessWidget {
  const RecentServiceOfferingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RecentServiceOfferingsBody();
  }
}

class _RecentServiceOfferingsBody extends StatelessWidget {
  const _RecentServiceOfferingsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentServiceOfferingsCubit,
        RecentServiceOfferingsState>(
      builder: (context, state) {
        switch (state.status) {
          case RecentServiceOfferingsStatus.loading:
            return const _RecentServiceOfferingsLoading();
          case RecentServiceOfferingsStatus.failure:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/error/failure.png', // الصورة عند الفشل
                    width: 100, // تصغير حجم الصورة
                    height: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.message ??
                        'common.error_occurred'.tr(), // رسالة خطأ عامة
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          case RecentServiceOfferingsStatus.loaded:
            if (state.offerings.isEmpty) {
              return _RecentServiceOfferingsEmpty(
                message: 'home.recent_service_offerings.empty'.tr(),
              );
            }
            return _RecentServiceOfferingsContent(offerings: state.offerings);
          case RecentServiceOfferingsStatus.initial:
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class _RecentServiceOfferingsContent extends StatelessWidget {
  final List<ServiceOfferingModel> offerings;

  const _RecentServiceOfferingsContent({required this.offerings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'home.recent_service_offerings.title'.tr(),
            actionLabel: 'home.recent_service_offerings.see_more'.tr(),
            onTap: () => _openSeeMore(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: offerings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final offering = offerings[index];
                return _RecentServiceOfferingCard(offering: offering);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openSeeMore(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RecentServiceOfferingsCubit>(),
          child: const RecentServiceOfferingsPage(),
        ),
      ),
    );
  }
}

class _RecentServiceOfferingCard extends StatelessWidget {
  final ServiceOfferingModel offering;

  const _RecentServiceOfferingCard({required this.offering});

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final locale = context.locale.languageCode;
    final serviceName = offering.service.nameForLocale(locale);
    final providerName = offering.provider.name.isNotEmpty
        ? offering.provider.name
        : 'home.recent_service_offerings.unknown_provider'.tr();
    final specialty = offering.provider.specialty;
    final cover = offering.images.isNotEmpty
        ? _resolveImage(offering.images.first, baseUrl)
        : _resolveImage(offering.service.image, baseUrl);
    final priceLabel = offering.price != null
        ? 'services.offerings.price'
            .tr(namedArgs: {'price': offering.price!.toStringAsFixed(2)})
        : null;

    return SizedBox(
      width: 200,
      child: ServiceOfferingCard(
        title: serviceName,
        subtitle: providerName,
        badgeLabel: specialty.trim().isNotEmpty ? specialty : null,
        priceLabel: priceLabel,
        imageUrl: cover,
        buttonLabel: 'hospitals.detail.cta.view_service'.tr(),
        onTap: () {
          final item = _toSearchResult(offering, baseUrl, locale: locale);
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
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _RecentServiceOfferingsLoading extends StatelessWidget {
  const _RecentServiceOfferingsLoading();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(
            width: 180,
            height: 20,
            baseColor: color,
            radius: 12,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, __) {
                return _ShimmerBox(
                  width: 260,
                  height: 260,
                  baseColor: color,
                  radius: 24,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentServiceOfferingsError extends StatelessWidget {
  final String message;

  const _RecentServiceOfferingsError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _RecentServiceOfferingsEmpty extends StatelessWidget {
  final String message;

  const _RecentServiceOfferingsEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

String? _resolveImage(String? path, String baseUrl) {
  if (path == null || path.isEmpty) {
    return null;
  }
  if (path.startsWith('http')) {
    return path;
  }
  try {
    final uri = Uri.parse(baseUrl);
    return uri.resolve(path).toString();
  } catch (_) {
    return path;
  }
}

SearchResultItem _toSearchResult(
  ServiceOfferingModel offering,
  String baseUrl, {
  required String locale,
}) {
  final service = offering.service;
  final provider = offering.provider;
  final serviceName = service.nameForLocale(locale);
  final image = _resolveImage(service.image, baseUrl);
  final avatar = _resolveImage(provider.profilePicture, baseUrl);

  return SearchResultItem(
    id: offering.id,
    type: SearchResultType.serviceOffering,
    title: serviceName,
    subtitle: provider.name,
    description: provider.specialty,
    rating: provider.rating,
    price: offering.price,
    imagePath: image,
    secondaryImagePath: avatar,
    location: const SearchLocation(),
    extra: {
      'service': {
        '_id': service.id,
        'name_en': service.nameEn,
        'name_fr': service.nameFr,
        'name_ar': service.nameAr,
        'name_sp': service.nameSp,
        'image': service.image,
      },
      'provider': {
        '_id': provider.id,
        'user': {
          '_id': provider.id,
          'name': provider.name,
          'profilePicture': provider.profilePicture,
        },
        'specialty': provider.specialty,
        'rating': provider.rating,
      },
    },
  );
}

class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;
  final Color baseColor;

  const _ShimmerBox({
    this.width,
    this.height,
    required this.baseColor,
    this.radius = 12,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * value, -0.3),
              end: Alignment(1 + 2 * value, 0.3),
              stops: const [0.1, 0.3, 0.4, 0.6, 0.9],
              colors: [
                widget.baseColor.withOpacity(0.35),
                widget.baseColor.withOpacity(0.5),
                widget.baseColor.withOpacity(0.85),
                widget.baseColor.withOpacity(0.5),
                widget.baseColor.withOpacity(0.35),
              ],
            ),
          ),
        );
      },
    );
  }
}
