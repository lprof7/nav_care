import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui; // Added import
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/become_doctor/viewmodel/become_doctor_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/colors.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_text_field.dart';

class BecomeDoctorPage extends StatelessWidget {
  final User? user;

  const BecomeDoctorPage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BecomeDoctorCubit>(),
      child: _BecomeDoctorView(user: user),
    );
  }
}

class _BecomeDoctorView extends StatefulWidget {
  const _BecomeDoctorView({required this.user});

  final User? user;

  @override
  State<_BecomeDoctorView> createState() => _BecomeDoctorViewState();
}

class _BecomeDoctorViewState extends State<_BecomeDoctorView> {
  final _formKey = GlobalKey<FormState>();
  final _bioEnController = TextEditingController();
  final _bioArController = TextEditingController(); // Added Ar
  final _bioFrController = TextEditingController(); // Added Fr
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _showTranslationFields = false; // Added toggle

  @override
  void dispose() {
    _bioEnController.dispose();
    _bioArController.dispose(); // Added dispose
    _bioFrController.dispose(); // Added dispose
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  void _submit(BuildContext context, bool isSubmitting) {
    if (isSubmitting) return;
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('become_doctor_image_required'.tr())),
      );
      return;
    }

    context.read<BecomeDoctorCubit>().submit(
          bioEn: _bioEnController.text.trim(),
          bioAr: _bioArController.text.trim().isEmpty
              ? null
              : _bioArController.text.trim(),
          bioFr: _bioFrController.text.trim().isEmpty
              ? null
              : _bioFrController.text.trim(),
          image: _selectedImage,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final headingColor =
        isDarkMode ? AppColors.textPrimaryDark : AppColors.headingPrimary;
    final bodyColor =
        isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final cardColor = isDarkMode ? AppColors.cardDark : AppColors.card;
    final shadowColor = AppColors.shadow.withOpacity(isDarkMode ? 0.32 : 0.08);
    final accentColor = theme.colorScheme.primary;
    final name = widget.user?.name ?? 'become_doctor_default_name'.tr();

    return BlocConsumer<BecomeDoctorCubit, BecomeDoctorState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        } else if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('become_doctor_success'.tr())),
          );
          context.go('/home');
        }
      },
      builder: (context, state) {
        final isSubmitting = state.isSubmitting;
        return Scaffold(
          appBar: AppBar(
            title: Text('become_doctor_title'.tr()),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'become_doctor_heading'.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: headingColor,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'become_doctor_description'
                            .tr(namedArgs: {'name': name}),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: bodyColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'become_doctor_next_steps'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: bodyColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor,
                              blurRadius: 30,
                              offset: const Offset(0, 16),
                            ),
                          ],
                          border: Border.all(
                            color: (isDarkMode
                                    ? AppColors.borderDark
                                    : AppColors.border)
                                .withOpacity(0.4),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'become_doctor_image_label'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: headingColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ImagePickerField(
                                image: _selectedImage,
                                onPick: isSubmitting ? null : _pickImage,
                                accent: accentColor,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'become_doctor_bio_label'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: headingColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              AppTextField(
                                controller: _bioEnController,
                                hintText: 'become_doctor_bio_hint'.tr(),
                                maxLines: 4,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'field_required'.tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              // Advanced Translations
                              Theme(
                                data: Theme.of(context)
                                    .copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  tilePadding: EdgeInsets.zero,
                                  title: Text(
                                    'become_doctor_bio_translations'.tr(),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: headingColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  initiallyExpanded: _showTranslationFields,
                                  onExpansionChanged: (expanded) {
                                    setState(() =>
                                        _showTranslationFields = expanded);
                                  },
                                  children: [
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: _bioArController,
                                      hintText:
                                          'become_doctor_bio_ar_hint'.tr(),
                                      maxLines: 4,
                                      textDirection: ui.TextDirection.rtl,
                                    ),
                                    const SizedBox(height: 12),
                                    AppTextField(
                                      controller: _bioFrController,
                                      hintText:
                                          'become_doctor_bio_fr_hint'.tr(),
                                      maxLines: 4,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              AppButton(
                                text: isSubmitting
                                    ? 'become_doctor_submitting'.tr()
                                    : 'become_doctor_submit'.tr(),
                                onPressed: () => _submit(context, isSubmitting),
                                icon: isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColors.textOnPrimary,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.check_circle_outline,
                                        color: AppColors.textOnPrimary),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => context.go('/signin'),
                                child:
                                    Text('become_doctor_back_to_signin'.tr()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({
    required this.image,
    required this.onPick,
    required this.accent,
  });

  final XFile? image;
  final VoidCallback? onPick;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.65);

    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.1),
          color: isDark ? AppColors.surfaceDark : AppColors.neutral200,
        ),
        clipBehavior: Clip.hardEdge,
        child: image != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(image!.path),
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_rounded,
                      color: accent,
                      size: 32,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'become_doctor_image_hint'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(isDark ? 0.85 : 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'become_doctor_image_cta'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
