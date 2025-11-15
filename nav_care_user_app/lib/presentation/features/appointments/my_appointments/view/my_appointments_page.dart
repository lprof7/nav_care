import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/appointments/models/user_appointment_model.dart';
import 'package:nav_care_user_app/presentation/features/appointments/my_appointments/viewmodel/my_appointments_cubit.dart';
import 'package:nav_care_user_app/presentation/features/appointments/my_appointments/viewmodel/my_appointments_state.dart';

class MyAppointmentsPage extends StatelessWidget {
  const MyAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyAppointmentsCubit>()..fetchAppointments(),
      child: const _MyAppointmentsView(),
    );
  }
}

class _MyAppointmentsView extends StatelessWidget {
  const _MyAppointmentsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'appointments.list.title'.tr(),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'appointments.list.subtitle'.tr(),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocConsumer<MyAppointmentsCubit, MyAppointmentsState>(
                listenWhen: (previous, current) =>
                    previous.actionId != current.actionId,
                listener: (context, state) {
                  if (state.actionStatus == AppointmentActionStatus.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('appointments.messages.update_success'.tr()),
                      ),
                    );
                  } else if (state.actionStatus ==
                      AppointmentActionStatus.failure) {
                    final fallback =
                        'appointments.messages.update_failure'.tr();
                    final errorMessage = state.actionError?.message;
                    final message =
                        (errorMessage != null && errorMessage.isNotEmpty)
                            ? errorMessage
                            : fallback;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
                builder: (context, state) {
                  final cubit = context.read<MyAppointmentsCubit>();
                  switch (state.status) {
                    case MyAppointmentsStatus.loading:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case MyAppointmentsStatus.failure:
                      final message = state.error?.message ??
                          'appointments.list.error'.tr();
                      return _AppointmentsError(
                        message: message,
                        onRetry: cubit.fetchAppointments,
                      );
                    case MyAppointmentsStatus.success:
                      final list = state.appointments;
                      if (list == null) {
                        return _AppointmentsEmpty(
                          onReload: cubit.fetchAppointments,
                        );
                      }
                      return _UserAppointmentsList(
                        appointments: list.appointments,
                        isProcessing: state.isProcessing,
                        onRefresh: cubit.refreshAppointments,
                        onAppointmentTap: (appointment) =>
                            _showUserAppointmentEditor(context, appointment),
                      );
                    case MyAppointmentsStatus.initial:
                    default:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAppointmentsList extends StatelessWidget {
  final List<UserAppointmentModel> appointments;
  final bool isProcessing;
  final Future<void> Function() onRefresh;
  final void Function(UserAppointmentModel) onAppointmentTap;

  const _UserAppointmentsList({
    required this.appointments,
    required this.isProcessing,
    required this.onRefresh,
    required this.onAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return _AppointmentsEmpty(onReload: onRefresh);
    }

    final listView = RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                appointment.serviceName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    appointment.providerName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatAppointmentRange(
                        context, appointment.startTime, appointment.endTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: SizedBox(
                height: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(
                      label: Text(
                        'appointments.status.'.tr(),
                      ),
                    ),
                    if (appointment.price != null)
                      Text(
                        NumberFormat.simpleCurrency(
                          locale: context.locale.toLanguageTag(),
                        ).format(appointment.price),
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              onTap: () => onAppointmentTap(appointment),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: appointments.length,
      ),
    );

    if (!isProcessing) return listView;

    return Stack(
      children: [
        listView,
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: LinearProgressIndicator(),
        ),
      ],
    );
  }
}

class _AppointmentsEmpty extends StatelessWidget {
  final Future<void> Function() onReload;

  const _AppointmentsEmpty({required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'appointments.list.empty'.tr(),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              onReload();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text('appointments.list.reload'.tr()),
          ),
        ],
      ),
    );
  }
}

class _AppointmentsError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _AppointmentsError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              onRetry();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text('appointments.list.retry'.tr()),
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

String _localizedMessage(String? value, String fallbackKey) {
  if (value == null || value.isEmpty) {
    return fallbackKey.tr();
  }
  final localized = value.tr();
  return localized != value ? localized : value;
}

Future<void> _showUserAppointmentEditor(
  BuildContext context,
  UserAppointmentModel appointment,
) async {
  final cubit = context.read<MyAppointmentsCubit>();
  DateTime start = appointment.startTime.toLocal();
  DateTime end = appointment.endTime.toLocal();
  String status = appointment.status;
  final statuses = <String>[status];
  for (final option in _userStatusOptions) {
    if (!statuses.contains(option)) {
      statuses.add(option);
    }
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
                  value: _formatFieldDate(sheetContext, start),
                  onTap: () async {
                    final newDate = await _pickDateTime(sheetContext, start);
                    if (newDate != null) {
                      setSheetState(() {
                        start = newDate;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                _AppointmentDateField(
                  label: 'appointments.edit.end_label'.tr(),
                  value: _formatFieldDate(sheetContext, end),
                  onTap: () async {
                    final newDate = await _pickDateTime(sheetContext, end);
                    if (newDate != null) {
                      setSheetState(() {
                        end = newDate;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  items: statuses
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text('appointments.status.'.tr()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() {
                        status = value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'appointments.edit.status_label'.tr(),
                  ),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (!end.isAfter(start)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'appointments.validation.invalid_range'.tr(),
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.of(sheetContext).pop();
                          cubit.updateAppointment(
                            appointmentId: appointment.id,
                            startTime: start.toUtc(),
                            endTime: end.toUtc(),
                            status:
                                status == appointment.status ? null : status,
                          );
                        },
                        child: Text('appointments.edit.submit'.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<DateTime?> _pickDateTime(BuildContext context, DateTime initial) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: initial.subtract(const Duration(days: 365)),
    lastDate: initial.add(const Duration(days: 365 * 2)),
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

String _formatAppointmentRange(
  BuildContext context,
  DateTime start,
  DateTime end,
) {
  final locale = context.locale.languageCode;
  final dateFormat = DateFormat.yMMMd(locale);
  final timeFormat = DateFormat.Hm(locale);
  return ' ??? \n ??? ';
}

String _formatFieldDate(BuildContext context, DateTime dateTime) {
  final locale = context.locale.languageCode;
  final dateFormat = DateFormat.yMMMd(locale);
  final timeFormat = DateFormat.Hm(locale);
  return ' ??? ';
}

const _userStatusOptions = ['cancelled'];
