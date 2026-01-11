import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/core/utils/responsive_grid.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/service_offerings/service_offerings_repository.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/view/service_offering_detail_page.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/view/service_offering_form_page.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offerings_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/become_doctor_required_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/add_service_offering_card.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/service_offering_card.dart';

class MyServiceOfferingsPage extends StatefulWidget {
  const MyServiceOfferingsPage({super.key});

  @override
  State<MyServiceOfferingsPage> createState() => _MyServiceOfferingsPageState();
}

class _MyServiceOfferingsPageState extends State<MyServiceOfferingsPage> {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState.status != AuthStatus.authenticated) {
      return const SizedBox.shrink();
    }

    if (!authState.isDoctor) {
      return _DoctorRequiredView(
        onBecomeDoctor: () => context.go('/become-doctor'),
      );
    }

    return BlocProvider(
      create: (_) => ServiceOfferingsCubit(
        sl<ServiceOfferingsRepository>(),
        useHospitalToken: false,
      )..loadOfferings(),
      child: const _MyServiceOfferingsView(),
    );
  }
}

class _DoctorRequiredView extends StatelessWidget {
  final VoidCallback onBecomeDoctor;

  const _DoctorRequiredView({required this.onBecomeDoctor});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: BecomeDoctorRequiredCard(
            onBecomeDoctor: onBecomeDoctor,
          ),
        ),
      ),
    );
  }
}

class _MyServiceOfferingsView extends StatelessWidget {
  const _MyServiceOfferingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseUrl = sl<AppConfig>().api.baseUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text('service_offerings.list.title'.tr()),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Expanded(
                child:
                    BlocBuilder<ServiceOfferingsCubit, ServiceOfferingsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.offerings.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.hasError && state.offerings.isEmpty) {
                      return _MyOfferingsError(
                        message: state.failure?.message ?? 'unknown_error'.tr(),
                        onRetry: () => context
                            .read<ServiceOfferingsCubit>()
                            .loadOfferings(refresh: true),
                      );
                    }

                    if (state.isEmpty) {
                      return _OfferingsGrid(
                        offerings: const [],
                        baseUrl: baseUrl,
                        onCreate: () => _openCreation(context),
                        onOpenDetail: (offering) =>
                            _openDetail(context, offering),
                        onReload: () => context
                            .read<ServiceOfferingsCubit>()
                            .loadOfferings(refresh: true),
                      );
                    }

                    return Stack(
                      children: [
                        _OfferingsGrid(
                          offerings: state.offerings,
                          baseUrl: baseUrl,
                          onCreate: () => _openCreation(context),
                          onOpenDetail: (offering) =>
                              _openDetail(context, offering),
                          onReload: () => context
                              .read<ServiceOfferingsCubit>()
                              .loadOfferings(refresh: true),
                        ),
                        if (state.isLoading)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCreation(BuildContext context) {
    Navigator.of(context)
        .push<ServiceOffering>(MaterialPageRoute(
      builder: (_) => const ServiceOfferingFormPage(
        hospitalId: '',
        useHospitalToken: false,
      ),
    ))
        .then((value) {
      if (value != null) {
        context.read<ServiceOfferingsCubit>().updateOffering(value);
      }
    });
  }

  void _openDetail(BuildContext context, ServiceOffering offering) {
    Navigator.of(context)
        .push<dynamic>(MaterialPageRoute(
      builder: (_) => ServiceOfferingDetailPage(
        offeringId: offering.id,
        initial: offering,
        hospitalId: null,
        useHospitalToken: false,
        allowDelete: true,
      ),
    ))
        .then((value) {
      if (value is ServiceOffering) {
        context.read<ServiceOfferingsCubit>().updateOffering(value);
      } else if (value == 'deleted') {
        context.read<ServiceOfferingsCubit>().removeOffering(offering.id);
      }
    });
  }
}

class _OfferingsGrid extends StatelessWidget {
  final List<ServiceOffering> offerings;
  final String baseUrl;
  final VoidCallback onCreate;
  final void Function(ServiceOffering) onOpenDetail;
  final VoidCallback onReload;

  const _OfferingsGrid({
    required this.offerings,
    required this.baseUrl,
    required this.onCreate,
    required this.onOpenDetail,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    const double rang = 40;
    final width = MediaQuery.sizeOf(context).width;
    final aspectRatio = (0.65 + ((width - 360) / 1200) * 0.12).clamp(0.65, 0.8);
    final crossAxisCount = responsiveGridColumns(
      width,
      rang: rang,
    );
    final useLargeCard = width >= 550;

    return RefreshIndicator(
      onRefresh: () async => onReload(),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: offerings.length + 1,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: aspectRatio - 0.08,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return AddServiceOfferingCard(onTap: onCreate);
          }
          final offering = offerings[index - 1];
          final locale = context.locale.languageCode;
          final serviceName = offering.localizedName(locale);
          final price = offering.price > 0
              ? 'service_offerings.list.price'.tr(
                  namedArgs: {'price': offering.price.toStringAsFixed(2)},
                )
              : '';
          final subtitle = offering.descriptionEn ??
              offering.descriptionAr ??
              offering.descriptionFr ??
              offering.descriptionSp ??
              'service_offerings.detail.no_description'.tr();
          final rating = offering.rating;
          final image = _resolveImage(
            offering.images.isNotEmpty
                ? offering.images.first
                : (offering.service.image ?? offering.provider.cover),
            baseUrl,
          );
          return useLargeCard
              ? LargServiceOfferingCard(
                  title: serviceName,
                  subtitle: subtitle,
                  priceLabel: price,
                  imageUrl: image,
                  baseUrl: baseUrl,
                  onTap: () => onOpenDetail(offering),
                )
              : ServiceOfferingCard(
                  title: serviceName,
                  subtitle: subtitle,
                  priceLabel: price,
                  imageUrl: image,
                  baseUrl: baseUrl,
                  onTap: () => onOpenDetail(offering),
                );
        },
      ),
    );
  }
}

class _MyOfferingsError extends StatelessWidget {
  const _MyOfferingsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message.startsWith('service_offerings.') ? message.tr() : message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
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

String? _resolveImage(String? path, String baseUrl) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  try {
    return Uri.parse(baseUrl).resolve(path).toString();
  } catch (_) {
    return path;
  }
}
