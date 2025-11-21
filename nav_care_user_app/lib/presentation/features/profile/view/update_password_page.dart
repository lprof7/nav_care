import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_cubit.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_state.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_user_app/presentation/shared/theme/colors.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtl = TextEditingController();
  final _newCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  bool _minLength = false;
  bool _hasUpper = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  @override
  void dispose() {
    _currentCtl.dispose();
    _newCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile.update_password_short'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<UserProfileCubit, UserProfileState>(
          listenWhen: (p, c) => p.passwordStatus != c.passwordStatus && c.passwordStatus != PasswordUpdateStatus.updating,
          listener: (context, state) {
            if (state.passwordStatus == PasswordUpdateStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('profile.password_update_success'.tr())),
              );
              context.pop();
            } else if (state.passwordStatus == PasswordUpdateStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'profile.password_update_error'.tr())),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state.passwordStatus == PasswordUpdateStatus.updating;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OutlinedPasswordField(
                      label: 'profile.password_current'.tr(),
                      controller: _currentCtl,
                      obscureText: !_showCurrent,
                      onToggleVisibility: () => setState(() => _showCurrent = !_showCurrent),
                      validator: (v) => (v == null || v.isEmpty) ? 'profile.password_current'.tr() : null,
                    ),
                    const SizedBox(height: 12),
                    _OutlinedPasswordField(
                      label: 'profile.password_new'.tr(),
                      controller: _newCtl,
                      obscureText: !_showNew,
                      onToggleVisibility: () => setState(() => _showNew = !_showNew),
                      onChanged: (v) => setState(() {
                        _minLength = v.length >= 8;
                        _hasUpper = RegExp(r'[A-Z]').hasMatch(v);
                        _hasNumber = RegExp(r'[0-9]').hasMatch(v);
                        _hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v);
                      }),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'profile.password_new'.tr();
                        if (v.length < 8) return 'profile.password_invalid'.tr();
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
                    const SizedBox(height: 12),
                    _OutlinedPasswordField(
                      label: 'profile.password_confirm_new'.tr(),
                      controller: _confirmCtl,
                      obscureText: !_showConfirm,
                      onToggleVisibility: () => setState(() => _showConfirm = !_showConfirm),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'profile.confirm_password_required'.tr();
                        if (v != _newCtl.text) return 'profile.password_mismatch'.tr();
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/profile/forgot-password'),
                        child: Text('profile.forgot_password'.tr()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: isLoading ? 'profile.updating'.tr() : 'profile.update_password_short'.tr(),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() != true) return;
                              context.read<UserProfileCubit>().updatePassword(
                                    currentPassword: _currentCtl.text,
                                    newPassword: _newCtl.text,
                                  );
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OutlinedPasswordField extends StatelessWidget {
  const _OutlinedPasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
              suffixIcon: IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary,
                ),
              ),
              hintText: label,
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

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
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
