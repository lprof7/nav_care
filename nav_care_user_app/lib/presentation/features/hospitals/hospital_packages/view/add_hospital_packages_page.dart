import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/presentation/features/hospitals/hospital_packages/viewmodel/hospital_packages_cubit.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_text_field.dart';

class AddHospitalPackagesPage extends StatefulWidget {
  final String hospitalId;
  const AddHospitalPackagesPage({super.key, required this.hospitalId});

  @override
  State<AddHospitalPackagesPage> createState() =>
      _AddHospitalPackagesPageState();
}

class _AddHospitalPackagesPageState extends State<AddHospitalPackagesPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _nameControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _priceControllers = [
    TextEditingController()
  ];

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    for (final controller in _priceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPackageField() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _priceControllers.add(TextEditingController());
    });
  }

  void _removePackageField(int index) {
    if (_nameControllers.length == 1) return;
    setState(() {
      final nameController = _nameControllers.removeAt(index);
      final priceController = _priceControllers.removeAt(index);
      nameController.dispose();
      priceController.dispose();
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (widget.hospitalId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing hospital identifier')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final packages = <Map<String, dynamic>>[];
    for (var i = 0; i < _nameControllers.length; i++) {
      final name = _nameControllers[i].text.trim();
      final priceString = _priceControllers[i].text.trim();
      final price = double.tryParse(priceString);
      if (name.isEmpty || price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please review package #${i + 1}')),
        );
        return;
      }
      packages.add({'name': name, 'price': price});
    }

    context
        .read<HospitalPackagesCubit>()
        .addPackages(widget.hospitalId, {'packages': packages});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HospitalPackagesCubit>(),
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
                    child: BlocConsumer<HospitalPackagesCubit,
                        HospitalPackagesState>(
                      listener: (context, state) {
                        if (state is HospitalPackagesFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        } else if (state is HospitalPackagesSuccess) {
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
                        final isLoading = state is HospitalPackagesLoading;
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Add packages',
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
                                'Create one or more packages for this hospital.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 24),
                              ...List.generate(_nameControllers.length,
                                  (index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom:
                                          index == _nameControllers.length - 1
                                              ? 0
                                              : 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Package ${index + 1}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const Spacer(),
                                          if (_nameControllers.length > 1)
                                            IconButton(
                                              onPressed: () =>
                                                  _removePackageField(index),
                                              icon: const Icon(
                                                  Icons.remove_circle_outline),
                                            ),
                                        ],
                                      ),
                                      AppTextField(
                                        controller: _nameControllers[index],
                                        hintText: 'Package name',
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Required';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      AppTextField(
                                        controller: _priceControllers[index],
                                        hintText: 'Price',
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Required';
                                          }
                                          final parsed =
                                              double.tryParse(value.trim());
                                          if (parsed == null || parsed < 0) {
                                            return 'Enter a valid price';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _addPackageField,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add another package'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              AppButton(
                                text: isLoading
                                    ? 'Submitting...'
                                    : 'Save packages',
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
