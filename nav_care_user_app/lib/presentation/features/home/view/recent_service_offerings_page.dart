import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/recent_service_offerings/viewmodel/recent_service_offerings_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/recent_service_offerings/viewmodel/recent_service_offerings_state.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/view/service_offering_detail_page.dart';

class RecentServiceOfferingsPage extends StatefulWidget {
  const RecentServiceOfferingsPage({super.key});

  @override
  State<RecentServiceOfferingsPage> createState() =>
      _RecentServiceOfferingsPageState();
}

class _RecentServiceOfferingsPageState extends State<RecentServiceOfferingsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home.recent_service_offerings.title'.tr()),
      ),
      body:
          BlocBuilder<RecentServiceOfferingsCubit, RecentServiceOfferingsState>(
        builder: (context, state) {
          switch (state.status) {
            case RecentServiceOfferingsStatus.initial:
            case RecentServiceOfferingsStatus.loading:
              if (state.offerings.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              // Continue to show loaded data while loading more
              break;
            case RecentServiceOfferingsStatus.failure:
              return Center(child: Text(state.message ?? 'An error occurred'));
            case RecentServiceOfferingsStatus.loaded:
              break;
          }

          if (state.offerings.isEmpty) {
            return Center(
              child: Text(
                'home.recent_service_offerings.empty'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            controller: _scrollController,
            itemCount: state.hasNextPage
                ? state.offerings.length + 1
                : state.offerings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) {
              if (index >= state.offerings.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final offering = state.offerings[index];
              return _RecentServiceOfferingTile(offering: offering);
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<RecentServiceOfferingsCubit>().loadMoreOfferings();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}

class _RecentServiceOfferingTile extends StatelessWidget {
  final ServiceOfferingModel offering;

  const _RecentServiceOfferingTile({required this.offering});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final locale = context.locale.languageCode;
    final serviceName = offering.nameForLocale(locale);
    final providerName = offering.provider.name.isNotEmpty
        ? offering.provider.name
        : 'home.recent_service_offerings.unknown_provider'.tr();
    final specialty = offering.provider.specialty;
    final cover = _resolveImage(offering.service.image, baseUrl);
    final avatar = _resolveImage(offering.provider.profilePicture, baseUrl);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _OfferingCoverImage(path: cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Text(
                      serviceName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    backgroundImage:
                        avatar != null ? NetworkImage(avatar) : null,
                    child: avatar == null
                        ? const Icon(Icons.person_rounded, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          providerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (specialty.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              specialty,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if ((offering.provider.rating ?? 0) > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  offering.provider.rating!.toStringAsFixed(1),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
SearchResultItem _toSearchResult(
  ServiceOfferingModel offering,
  String baseUrl, {
  required String locale,
}) {
  final service = offering.service;
  final provider = offering.provider;
  final serviceName = offering.nameForLocale(locale);
  final image = offering.images.isNotEmpty
      ? _resolveImage(offering.images.first, baseUrl)
      : _resolveImage(service.image, baseUrl);
  final avatar = _resolveImage(provider.profilePicture, baseUrl);

  return SearchResultItem(
    id: offering.id,
    type: SearchResultType.serviceOffering,
    title: serviceName,
    subtitle: provider.name,
    description: provider.specialty,
    rating: offering.rating,
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
      'offering': {
        '_id': offering.id,
        'name_en': offering.nameEn,
        'name_fr': offering.nameFr,
        'name_ar': offering.nameAr,
        'name_sp': offering.nameSp,
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
class _OfferingCoverImage extends StatelessWidget {
  final String? path;

  const _OfferingCoverImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: const Icon(PhosphorIconsBold.stethoscope, size: 42),
      );
    }
    if (path!.startsWith('http')) {
      return Image.network(
        path!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    return Image.asset(
      path!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_rounded, size: 36),
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
    return Uri.parse(baseUrl).resolve(path).toString();
  } catch (_) {
    return path;
  }
}
