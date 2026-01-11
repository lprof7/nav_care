import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_user_app/presentation/features/doctors/view/doctor_detail_page.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/doctors_choice/viewmodel/doctors_choice_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/doctors_choice/viewmodel/doctors_choice_state.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/featured_doctors/viewmodel/featured_doctors_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/featured_doctors/viewmodel/featured_doctors_state.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/recent_doctors/viewmodel/recent_doctors_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/sections/recent_doctors/viewmodel/recent_doctors_state.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/doctor_grid_card.dart';

class NavcareDoctorsPage extends StatefulWidget {
  final List<DoctorModel> doctors;
  final String titleKey;
  final bool enablePagination;

  const NavcareDoctorsPage({
    super.key,
    this.doctors = const [],
    this.titleKey = 'home.doctors_choice.title',
    this.enablePagination = false,
  });

  @override
  State<NavcareDoctorsPage> createState() => _NavcareDoctorsPageState();
}

class _NavcareDoctorsPageState extends State<NavcareDoctorsPage> {
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
    final DoctorsChoiceCubit? choiceCubit =
        widget.enablePagination ? _maybeRead<DoctorsChoiceCubit>(context) : null;
    final FeaturedDoctorsCubit? featuredCubit =
        widget.enablePagination ? _maybeRead<FeaturedDoctorsCubit>(context) : null;
    final RecentDoctorsCubit? recentCubit =
        widget.enablePagination ? _maybeRead<RecentDoctorsCubit>(context) : null;
    final cubit = choiceCubit ?? featuredCubit ?? recentCubit;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titleKey.tr()),
      ),
      body: cubit == null
          ? _StaticDoctorsGrid(
              doctors: widget.doctors,
              controller: _scrollController,
            )
          : choiceCubit != null
              ? BlocBuilder<DoctorsChoiceCubit, DoctorsChoiceState>(
                  builder: (context, state) {
                    if ((state.status == DoctorsChoiceStatus.loading ||
                            state.status == DoctorsChoiceStatus.initial) &&
                        state.doctors.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == DoctorsChoiceStatus.failure &&
                        state.doctors.isEmpty) {
                      return Center(
                        child: Text(
                          state.message ?? 'common.error_occurred'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    if (state.doctors.isEmpty) {
                      return Center(
                        child: Text(
                          'home.doctors_choice.empty'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return _DoctorsGrid(
                      doctors: state.doctors,
                      controller: _scrollController,
                      showLoadingTail: state.hasNextPage,
                    );
                  },
                )
              : featuredCubit != null
                  ? BlocBuilder<FeaturedDoctorsCubit, FeaturedDoctorsState>(
                      builder: (context, state) {
                    if ((state.status == FeaturedDoctorsStatus.loading ||
                            state.status == FeaturedDoctorsStatus.initial) &&
                        state.doctors.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == FeaturedDoctorsStatus.failure &&
                        state.doctors.isEmpty) {
                      return Center(
                        child: Text(
                          state.message ?? 'common.error_occurred'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    if (state.doctors.isEmpty) {
                      return Center(
                        child: Text(
                          'home.featured_doctors.empty'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return _DoctorsGrid(
                      doctors: state.doctors,
                      controller: _scrollController,
                      showLoadingTail: state.hasNextPage,
                    );
                  },
                )
                  : BlocBuilder<RecentDoctorsCubit, RecentDoctorsState>(
                      builder: (context, state) {
                        if ((state.status == RecentDoctorsStatus.loading ||
                                state.status == RecentDoctorsStatus.initial) &&
                            state.doctors.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state.status == RecentDoctorsStatus.failure &&
                            state.doctors.isEmpty) {
                          return Center(
                            child: Text(
                              state.message ?? 'common.error_occurred'.tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }

                        if (state.doctors.isEmpty) {
                          return Center(
                            child: Text(
                              'home.recent_doctors.empty'.tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }

                        return _DoctorsGrid(
                          doctors: state.doctors,
                          controller: _scrollController,
                          showLoadingTail: state.hasNextPage,
                        );
                      },
                    ),
    );
  }

  void _onScroll() {
    if (!widget.enablePagination || !_isBottom) return;
    final choiceCubit = _maybeRead<DoctorsChoiceCubit>(context);
    final featuredCubit = _maybeRead<FeaturedDoctorsCubit>(context);
    final recentCubit = _maybeRead<RecentDoctorsCubit>(context);
    if (choiceCubit != null) {
      choiceCubit.loadMoreDoctors();
    } else if (featuredCubit != null) {
      featuredCubit.loadMoreDoctors();
    } else if (recentCubit != null) {
      recentCubit.loadMoreDoctors();
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

class _StaticDoctorsGrid extends StatelessWidget {
  final List<DoctorModel> doctors;
  final ScrollController controller;

  const _StaticDoctorsGrid({
    required this.doctors,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return Center(
        child: Text(
          'home.doctors_choice.empty'.tr(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return _DoctorsGrid(
      doctors: doctors,
      controller: controller,
      showLoadingTail: false,
    );
  }
}

class _DoctorsGrid extends StatelessWidget {
  final List<DoctorModel> doctors;
  final ScrollController controller;
  final bool showLoadingTail;

  const _DoctorsGrid({
    required this.doctors,
    required this.controller,
    this.showLoadingTail = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        int crossAxisCount = 2;
        double childAspectRatio = 0.74;

        if (maxWidth >= 1200) {
          crossAxisCount = 4;
          childAspectRatio = 0.78;
        } else if (maxWidth >= 650) {
          crossAxisCount = 3;
          childAspectRatio = 0.76;
        } else if (maxWidth >= 300) {
          crossAxisCount = 2;
          childAspectRatio = 0.74;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          controller: controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: showLoadingTail ? doctors.length + 1 : doctors.length,
          itemBuilder: (context, index) {
            if (index >= doctors.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final doctor = doctors[index];
            final baseUrl = sl<AppConfig>().api.baseUrl;
            final coverPath = doctor.avatarImage(baseUrl: baseUrl) ??
                doctor.coverImage(baseUrl: baseUrl);
            final displayName = doctor.displayName.trim().isNotEmpty
                ? doctor.displayName
                : doctor.specialty;
            final specialtyLabel = doctor.specialty.trim().isNotEmpty
                ? doctor.specialty
                : 'home.doctors_choice.title'.tr();

            return DoctorGridCard(
              title: displayName,
              subtitle: specialtyLabel,
              imageUrl: coverPath,
              rating: doctor.rating > 0 ? doctor.rating : null,
              buttonLabel: 'hospitals.detail.cta.view_profile'.tr(),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DoctorDetailPage(
                      doctorId: doctor.id,
                      initial: doctor,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
