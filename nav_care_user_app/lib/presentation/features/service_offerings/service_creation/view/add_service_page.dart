import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/service_creation/viewmodel/service_creation_cubit.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_text_field.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameFrController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  XFile? _selectedImage;

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameFrController.dispose();
    _nameArController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedImage = picked);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service image')),
      );
      return;
    }

    final body = {
      'name_en': _nameEnController.text.trim(),
      'name_fr': _nameFrController.text.trim(),
      'name_ar': _nameArController.text.trim(),
      'description': _descriptionController.text.trim(),
      'file': _selectedImage,
    };

    context.read<ServiceCreationCubit>().createService(body);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ServiceCreationCubit>(),
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
                  constraints: const BoxConstraints(maxWidth: 460),
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
                    child: BlocConsumer<ServiceCreationCubit,
                        ServiceCreationState>(
                      listener: (context, state) {
                        if (state is ServiceCreationFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        } else if (state is ServiceCreationSuccess) {
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
                        final isLoading = state is ServiceCreationLoading;
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Add Service',
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
                                'Provide details for the new service offering',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 24),
                              AppTextField(
                                controller: _nameEnController,
                                hintText: 'Service name (English)',
                                textCapitalization: TextCapitalization.words,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Max 255 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _nameFrController,
                                hintText: 'Service name (French)',
                                textCapitalization: TextCapitalization.words,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Max 255 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _nameArController,
                                hintText: 'Service name (Arabic)',
                                textCapitalization: TextCapitalization.words,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Max 255 characters';
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
                                  if (value.trim().length > 1000) {
                                    return 'Max 1000 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.cloud_upload_outlined),
                                label: Text(
                                  _selectedImage == null
                                      ? 'Upload service image'
                                      : _selectedImage!.name,
                                ),
                              ),
                              const SizedBox(height: 24),
                              AppButton(
                                text: isLoading
                                    ? 'Submitting...'
                                    : 'Create Service',
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
