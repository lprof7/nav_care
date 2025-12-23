import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/hospitals/models/hospital_model.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/featured_hospitals/viewmodel/featured_hospitals_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/featured_hospitals/viewmodel/featured_hospitals_state.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/hospitals_choice/viewmodel/hospitals_choice_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/hospitals_choice/viewmodel/hospitals_choice_state.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/recent_hospitals/viewmodel/recent_hospitals_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/recent_hospitals/viewmodel/recent_hospitals_state.dart';
import 'package:nav_care_user_app/presentation/features/hospitals/view/hospital_detail_page.dart';

class NavcareHospitalsPage extends StatefulWidget {
  final List<HospitalModel> hospitals;
  final String titleKey;
  final String emptyKey;
  final bool enablePagination;

  const NavcareHospitalsPage({
    super.key,
    this.hospitals = const [],
    this.titleKey = 'home.hospitals_choice.title',
    this.emptyKey = 'home.hospitals_choice.empty',
    this.enablePagination = false,
  });

  @override
  State<NavcareHospitalsPage> createState() => _NavcareHospitalsPageState();
}

class _NavcareHospitalsPageState extends State<NavcareHospitalsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HospitalsChoiceCubit? choiceCubit =
        widget.enablePagination ? _maybeRead<HospitalsChoiceCubit>(context) : null;
    final FeaturedHospitalsCubit? featuredCubit =
        widget.enablePagination ? _maybeRead<FeaturedHospitalsCubit>(context) : null;
    final RecentHospitalsCubit? recentCubit =
        widget.enablePagination ? _maybeRead<RecentHospitalsCubit>(context) : null;
    final cubit = choiceCubit ?? featuredCubit ?? recentCubit;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titleKey.tr()),
      ),
      body: cubit == null
          ? _StaticHospitalsBody(
              hospitals: widget.hospitals,
              emptyKey: widget.emptyKey,
              controller: _scrollController,
            )
          : choiceCubit != null
              ? BlocBuilder<HospitalsChoiceCubit, HospitalsChoiceState>(
                  builder: (context, state) {
                    if ((state.status == HospitalsChoiceStatus.loading ||
                            state.status == HospitalsChoiceStatus.initial) &&
                        state.hospitals.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == HospitalsChoiceStatus.failure &&
                        state.hospitals.isEmpty) {
                      return Center(
                        child: Text(
                          state.message ?? 'common.error_occurred'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    if (state.hospitals.isEmpty) {
                      return Center(
                        child: Text(
                          widget.emptyKey.tr(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return _HospitalsListView(
                      hospitals: state.hospitals,
                      controller: _scrollController,
                      showLoadingTail: state.hasNextPage,
                    );
                  },
                )
              : featuredCubit != null
                  ? BlocBuilder<FeaturedHospitalsCubit, FeaturedHospitalsState>(
                      builder: (context, state) {
                        if ((state.status == FeaturedHospitalsStatus.loading ||
                                state.status == FeaturedHospitalsStatus.initial) &&
                            state.hospitals.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state.status == FeaturedHospitalsStatus.failure &&
                            state.hospitals.isEmpty) {
                          return Center(
                            child: Text(
                              state.message ?? 'common.error_occurred'.tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }

                        if (state.hospitals.isEmpty) {
                          return Center(
                            child: Text(
                              widget.emptyKey.tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }

                        return _HospitalsListView(
                          hospitals: state.hospitals,
                          controller: _scrollController,
                          showLoadingTail: state.hasNextPage,
                        );
                      },
                    )
                  : BlocBuilder<RecentHospitalsCubit, RecentHospitalsState>(
                      builder: (context, state) {
                        if ((state.status == RecentHospitalsStatus.loading ||
                                state.status == RecentHospitalsStatus.initial) &&
                            state.hospitals.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state.status == RecentHospitalsStatus.failure &&
                            state.hospitals.isEmpty) {
                          return Center(
                            child: Text(
                              state.message ?? 'common.error_occurred'.tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }

                        if (state.hospitals.isEmpty) {
                          return Center(
                            child: Text(
                              widget.emptyKey.tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }

                        return _HospitalsListView(
                          hospitals: state.hospitals,
                          controller: _scrollController,
                          showLoadingTail: state.hasNextPage,
                        );
                      },
                    ),
    );
  }

  void _onScroll() {
    if (!widget.enablePagination || !_isBottom) return;
    final choiceCubit = _maybeRead<HospitalsChoiceCubit>(context);
    final featuredCubit = _maybeRead<FeaturedHospitalsCubit>(context);
    final recentCubit = _maybeRead<RecentHospitalsCubit>(context);
    if (choiceCubit != null) {
      choiceCubit.loadMoreHospitals();
    } else if (featuredCubit != null) {
      featuredCubit.loadMoreHospitals();
    } else if (recentCubit != null) {
      recentCubit.loadMoreHospitals();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= maxScroll * 0.9;
  }

  T? _maybeRead<T extends StateStreamableSource<Object?>>(BuildContext context) {
    try {
      return BlocProvider.of<T>(context, listen: false);
    } catch (_) {
      return null;
    }
  }
}

class _StaticHospitalsBody extends StatelessWidget {
  final List<HospitalModel> hospitals;
  final String emptyKey;
  final ScrollController controller;

  const _StaticHospitalsBody({
    required this.hospitals,
    required this.emptyKey,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (hospitals.isEmpty) {
      return Center(
        child: Text(
          emptyKey.tr(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return _HospitalsListView(
      hospitals: hospitals,
      controller: controller,
      showLoadingTail: false,
    );
  }
}

class _HospitalsListView extends StatelessWidget {
  final List<HospitalModel> hospitals;
  final ScrollController controller;
  final bool showLoadingTail;

  const _HospitalsListView({
    required this.hospitals,
    required this.controller,
    this.showLoadingTail = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      controller: controller,
      itemCount: showLoadingTail ? hospitals.length + 1 : hospitals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index >= hospitals.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final hospital = hospitals[index];
        return _HospitalListTile(hospital: hospital);
      },
    );
  }
}

class _HospitalListTile extends StatelessWidget {
  final HospitalModel hospital;

  const _HospitalListTile({required this.hospital});

  @override
  Widget build(BuildContext context) {
    final description = hospital.descriptionForLocale(context.locale.languageCode);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final image = hospital.primaryImage(baseUrl: baseUrl);
    final facilityLabel = hospital.field.trim().isNotEmpty
        ? hospital.field
        : hospital.facilityType;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HospitalDetailPage(
              hospitalId: hospital.id,
              initial: hospital,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _HospitalCoverImage(path: image),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIconsBold.buildings,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              facilityLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (hospital.rating > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hospital.rating.toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hospital.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (hospital.address.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            hospital.address,
                            style: Theme.of(context).textTheme.bodySmall,
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
      ),
    );
  }
}

class _HospitalCoverImage extends StatelessWidget {
  final String? path;

  const _HospitalCoverImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget placeholder(
        {IconData icon = PhosphorIconsBold.stethoscope, double size = 48}) {
      return Container(
        color: theme.colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(icon, size: size),
      );
    }

    final imagePath = path;
    if (imagePath == null || imagePath.isEmpty) {
      return placeholder();
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder(icon: PhosphorIconsBold.buildings, size: 40);
        },
        errorBuilder: (context, error, stackTrace) =>
            placeholder(icon: Icons.image_not_supported_rounded, size: 36),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          placeholder(icon: Icons.image_not_supported_rounded, size: 36),
    );
  }
}
