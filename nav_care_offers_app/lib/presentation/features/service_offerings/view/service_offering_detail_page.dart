import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/service_offerings/service_offerings_repository.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offering_detail_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offerings_cubit.dart';

class ServiceOfferingDetailPage extends StatelessWidget {
  const ServiceOfferingDetailPage({
    super.key,
    required this.hospitalId,
    required this.offeringId,
    this.initial,
  });

  final String hospitalId;
  final String offeringId;
  final ServiceOffering? initial;

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    return BlocProvider(
      create: (_) => ServiceOfferingDetailCubit(
        sl<ServiceOfferingsRepository>(),
        offeringId: offeringId,
        initial: initial,
      )..refresh(),
      child: _ServiceOfferingDetailView(
        hospitalId: hospitalId,
        baseUrl: baseUrl,
      ),
    );
  }
}

class _ServiceOfferingDetailView extends StatelessWidget {
  const _ServiceOfferingDetailView({
    required this.hospitalId,
    required this.baseUrl,
  });

  final String hospitalId;
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiceOfferingDetailCubit, ServiceOfferingDetailState>(
      listener: (context, state) {
        if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.failure!.message ?? 'unknown_error'.tr())),
          );
        }
        if (state.offering != null) {
          final offeringsCubit = _maybeOfferingsCubit(context);
          offeringsCubit?.updateOffering(state.offering!);
        }
      },
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

        final theme = Theme.of(context);
        final locale = context.locale.languageCode;
        final serviceName = offering.localizedName(locale);
        final description = _localizedDescription(offering, locale);
        final rating = offering.provider.rating;
        final providerName = offering.provider.user.name;
        final providerSpecialty = offering.provider.specialty ?? '';
        final image = _resolvePath(
          offering.images.isNotEmpty
              ? offering.images.first
              : (offering.service.image ?? offering.provider.cover),
        );
        final avatar = _resolvePath(offering.provider.user.profilePicture);
        final priceLabel =
            offering.price > 0 ? offering.price.toStringAsFixed(2) : '--';
        print("provider: ${offering.provider.bioEn}");
        print("service: ${offering.service.nameEn}");
        print("description: $description");
        print("rating: $rating");
        print("providerName: $providerName");
        print("providerSpecialty: $providerSpecialty");
        print("image: $image");
        print("avatar: $avatar");
        print("priceLabel: $priceLabel");
        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          appBar: AppBar(
            title: Text(serviceName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _openEdit(context, hospitalId, offering),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopPreview(
                    imageUrl: image,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF1F3958),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (rating != null) ...[
                              const Icon(Icons.star_rounded,
                                  size: 18, color: Color(0xFFFFC107)),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF1F3958),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Chip(
                              label: Text(offering.providerType),
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.1),
                              labelStyle: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _ProviderHighlight(
                          avatar: avatar,
                          name: providerName,
                          specialty: providerSpecialty.isNotEmpty
                              ? providerSpecialty
                              : 'service_offerings.detail.provider'.tr(),
                          rating: rating,
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          label: 'service_offerings.detail.price'.tr(),
                          value: priceLabel,
                          icon: Icons.price_change_outlined,
                        ),
                        const SizedBox(height: 18),
                        _InfoRow(
                          label: 'service_offerings.detail.provider'.tr(),
                          value: providerName.isNotEmpty
                              ? providerName
                              : 'service_offerings.detail.unknown_provider'.tr(),
                          icon: Icons.person_outline,
                        ),
                        if (providerSpecialty.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'service_offerings.detail.specialty'.tr(),
                            value: providerSpecialty,
                            icon: Icons.badge_outlined,
                          ),
                        ],
                        const SizedBox(height: 22),
                        Text(
                          'service_offerings.detail.description'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF1F3958),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description.isNotEmpty
                              ? description
                              : 'service_offerings.detail.no_description'.tr(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF2F435A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

  String? _resolvePath(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    try {
      return Uri.parse(baseUrl).resolve(path).toString();
    } catch (_) {
      return path;
    }
  }

  void _openEdit(
    BuildContext context,
    String hospitalId,
    ServiceOffering offering,
  ) {
    final route =
        '/hospitals/$hospitalId/service-offerings/${offering.id}/edit';
    context.push(route, extra: offering).then((value) {
      if (value is ServiceOffering) {
        context.read<ServiceOfferingDetailCubit>().replace(value);
        final offeringsCubit = _maybeOfferingsCubit(context);
        offeringsCubit?.updateOffering(value);
        context.pop(value);
      }
    });
  }

  ServiceOfferingsCubit? _maybeOfferingsCubit(BuildContext context) {
    try {
      return context.read<ServiceOfferingsCubit>();
    } catch (_) {
      return null;
    }
  }
}

class _TopPreview extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onBack;

  const _TopPreview({required this.imageUrl, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 230,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceVariant,
                    alignment: Alignment.center,
                    child: const Icon(Icons.medical_services_rounded, size: 48),
                  ),
                )
              : Container(
                  color: theme.colorScheme.surfaceVariant,
                  alignment: Alignment.center,
                  child: const Icon(Icons.medical_services_rounded, size: 48),
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
          Positioned(
            top: 12,
            left: 12,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: onBack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderHighlight extends StatelessWidget {
  final String? avatar;
  final String name;
  final String specialty;
  final double? rating;

  const _ProviderHighlight({
    required this.avatar,
    required this.name,
    required this.specialty,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.surfaceVariant,
            backgroundImage: avatar != null && avatar!.isNotEmpty
                ? NetworkImage(avatar!)
                : null,
            child: (avatar == null || avatar!.isEmpty)
                ? const Icon(Icons.person_rounded)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F3958),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (rating != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 16, color: Color(0xFFFFC107)),
                      const SizedBox(width: 4),
                      Text(
                        rating!.toStringAsFixed(1),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
