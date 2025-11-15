import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/appointments/models/appointment_model.dart';
import 'package:nav_care_offers_app/presentation/features/appointments/viewmodel/appointments_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/appointments/viewmodel/appointments_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/appointment_card.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AppointmentsCubit>()..getMyDoctorAppointments(),
      child: const _AppointmentsListView(),
    );
  }
}

class _AppointmentsListView extends StatelessWidget {
  const _AppointmentsListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'home.appointments.title'.tr(),
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'home.appointments.subtitle'.tr(),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocConsumer<AppointmentsCubit, AppointmentsState>(
                listener: (context, state) {
                  state.whenOrNull(
                    updateSuccess: (_, __) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'appointments.messages.update_success'.tr(),
                          ),
                        ),
                      );
                    },
                    updateFailure: (_, failure) {
                      final fallback =
                          'appointments.messages.update_failure'.tr();
                      final message = failure.message.isNotEmpty
                          ? failure.message
                          : fallback;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    },
                  );
                },
                builder: (context, state) {
                  final cubit = context.read<AppointmentsCubit>();
                  return state.when(
                    initial: () =>
                        const Center(child: CircularProgressIndicator()),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    success: (appointmentList) => _AppointmentsList(
                      appointmentList: appointmentList,
                      isProcessing: false,
                      onRefresh: () => cubit.getMyDoctorAppointments(),
                      onAppointmentTap: (appointment) =>
                          _showAppointmentEditor(context, appointment),
                    ),
                    failure: (failure) => _ErrorView(
                      message: failure.message ?? 'unknown_error'.tr(),
                      onRetry: () => cubit.getMyDoctorAppointments(),
                    ),
                    processing: (appointmentList) => _AppointmentsList(
                      appointmentList: appointmentList,
                      isProcessing: true,
                      onRefresh: () => cubit.getMyDoctorAppointments(),
                      onAppointmentTap: (appointment) =>
                          _showAppointmentEditor(context, appointment),
                    ),
                    updateSuccess: (appointmentList, _) => _AppointmentsList(
                      appointmentList: appointmentList,
                      isProcessing: false,
                      onRefresh: () => cubit.getMyDoctorAppointments(),
                      onAppointmentTap: (appointment) =>
                          _showAppointmentEditor(context, appointment),
                    ),
                    updateFailure: (appointmentList, __) => _AppointmentsList(
                      appointmentList: appointmentList,
                      isProcessing: false,
                      onRefresh: () => cubit.getMyDoctorAppointments(),
                      onAppointmentTap: (appointment) =>
                          _showAppointmentEditor(context, appointment),
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

class _AppointmentsList extends StatelessWidget {
  final AppointmentListModel appointmentList;
  final bool isProcessing;
  final Future<void> Function() onRefresh;
  final void Function(AppointmentModel) onAppointmentTap;

  const _AppointmentsList({
    required this.appointmentList,
    required this.isProcessing,
    required this.onRefresh,
    required this.onAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (appointmentList.appointments.isEmpty) {
      return _EmptyView(
        messageKey: 'home.appointments.empty',
        onReload: () {
          onRefresh();
        },
      );
    }

    final listView = RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (ctx, index) {
          final appointment = appointmentList.appointments[index];
          return AppointmentCard(
            appointment: appointment,
            onTap: () => onAppointmentTap(appointment),
          );
        },
        separatorBuilder: (ctx, _) => const SizedBox(height: 20),
        itemCount: appointmentList.appointments.length,
      ),
    );

    if (!isProcessing) return listView;

    return Stack(
      children: [
        listView,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: LinearProgressIndicator(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String messageKey;
  final VoidCallback onReload;

  const _EmptyView({
    required this.messageKey,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              messageKey.tr(),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('hospitals.actions.reload'.tr()),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayMessage =
        message.startsWith('hospitals.') ? message.tr() : message;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              displayMessage,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('hospitals.actions.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _AppointmentDateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}

Future<void> _showAppointmentEditor(
  BuildContext context,
  AppointmentModel appointment,
) async {
  final start = DateTime.tryParse(appointment.startTime);
  final end = DateTime.tryParse(appointment.endTime);

  if (start == null || end == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('appointments.validation.invalid_dates'.tr())),
    );
    return;
  }

  final cubit = context.read<AppointmentsCubit>();
  DateTime selectedStart = start.toLocal();
  DateTime selectedEnd = end.toLocal();
  String selectedStatus = appointment.status;
  final statuses = List<String>.from(_allowedAppointmentStatuses);
  if (!statuses.contains(selectedStatus)) {
    statuses.insert(0, selectedStatus);
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'appointments.edit.title'.tr(),
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _AppointmentDateField(
                    label: 'appointments.edit.start_label'.tr(),
                    value: _formatFieldDate(sheetContext, selectedStart),
                    onTap: () async {
                      final newDate =
                          await _pickDateTime(sheetContext, selectedStart);
                      if (newDate != null) {
                        setSheetState(() {
                          selectedStart = newDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _AppointmentDateField(
                    label: 'appointments.edit.end_label'.tr(),
                    value: _formatFieldDate(sheetContext, selectedEnd),
                    onTap: () async {
                      final newDate =
                          await _pickDateTime(sheetContext, selectedEnd);
                      if (newDate != null) {
                        setSheetState(() {
                          selectedEnd = newDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'appointments.edit.status_label'.tr(),
                    ),
                    items: statuses
                        .map((status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text('appointments.status.$status'.tr()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() {
                        selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: Text('appointments.edit.cancel'.tr()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (!selectedEnd.isAfter(selectedStart)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'appointments.validation.invalid_range'
                                        .tr(),
                                  ),
                                ),
                              );
                              return;
                            }

                            Navigator.of(sheetContext).pop();
                            cubit.updateAppointment(
                              appointmentId: appointment.id,
                              startTime: selectedStart.toUtc(),
                              endTime: selectedEnd.toUtc(),
                              status: selectedStatus,
                            );
                          },
                          child: Text('appointments.edit.submit'.tr()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<DateTime?> _pickDateTime(BuildContext context, DateTime initial) async {
  final firstDate = DateTime(initial.year - 1);
  final lastDate = DateTime(initial.year + 2);

  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: firstDate,
    lastDate: lastDate,
  );
  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
  );
  if (time == null) return null;

  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}

String _formatFieldDate(BuildContext context, DateTime dateTime) {
  final locale = context.locale.languageCode;
  final dateFormat = DateFormat.yMMMd(locale);
  final timeFormat = DateFormat.Hm(locale);
  return '${dateFormat.format(dateTime)} • ${timeFormat.format(dateTime)}';
}

const _allowedAppointmentStatuses = [
  'pending',
  'confirmed',
  'completed',
  'cancelled',
];
