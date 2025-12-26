import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/invite_doctor_cubit.dart';

class InviteDoctorSheet extends StatelessWidget {
  final String baseUrl;
  final void Function(DoctorModel) onOpenDetail;
  static const double _loadMoreTrigger = 120;

  const InviteDoctorSheet({
    super.key,
    required this.baseUrl,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = MediaQuery.of(context).viewInsets +
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

    return SafeArea(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'hospitals.detail.invite_doctor_title'.tr(),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'hospitals.detail.invite_doctor_subtitle'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'hospitals.detail.invite_doctor_search'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: context.read<InviteDoctorCubit>().updateQuery,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: BlocBuilder<InviteDoctorCubit, InviteDoctorState>(
                builder: (context, state) {
                  if (state.isLoading && state.doctors.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.failure != null) {
                    return _InviteError(
                      message: state.failure!.message,
                      onRetry: () => context.read<InviteDoctorCubit>().load(),
                    );
                  }

                  final doctors = state.filteredDoctors;
                  if (doctors.isEmpty) {
                    return _InviteEmpty(
                      onReload: () => context.read<InviteDoctorCubit>().load(),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent -
                              _loadMoreTrigger) {
                        context.read<InviteDoctorCubit>().loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      itemCount: doctors.length +
                          (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index >= doctors.length) {
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
                        final doctor = doctors[index];
                        final image = doctor.avatarImage(baseUrl: baseUrl) ??
                            doctor.coverImage(baseUrl: baseUrl);
                        return _DoctorTile(
                          doctor: doctor,
                          imageUrl: image,
                          onOpenDetail: () => onOpenDetail(doctor),
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
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final DoctorModel doctor;
  final String? imageUrl;
  final VoidCallback onOpenDetail;

  const _DoctorTile({
    required this.doctor,
    required this.imageUrl,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.surfaceVariant,
            backgroundImage:
                imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage(imageUrl!) : null,
            onBackgroundImageError: (_, __) {},
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? const Icon(Icons.person_rounded)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : '--',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onOpenDetail,
            child: Text('hospitals.detail.invite_doctor_view_profile'.tr()),
          ),
        ],
      ),
    );
  }
}

class _InviteEmpty extends StatelessWidget {
  final VoidCallback onReload;

  const _InviteEmpty({required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 42, color: Colors.grey),
          const SizedBox(height: 10),
          Text('hospitals.detail.invite_doctor_empty'.tr()),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('hospitals.detail.invite_doctor_reload'.tr()),
          ),
        ],
      ),
    );
  }
}

class _InviteError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InviteError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 42, color: Colors.red),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('hospitals.detail.invite_doctor_reload'.tr()),
          ),
        ],
      ),
    );
  }
}
