import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_cubit.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_state.dart';
import 'package:nav_care_user_app/presentation/shared/theme/colors.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_button.dart';

class EditUserProfilePage extends StatefulWidget {
  const EditUserProfilePage({super.key});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  XFile? _pickedImage;
  String? _avatarUrl;
  bool _didPrefill = false;

  late final TextEditingController _firstNameCtl;
  late final TextEditingController _lastNameCtl;
  late final TextEditingController _emailCtl;
  late final TextEditingController _phoneCtl;
  late final TextEditingController _addressCtl;
  late final TextEditingController _cityCtl;
  late final TextEditingController _stateCtl;
  late final TextEditingController _countryCtl;
  late final TextEditingController _countrySearchController;
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _firstNameCtl = TextEditingController();
    _lastNameCtl = TextEditingController();
    _emailCtl = TextEditingController();
    _phoneCtl = TextEditingController();
    _addressCtl = TextEditingController();
    _cityCtl = TextEditingController();
    _stateCtl = TextEditingController();
    _countryCtl = TextEditingController();
    _countrySearchController = TextEditingController();

    _prefillIfNeeded(context.read<UserProfileCubit>().state);
  }

  @override
  void dispose() {
    _firstNameCtl.dispose();
    _lastNameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _addressCtl.dispose();
    _cityCtl.dispose();
    _stateCtl.dispose();
    _countryCtl.dispose();
    _countrySearchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 78,
    );
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  ImageProvider? _avatarImageProvider() {
    if (_pickedImage != null) {
      return FileImage(File(_pickedImage!.path));
    }
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return NetworkImage(_avatarUrl!);
    }
    return null;
  }

  void _prefillIfNeeded(UserProfileState state) {
    if (_didPrefill) return;
    final profile = state.profile;
    if (profile == null) return;

    final appConfig = sl<AppConfig>();
    final avatar = profile.avatarUrl(appConfig.api.baseUrl);
    final nameParts = (profile.name).trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    setState(() {
      _avatarUrl = avatar;
      _firstNameCtl.text = firstName;
      _lastNameCtl.text = lastName;
      _emailCtl.text = profile.email;
      _phoneCtl.text = profile.phone ?? '';
      _addressCtl.text = profile.address ?? '';
      _cityCtl.text = profile.city ?? '';
      _stateCtl.text = profile.state ?? '';
      _applyCountry(profile.country, context.locale.languageCode);
      _didPrefill = true;
    });
  }

  void _applyCountry(String? value, String languageCode) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      _selectedCountry = null;
      _countryCtl.text = '';
      return;
    }

    final normalized = raw.toLowerCase();
    final match = countries.firstWhere(
      (country) =>
          country.name.toLowerCase() == normalized ||
          country.localizedName(languageCode).toLowerCase() == normalized,
      orElse: () => countries.first,
    );

    if (match.name.toLowerCase() == normalized ||
        match.localizedName(languageCode).toLowerCase() == normalized) {
      _selectedCountry = match;
      _countryCtl.text = match.name;
    } else {
      _selectedCountry = null;
      _countryCtl.text = raw;
    }
  }

  Future<void> _pickCountry() async {
    final result = await showDialog<Country>(
      context: context,
      builder: (dialogContext) {
        var filtered = countries.toList(growable: false);
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text('country'.tr()),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _countrySearchController,
                      decoration: InputDecoration(
                        hintText: 'shell.nav_search'.tr(),
                      ),
                      onChanged: (value) {
                        final query = value.trim().toLowerCase();
                        filtered = query.isEmpty
                            ? countries.toList(growable: false)
                            : countries
                                .where((country) => country
                                    .localizedName(context.locale.languageCode)
                                    .toLowerCase()
                                    .contains(query))
                                .toList(growable: false);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (listCtx, index) {
                          final country = filtered[index];
                          return ListTile(
                            leading: Text(
                              country.flag,
                              style: const TextStyle(fontSize: 18),
                            ),
                            title: Text(
                              country.localizedName(
                                context.locale.languageCode,
                              ),
                            ),
                            trailing: Text('+${country.dialCode}'),
                            onTap: () => Navigator.of(ctx).pop(country),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCountry = result;
        _countryCtl.text = result.name;
      });
    }
    _countrySearchController.clear();
  }

  void _submit(BuildContext context, bool isUpdating) {
    if (isUpdating) return;
    if (_formKey.currentState?.validate() != true) return;

    final fullName = '${_firstNameCtl.text.trim()} ${_lastNameCtl.text.trim()}'.trim();

    context.read<UserProfileCubit>().updateProfile(
          name: fullName.isEmpty ? null : fullName,
          email: _emailCtl.text.trim(),
          phone: _phoneCtl.text.trim(),
          address: _addressCtl.text.trim(),
          city: _cityCtl.text.trim(),
          province: _stateCtl.text.trim(),
          country: _countryCtl.text.trim(),
          imagePath: _pickedImage?.path,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text('profile.edit_profile'.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<UserProfileCubit, UserProfileState>(
          listenWhen: (prev, curr) =>
              prev.updateStatus != curr.updateStatus || prev.profile != curr.profile,
          listener: (context, state) {
            _prefillIfNeeded(state);
            if (state.updateStatus == ProfileUpdateStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('profile.update_success'.tr())),
              );
              context.pop();
            } else if (state.updateStatus == ProfileUpdateStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'profile.update_error'.tr())),
              );
            }
          },
          builder: (context, state) {
            final isUpdating = state.updateStatus == ProfileUpdateStatus.updating;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EditHeader(
                    primary: primary,
                    avatar: _avatarImageProvider(),
                    onAvatarTap: _pickImage,
                  ),
                  const SizedBox(height: 18),
                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 16),
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _LabeledField(
                                  label: 'profile.first_name'.tr(),
                                  hint: 'profile.first_name'.tr(),
                                  icon: Icons.person_outline,
                                  controller: _firstNameCtl,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty) ? 'profile.first_name'.tr() : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _LabeledField(
                                  label: 'profile.last_name'.tr(),
                                  hint: 'profile.last_name'.tr(),
                                  icon: Icons.badge_outlined,
                                  controller: _lastNameCtl,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _LabeledField(
                            label: 'profile.email'.tr(),
                            hint: 'profile.email'.tr(),
                            icon: Icons.mail_outline,
                            controller: _emailCtl,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'profile.email'.tr();
                              if (!v.contains('@')) return 'profile.invalid_email'.tr();
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _LabeledField(
                            label: 'profile.phone'.tr(),
                            hint: 'profile.phone'.tr(),
                            icon: Icons.phone_rounded,
                            controller: _phoneCtl,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _LabeledField(
                            label: 'profile.address_label'.tr(),
                            hint: 'profile.address_label'.tr(),
                            icon: Icons.location_on_outlined,
                            controller: _addressCtl,
                          ),
                          const SizedBox(height: 12),
                          _LabeledField(
                            label: 'city'.tr(),
                            hint: 'city'.tr(),
                            icon: Icons.location_city,
                            controller: _cityCtl,
                          ),
                          const SizedBox(height: 12),
                          _LabeledField(
                            label: 'state'.tr(),
                            hint: 'state'.tr(),
                            icon: Icons.map_outlined,
                            controller: _stateCtl,
                          ),
                          const SizedBox(height: 12),
                          _LabeledField(
                            label: 'country'.tr(),
                            hint: 'country'.tr(),
                            icon: Icons.flag_outlined,
                            controller: _countryCtl,
                            customBuilder: (context, decoration) {
                              final displayValue = _selectedCountry?.localizedName(
                                    context.locale.languageCode,
                                  ) ??
                                  _countryCtl.text.trim();
                              return InkWell(
                                onTap: _pickCountry,
                                child: InputDecorator(
                                  decoration: decoration.copyWith(
                                    hintText: 'country'.tr(),
                                  ),
                                  child: Row(
                                    children: [
                                      if (_selectedCountry != null) ...[
                                        Text(
                                          _selectedCountry!.flag,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          displayValue.isEmpty
                                              ? 'country'.tr()
                                              : displayValue,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: isUpdating ? 'profile.updating'.tr() : 'profile.update_profile_button'.tr(),
                    onPressed: () => _submit(context, isUpdating),
                  ),
                  const SizedBox(height: 12),
                  if (state.updateStatus == ProfileUpdateStatus.failure)
                    _StatusBanner(
                      message: state.errorMessage ?? 'profile.update_error'.tr(),
                      color: Colors.red.shade100,
                      textColor: Colors.red.shade800,
                    )
                  else if (state.updateStatus == ProfileUpdateStatus.success)
                    _StatusBanner(
                      message: 'profile.update_success'.tr(),
                      color: Colors.green.shade100,
                      textColor: Colors.green.shade800,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EditHeader extends StatelessWidget {
  const _EditHeader({
    required this.primary,
    required this.avatar,
    required this.onAvatarTap,
  });

  final Color primary;
  final ImageProvider? avatar;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            primary,
            primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.white,
                  backgroundImage: avatar,
                  child: avatar == null
                      ? Icon(Icons.person_rounded, size: 56, color: primary.withOpacity(0.18))
                      : null,
                ),
              ),
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 3,
                child: InkWell(
                  onTap: onAvatarTap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'profile.update_profile_button'.tr(),
            style: theme.textTheme.titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.customBuilder,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final Widget Function(BuildContext context, InputDecoration decoration)?
      customBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration = InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.primary),
      hintText: hint,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.28)),
            color: theme.cardColor,
          ),
          child: customBuilder != null
              ? customBuilder!(context, decoration)
              : TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: keyboardType,
                  decoration: decoration,
                ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message, required this.color, required this.textColor});

  final String message;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(message, style: TextStyle(color: textColor)),
    );
  }
}
