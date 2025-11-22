import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/appointments/models/appointment_model.dart';
import 'package:nav_care_user_app/presentation/features/appointments/appointment_creation/view/appointment_success_page.dart';
import 'package:nav_care_user_app/presentation/features/appointments/appointment_creation/viewmodel/appointment_creation_cubit.dart';
import 'package:nav_care_user_app/presentation/features/appointments/appointment_creation/viewmodel/appointment_creation_state.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_text_field.dart';

class AddAppointmentPage extends StatefulWidget {
  final String serviceOfferingId;
  const AddAppointmentPage({super.key, required this.serviceOfferingId});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  late final TextEditingController _serviceOfferingController;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  String _selectedType = 'in_person';
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    _serviceOfferingController = TextEditingController(text: widget.serviceOfferingId);
  }

  @override
  void dispose() {
    _serviceOfferingController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context, bool isStartTime) async {
    final initialDate = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStartTime ? (_selectedStartTime ?? initialDate) : (_selectedEndTime ?? initialDate)),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartTime) {
            _selectedStartTime = selectedDateTime;
            _startTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
          } else {
            _selectedEndTime = selectedDateTime;
            _endTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AppointmentCreationCubit>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('add_appointment_page_title'.tr()),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            body: BlocConsumer<AppointmentCreationCubit, AppointmentCreationState>(
              listener: (context, state) {
                if (state.status == AppointmentCreationStatus.success) {
                  final message = state.successMessage?.isNotEmpty == true
                      ? state.successMessage!
                      : 'appointment_created_success'.tr();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AppointmentSuccessPage(
                        message: message,
                        onGoToAppointments: () => context.go('/appointments'),
                      ),
                    ),
                  );
                } else if (state.status == AppointmentCreationStatus.failure) {
                  final localizedMessage = (state.errorMessage != null &&
                          state.errorMessage!.isNotEmpty)
                      ? state.errorMessage!
                      : 'appointment_created_failure'.tr();
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('appointment_created_failure'.tr()),
                      content: Text(localizedMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('ok'.tr()),
                        ),
                      ],
                    ),
                  );
                }
              },
              builder: (context, state) {
                final theme = Theme.of(context);
                final colorScheme = theme.colorScheme;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withOpacity(0.14),
                              colorScheme.primary.withOpacity(0.04),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'appointments.form.heading'.tr(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'appointments.form.subtitle'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.blueGrey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'appointment_type_label'.tr(),
                                  border: const OutlineInputBorder(),
                                ),
                                value: _selectedType,
                                items: [
                                  DropdownMenuItem(value: 'in_person', child: Text('in_person_appointment'.tr())),
                                  DropdownMenuItem(value: 'virtual', child: Text('virtual_appointment'.tr())),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 14),
                              AppTextField(
                                controller: _startTimeController,
                                hintText: 'start_time_label'.tr(),
                                readOnly: true,
                                onTap: () => _pickDateTime(context, true),
                              ),
                              const SizedBox(height: 14),
                              AppTextField(
                                controller: _endTimeController,
                                hintText: 'end_time_label'.tr(),
                                readOnly: true,
                                onTap: () => _pickDateTime(context, false),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        onPressed:
                            state.status == AppointmentCreationStatus.loading ||
                                    _selectedStartTime == null ||
                                    _selectedEndTime == null
                                ? null
                                : () {
                                    if (_selectedStartTime != null &&
                                        _selectedEndTime != null &&
                                        !_selectedEndTime!.isAfter(
                                            _selectedStartTime!)) {
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
                                    final cubit = context.read<AppointmentCreationCubit>();
                                    final typeToSend =
                                        _selectedType == 'virtual' ? 'teleconsultation' : 'in_person';
                                    final newAppointment = AppointmentModel(
                                      serviceOffering: widget.serviceOfferingId,
                                      type: typeToSend,
                                      startTime: _selectedStartTime!.toUtc(),
                                      endTime: _selectedEndTime!.toUtc(),
                                      status: 'pending',
                                    );
                                    cubit.createAppointment(newAppointment);
                                  },
                        text: state.status == AppointmentCreationStatus.loading
                            ? 'loading'.tr()
                            : 'create_appointment_button'.tr(),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
