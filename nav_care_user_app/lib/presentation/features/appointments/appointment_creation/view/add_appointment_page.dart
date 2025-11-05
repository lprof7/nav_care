import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/appointments/models/appointment_model.dart';
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
  String _selectedStatus = 'pending';
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('appointment_created_success'.tr())),
                  );
                  context.pop(); // Go back after successful creation
                } else if (state.status == AppointmentCreationStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage ?? 'appointment_created_failure'.tr())),
                  );
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // Type Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'appointment_type_label'.tr(),
                          border: const OutlineInputBorder(),
                        ),
                        value: _selectedType,
                        items: const [
                          DropdownMenuItem(value: 'in_person', child: Text('In Person')),
                          DropdownMenuItem(value: 'virtual', child: Text('Virtual')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Start Time Picker
                      AppTextField(
                        controller: _startTimeController,
                        hintText: 'start_time_label'.tr(),
                        readOnly: true,
                        onTap: () => _pickDateTime(context, true),
                      ),
                      const SizedBox(height: 16.0),

                      // End Time Picker
                      AppTextField(
                        controller: _endTimeController,
                        hintText: 'end_time_label'.tr(),
                        readOnly: true,
                        onTap: () => _pickDateTime(context, false),
                      ),
                      const SizedBox(height: 16.0),

                      const SizedBox(height: 32.0),

                      AppButton(
                        onPressed: state.status == AppointmentCreationStatus.loading ||
                                _selectedStartTime == null ||
                                _selectedEndTime == null
                            ? null
                            : () {
                                final cubit = context.read<AppointmentCreationCubit>();
                                final newAppointment = AppointmentModel(
                                  serviceOffering: widget.serviceOfferingId,
                                  type: _selectedType,
                                  startTime: _selectedStartTime!,
                                  endTime: _selectedEndTime!,
                                  status: 'pending', // Hardcoded to pending
                                );
                                cubit.createAppointment(newAppointment);
                              },
                      text: state.status == AppointmentCreationStatus.loading
                          ? 'loading'.tr() // Use a translated loading text
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