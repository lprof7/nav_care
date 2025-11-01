import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/presentation/features/hospitals/hospital_creation/viewmodel/hospital_creation_cubit.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_text_field.dart';

class AddHospitalPage extends StatefulWidget {
  const AddHospitalPage({super.key});

  @override
  State<AddHospitalPage> createState() => _AddHospitalPageState();
}

class _AddHospitalPageState extends State<AddHospitalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _facilityTypes = const ['Clinic', 'Hospital', 'Center'];
  final _imagePicker = ImagePicker();

  final List<TextEditingController> _phoneControllers = [
    TextEditingController(),
  ];

  XFile? _selectedFile;
  String? _selectedFacilityType;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    for (final controller in _phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedFile = picked);
    }
  }

  void _addPhoneField() {
    setState(() {
      _phoneControllers.add(TextEditingController());
    });
  }

  void _removePhoneField(int index) {
    if (_phoneControllers.length == 1) return;
    setState(() {
      final controller = _phoneControllers.removeAt(index);
      controller.dispose();
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final phones = _phoneControllers
        .map((c) => c.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (phones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide at least one phone number')),
      );
      return;
    }

    if (_selectedFacilityType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select facility type')),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a related file')),
      );
      return;
    }

    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid coordinates')),
      );
      return;
    }

    final body = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'facility_type': _selectedFacilityType!,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'phone': phones,
      'file': _selectedFile,
    };

    context.read<HospitalCreationCubit>().createHospital(body);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HospitalCreationCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF1FF),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEFF1FF),
                  Color(0xFFF9F9FF),
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: BlocConsumer<HospitalCreationCubit,
                        HospitalCreationState>(
                      listener: (context, state) {
                        if (state is HospitalCreationFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        } else if (state is HospitalCreationSuccess) {
                          final router = GoRouter.of(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.result.message)),
                          );
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (mounted) {
                              router.pop(state.result);
                            }
                          });
                        }
                      },
                      builder: (context, state) {
                        final isLoading = state is HospitalCreationLoading;
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Add Hospital / Clinic',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2D3B66),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Fill in the details for the new healthcare facility.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 24),
                              AppTextField(
                                controller: _nameController,
                                hintText: 'Facility name',
                                textCapitalization: TextCapitalization.words,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _descriptionController,
                                hintText: 'Description',
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedFacilityType,
                                items: _facilityTypes
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ),
                                    )
                                    .toList(),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Facility type',
                                ),
                                onChanged: (value) {
                                  setState(() => _selectedFacilityType = value);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller: _latitudeController,
                                      hintText: 'Latitude',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        if (double.tryParse(value.trim()) ==
                                            null) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppTextField(
                                      controller: _longitudeController,
                                      hintText: 'Longitude',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        if (double.tryParse(value.trim()) ==
                                            null) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Phone numbers',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              ...List.generate(_phoneControllers.length,
                                  (index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom:
                                          index == _phoneControllers.length - 1
                                              ? 0
                                              : 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          controller: _phoneControllers[index],
                                          hintText: 'Phone number',
                                          keyboardType: TextInputType.phone,
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        onPressed: () =>
                                            _removePhoneField(index),
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _addPhoneField,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add phone'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _pickFile,
                                icon: const Icon(Icons.cloud_upload_outlined),
                                label: Text(
                                  _selectedFile == null
                                      ? 'Upload related image / document'
                                      : _selectedFile!.name,
                                ),
                              ),
                              const SizedBox(height: 24),
                              AppButton(
                                text: isLoading
                                    ? 'Submitting...'
                                    : 'Create facility',
                                onPressed: isLoading ? null : _submit,
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
