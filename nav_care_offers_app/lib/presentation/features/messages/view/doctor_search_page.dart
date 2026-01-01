import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/presentation/features/messages/view/widgets/doctor_search_card.dart';
import 'package:nav_care_offers_app/presentation/features/messages/viewmodel/doctor_search_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/messages/viewmodel/doctor_search_state.dart';

class DoctorSearchPage extends StatelessWidget {
  const DoctorSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DoctorSearchCubit>(),
      child: const _DoctorSearchView(),
    );
  }
}

class _DoctorSearchView extends StatefulWidget {
  const _DoctorSearchView();

  @override
  State<_DoctorSearchView> createState() => _DoctorSearchViewState();
}

class _DoctorSearchViewState extends State<_DoctorSearchView> {
  final _searchController = TextEditingController();
  static const double _loadMoreTrigger = 140;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    return Scaffold(
      appBar: AppBar(
        title: Text('messages.search_doctors_title'.tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'messages.search_doctors_hint'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: context.read<DoctorSearchCubit>().updateQuery,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: BlocConsumer<DoctorSearchCubit, DoctorSearchState>(
                  listenWhen: (prev, curr) =>
                      prev.errorMessage != curr.errorMessage &&
                      curr.errorMessage != null &&
                      curr.errorMessage!.isNotEmpty,
                  listener: (context, state) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'messages.search_error'
                              .tr(namedArgs: {'message': state.errorMessage!}),
                        ),
                      ),
                    );
                  },
                  builder: (context, state) {
                    if (state.status == DoctorSearchStatus.idle) {
                      return _SearchHint();
                    }

                    if (state.status == DoctorSearchStatus.loading &&
                        state.doctors.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == DoctorSearchStatus.failure &&
                        state.doctors.isEmpty) {
                      return _SearchError(
                        onRetry: () => context
                            .read<DoctorSearchCubit>()
                            .search(state.query),
                      );
                    }

                    if (state.doctors.isEmpty) {
                      return _SearchEmpty(
                        onRetry: () => context
                            .read<DoctorSearchCubit>()
                            .search(state.query),
                      );
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent -
                                _loadMoreTrigger) {
                          context.read<DoctorSearchCubit>().loadMore();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        itemCount:
                            state.doctors.length + (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index >= state.doctors.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          final doctor = state.doctors[index];
                          final image = doctor.avatarImage(baseUrl: baseUrl) ??
                              doctor.coverImage(baseUrl: baseUrl);
                          return DoctorSearchCard(
                            doctor: doctor,
                            imageUrl: image,
                            onOpenDetail: () => context.push(
                              '/messages/chat',
                              extra: {
                                'name': doctor.displayName,
                                'imageUrl': image,
                                'counterpartUserId': doctor.userId,
                              },
                            ),
                          );
                        },
                      ),
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
}

class _SearchHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_rounded, size: 42, color: Colors.grey),
          const SizedBox(height: 10),
          Text('messages.search_doctors_subtitle'.tr()),
        ],
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  final VoidCallback onRetry;
  const _SearchEmpty({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 42, color: Colors.grey),
          const SizedBox(height: 10),
          Text('messages.search_empty'.tr()),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('messages.search_retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  final VoidCallback onRetry;
  const _SearchError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 42, color: Colors.red),
          const SizedBox(height: 10),
          Text('messages.search_failed'.tr()),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('messages.search_retry'.tr()),
          ),
        ],
      ),
    );
  }
}
