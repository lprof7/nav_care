import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/core/routing/app_router.dart';
import 'package:nav_care_offers_app/data/authentication/signup/models/signup_request.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/signup/viewmodel/signup_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/colors.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_text_field.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/social_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/password_field.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/phone_number_field.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SignupCubit>(),
      child: const _SignupView(),
    );
  }
}

class _SignupView extends StatelessWidget {
  const _SignupView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final gradientColors = isDarkMode
        ? const [AppColors.gradientDarkStart, AppColors.gradientDarkEnd]
        : const [AppColors.gradientLightStart, AppColors.gradientLightEnd];
    final cardColor = isDarkMode ? AppColors.cardDark : AppColors.card;
    final boxShadowColor =
        AppColors.shadow.withOpacity(isDarkMode ? 0.35 : 0.08);

    return Scaffold(
      backgroundColor: gradientColors.first,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: boxShadowColor,
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: BlocListener<SignupCubit, SignupState>(
                    listener: (context, state) {
                      if (state is SignupSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('signup_success_message'.tr()),
                          ),
                        );
                        final user = state.result.user;
                        if (user != null) {
                          context
                              .read<AuthCubit>()
                              .setAuthenticatedUser(user, isDoctorOverride: false);
                          context.go(AppRoute.home.path);
                        } else {
                          context.go(AppRoute.home.path);
                        }
                      } else if (state is SignupFailure) {
                        final resolvedMessage = state.message.startsWith('signup_')
                            ? state.message.tr()
                            : state.message;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'signup_error_message'.tr(
                                namedArgs: {'message': resolvedMessage},
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: const _SignupForm(),
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

class _SignupForm extends StatefulWidget {
  const _SignupForm();

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedCountry;

  bool _minLength = false;
  bool _hasUpper = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  DateTime? _selectedBirthDate;
  String? _completePhoneNumber;
  XFile? _profileImage;
  bool _acceptTerms = false;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacyPolicy;
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final password = _passwordController.text;
    setState(() {
      _minLength = password.length >= 8;
      _hasUpper = RegExp(r'[A-Z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate =
        _selectedBirthDate ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text =
            DateFormat.yMMMMd(context.locale.toLanguageTag()).format(picked);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _profileImage = picked;
      });
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('passwords_do_not_match'.tr())),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('accept_terms_error'.tr())),
      );
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final name = [firstName, lastName]
        .where((value) => value.isNotEmpty)
        .join(' ')
        .trim();

    final phoneNumber = _ensureAlgerianPhone(
      _completePhoneNumber ?? _phoneController.text.trim(),
    );

    final request = SignupRequest(
      name: name.isEmpty ? _emailController.text.trim() : name,
      email: _emailController.text.trim(),
      phone: phoneNumber,
      password: _passwordController.text,
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      birthDate: _selectedBirthDate?.toIso8601String(),
      file: _profileImage,
    );

    context.read<SignupCubit>().signup(request);
  }

  String _ensureAlgerianPhone(String input) {
    final sanitized = input.replaceAll(RegExp(r'[^0-9+]'), '');
    if (sanitized.startsWith('+213')) {
      return sanitized;
    }
    final trimmed = sanitized.replaceFirst(RegExp(r'^\\+?213'), '');
    final withoutLeadingZeros = trimmed.replaceFirst(RegExp(r'^0+'), '');
    return '+213$withoutLeadingZeros';
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://www.nav-care.com/privacy-policy';
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('cannot_open_link'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;
    final headingColor =
        isDarkMode ? AppColors.textPrimaryDark : AppColors.headingPrimary;
    final secondaryTextColor =
        isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDarkMode ? AppColors.borderDark : AppColors.border;
    final surfaceColor =
        isDarkMode ? AppColors.surfaceDark : AppColors.neutral100;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'sign_up'.tr(),
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'sign_up_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileSection(
            textTheme,
            surfaceColor,
            borderColor,
            secondaryTextColor,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  hintText: 'first_name'.tr(),
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  validator: _requiredValidator,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  hintText: 'last_name'.tr(),
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            hintText: 'email'.tr(),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'field_required'.tr();
              }
              if (RegExp(r'^[^@]+@[^@]+\\.[a-zA-Z]{2,}\$').hasMatch(value)) {
                return 'invalid_email_format'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  hintText: 'birth_date_hint'.tr(),
                  controller: _birthDateController,
                  readOnly: true,
                  onTap: _selectBirthDate,
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PhoneNumberField(
            controller: _phoneController,
            labelText: 'phone_number'.tr(),
            onChanged: (value) => _completePhoneNumber = value,
            validator: (value) {
              final trimmed = value!.trim();
              if (trimmed.isEmpty) {
                return 'field_required'.tr();
              }
              if (!trimmed.startsWith('+213')) {
                return 'algerian_phone_error'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            hintText: 'address'.tr(),
            controller: _addressController,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  hintText: 'city'.tr(),
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  validator: _requiredValidator,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  hintText: 'state'.tr(),
                  controller: _stateController,
                  textCapitalization: TextCapitalization.words,
                  validator: _requiredValidator,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCountry,
            decoration: InputDecoration(
              hintText: 'country'.tr(),
            ),
            isExpanded: true,
            items: _countries
                .map(
                  (country) => DropdownMenuItem<String>(
                    value: country,
                    child: Text(
                      country,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountry = value;
                _countryController.text = value ?? '';
              });
            },
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'field_required'.tr() : null,
          ),
          const SizedBox(height: 16),
          PasswordField(
            hintText: 'password'.tr(),
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'profile.password_new'.tr();
              }
              if (value.length < 8) return 'profile.password_invalid'.tr();
              if (!_hasUpper || !_hasNumber || !_hasSpecial) {
                return 'profile.password_invalid'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _PasswordRequirements(
            minLength: _minLength,
            hasUpper: _hasUpper,
            hasNumber: _hasNumber,
            hasSpecial: _hasSpecial,
          ),
          const SizedBox(height: 16),
          PasswordField(
            hintText: 'confirm_password'.tr(),
            controller: _confirmPasswordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'profile.confirm_password_required'.tr();
              }
              if (value != _passwordController.text) {
                return 'profile.password_mismatch'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                    ),
                    children: [
                      TextSpan(text: '${'i_accept'.tr()} '),
                      TextSpan(
                        text: 'terms_and_policy'.tr(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: _privacyRecognizer,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<SignupCubit, SignupState>(
            builder: (context, state) {
              final isLoading = state is SignupLoading;
              return AppButton(
                text: 'sign_up'.tr(),
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textOnPrimary,
                          ),
                        ),
                      )
                    : null,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'already_have_account'.tr(),
                style: textTheme.bodyMedium?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoute.signIn.path),
                child: Text(
                  'sign_in'.tr(),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: borderColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or'.tr(),
                  style: textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ),
              Expanded(child: Divider(color: borderColor)),
            ],
          ),
          const SizedBox(height: 16),
          SocialButton(
            text: 'sign_up_with_google'.tr(),
            color: AppColors.brandGoogle,
            textColor: AppColors.textOnPrimary,
            onPressed: () {},
            icon: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card,
              ),
              alignment: Alignment.center,
              child: const Text(
                'G',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandGoogleAccent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SocialButton(
            text: 'sign_up_with_apple'.tr(),
            color: AppColors.brandApple,
            textColor: AppColors.textOnPrimary,
            onPressed: () {},
            icon: const Icon(
              Icons.apple,
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    TextTheme textTheme,
    Color surfaceColor,
    Color borderColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'upload_profile_picture'.tr(),
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickProfileImage,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profileImage?.name ?? 'upload_profile_picture'.tr(),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profileImage != null
                            ? 'change_photo'.tr()
                            : 'upload_photo_hint'.tr(),
                        style: textTheme.bodySmall?.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        if (_profileImage != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _profileImage = null;
                });
              },
              child: Text('remove_photo'.tr()),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    if (_profileImage == null) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primary.withOpacity(0.08),
        child: const Icon(
          Icons.person_outline,
          color: AppColors.primary,
        ),
      );
    }
    if (kIsWeb) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: const Icon(
          Icons.insert_photo_outlined,
          color: AppColors.primary,
        ),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundImage: FileImage(File(_profileImage!.path)),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'field_required'.tr();
    }
    return null;
  }
}

const List<String> _countries = [
  'Algeria',
  'Argentina',
  'Australia',
  'Austria',
  'Bahrain',
  'Bangladesh',
  'Belgium',
  'Brazil',
  'Canada',
  'Chile',
  'China',
  'Colombia',
  'Cote dIvoire',
  'Czech Republic',
  'Denmark',
  'Egypt',
  'Finland',
  'France',
  'Germany',
  'Ghana',
  'Greece',
  'Hungary',
  'India',
  'Indonesia',
  'Ireland',
  'Italy',
  'Japan',
  'Jordan',
  'Kenya',
  'Kuwait',
  'Lebanon',
  'Malaysia',
  'Mexico',
  'Morocco',
  'Netherlands',
  'New Zealand',
  'Nigeria',
  'Norway',
  'Oman',
  'Pakistan',
  'Philippines',
  'Poland',
  'Portugal',
  'Qatar',
  'Romania',
  'Saudi Arabia',
  'Singapore',
  'South Africa',
  'South Korea',
  'Spain',
  'Sweden',
  'Switzerland',
  'Tunisia',
  'Turkey',
  'Ukraine',
  'United Arab Emirates',
  'United Kingdom',
  'United States',
  'Vietnam',
];

class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements({
    required this.minLength,
    required this.hasUpper,
    required this.hasNumber,
    required this.hasSpecial,
  });

  final bool minLength;
  final bool hasUpper;
  final bool hasNumber;
  final bool hasSpecial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile.password_requirements_title'.tr(),
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _RequirementRow(
          text: 'profile.password_requirement_length'.tr(),
          met: minLength,
        ),
        _RequirementRow(
          text: 'profile.password_requirement_upper'.tr(),
          met: hasUpper,
        ),
        _RequirementRow(
          text: 'profile.password_requirement_number'.tr(),
          met: hasNumber,
        ),
        _RequirementRow(
          text: 'profile.password_requirement_special'.tr(),
          met: hasSpecial,
        ),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.text, required this.met});

  final String text;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final icon = met ? Icons.check_circle : Icons.radio_button_unchecked;
    final color = met ? AppColors.primary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
