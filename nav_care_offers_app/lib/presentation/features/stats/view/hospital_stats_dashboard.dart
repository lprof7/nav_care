import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/presentation/features/stats/viewmodel/hospital_stats_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/stats/viewmodel/hospital_stats_state.dart';

import 'widgets/stats_widgets.dart';

class HospitalStatsDashboard extends StatelessWidget {
  const HospitalStatsDashboard({super.key});

  static const _palettes = [
    [Color(0xFF2E7DFF), Color(0xFF6EC1FF)],
    [Color(0xFFFF8A00), Color(0xFFFFC046)],
    [Color(0xFF16A085), Color(0xFF5EE4C2)],
    [Color(0xFFEF476F), Color(0xFFFF9A8B)],
    [Color(0xFF6A5AE0), Color(0xFF9B8CFF)],
    [Color(0xFF00B4D8), Color(0xFF6AD7FF)],
    [Color(0xFF3CBA54), Color(0xFF9AE66E)],
    [Color(0xFFF4B400), Color(0xFFFFD36E)],
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HospitalStatsCubit, HospitalStatsState>(
      builder: (context, state) {
        switch (state.status) {
          case HospitalStatsStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case HospitalStatsStatus.failure:
            return StatsErrorView(
              message: state.failure?.message ?? 'stats.error_generic'.tr(),
              onRetry: () => context.read<HospitalStatsCubit>().load(),
            );
          case HospitalStatsStatus.success:
            final stats = state.stats!;
            final overview = [
              StatsCardData(
                label: 'stats.clinics_total'.tr(),
                value: stats.clinicsTotal,
                icon: Icons.apartment_rounded,
                colors: _palettes[0],
              ),
              StatsCardData(
                label: 'stats.doctors_total'.tr(),
                value: stats.doctorsTotal,
                icon: Icons.medical_information_rounded,
                colors: _palettes[1],
              ),
              StatsCardData(
                label: 'stats.services_total'.tr(),
                value: stats.serviceOfferingsTotal,
                icon: Icons.medical_services_rounded,
                colors: _palettes[2],
              ),
              StatsCardData(
                label: 'stats.appointments_total'.tr(),
                value: stats.appointments.total,
                icon: Icons.calendar_today_rounded,
                colors: _palettes[3],
              ),
            ];
            final byStatus = [
              StatsCardData(
                label: 'stats.status_pending'.tr(),
                value: stats.appointments.status('pending'),
                icon: Icons.hourglass_top_rounded,
                colors: _palettes[4],
              ),
              StatsCardData(
                label: 'stats.status_confirmed'.tr(),
                value: stats.appointments.status('confirmed'),
                icon: Icons.check_circle_rounded,
                colors: _palettes[5],
              ),
              StatsCardData(
                label: 'stats.status_completed'.tr(),
                value: stats.appointments.status('completed'),
                icon: Icons.verified_rounded,
                colors: _palettes[6],
              ),
              StatsCardData(
                label: 'stats.status_cancelled'.tr(),
                value: stats.appointments.status('cancelled'),
                icon: Icons.cancel_rounded,
                colors: _palettes[7],
              ),
            ];
            final byType = [
              StatsCardData(
                label: 'stats.type_in_person'.tr(),
                value: stats.appointments.type('inPerson'),
                icon: Icons.local_hospital_rounded,
                colors: _palettes[2],
              ),
              StatsCardData(
                label: 'stats.type_teleconsultation'.tr(),
                value: stats.appointments.type('teleconsultation'),
                icon: Icons.video_call_rounded,
                colors: _palettes[3],
              ),
            ];

            return RefreshIndicator(
              onRefresh: () => context.read<HospitalStatsCubit>().load(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatsSectionHeader(
                      title: 'stats.overview'.tr(),
                      icon: Icons.dashboard_customize_rounded,
                    ),
                    const SizedBox(height: 16),
                    StatsGrid(
                      items: overview,
                      targetTileWidth: 210,
                      minColumns: 2,
                      maxColumns: 4,
                    ),
                    const SizedBox(height: 24),
                    StatsSectionHeader(
                      title: 'stats.appointments_by_status'.tr(),
                      icon: Icons.timeline_rounded,
                    ),
                    const SizedBox(height: 16),
                    StatsGrid(
                      items: byStatus,
                      targetTileWidth: 180,
                      minColumns: 2,
                      maxColumns: 4,
                    ),
                    const SizedBox(height: 24),
                    StatsSectionHeader(
                      title: 'stats.appointments_by_type'.tr(),
                      icon: Icons.pie_chart_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    StatsGrid(
                      items: byType,
                      targetTileWidth: 200,
                      minColumns: 2,
                      maxColumns: 2,
                    ),
                  ],
                ),
              ),
            );
          case HospitalStatsStatus.initial:
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
