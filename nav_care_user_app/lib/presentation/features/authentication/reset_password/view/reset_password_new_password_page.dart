import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/presentation/features/authentication/reset_password/view/reset_password_layout.dart';
import 'package:nav_care_user_app/presentation/features/authentication/reset_password/viewmodel/reset_password_cubit.dart';
import 'package:nav_care_user_app/presentation/features/authentication/reset_password/viewmodel/reset_password_state.dart';
import 'package:nav_care_user_app/presentation/shared/theme/colors.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_button.dart';

class ResetPasswordNewPasswordPage extends StatefulWidget {
  const ResetPasswordNewPasswordPage({super.key});

  @override
  State<ResetPasswordNewPasswordPage> createState() =>
      _ResetPasswordNewPasswordPageState();
}

class _ResetPasswordNewPasswordPageState
    extends State<ResetPasswordNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  bool _showNew = false;
  bool _showConfirm = false;

  bool _minLength = false;
  bool _hasUpper = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  @override
  void dispose() {
    _newCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listenWhen: (p, c) => p.resetStatus != c.resetStatus,
      listener: (context, state) {
        if (state.resetStatus == ResetRequestStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('reset_password.success'.tr())),
          );
          context.go('/signin');
        } else if (state.resetStatus == ResetRequestStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'reset_password.error'.tr()),
            ),
          );
        }
      },
      builder: (context, state) {
        if (!state.isCodeVerified) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/reset-password/email');
            context.read<ResetPasswordCubit>().resetFlow();
          });
          return const SizedBox.shrink();
        }

        final isLoading = state.resetStatus == ResetRequestStatus.loading;
        return ResetPasswordLayout(
          title: 'reset_password.password_title'.tr(),
          subtitle: 'reset_password.password_subtitle'.tr(),
          onBack: () {
            context.pop();
          },
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PasswordField(
                  label: 'reset_password.new_password'.tr(),
                  controller: _newCtl,
                  obscureText: !_showNew,
                  onToggleVisibility: () =>
                      setState(() => _showNew = !_showNew),
                  onChanged: (v) => setState(() {
                    _minLength = v.length >= 8;
                    _hasUpper = RegExp(r'[A-Z]').hasMatch(v);
                    _hasNumber = RegExp(r'[0-9]').hasMatch(v);
                    _hasSpecial =
                        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v);
                  }),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'reset_password.new_password'.tr();
                    }
                    if (v.length < 8 || !_hasUpper || !_hasNumber || !_hasSpecial) {
                      return 'profile.password_invalid'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _PasswordRequirements(
                  minLength: _minLength,
                  hasUpper: _hasUpper,
                  hasNumber: _hasNumber,
                  hasSpecial: _hasSpecial,
                ),
                const SizedBox(height: 12),
                _PasswordField(
                  label: 'reset_password.confirm_password'.tr(),
                  controller: _confirmCtl,
                  obscureText: !_showConfirm,
                  onToggleVisibility: () =>
                      setState(() => _showConfirm = !_showConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'profile.confirm_password_required'.tr();
                    }
                    if (v != _newCtl.text) {
                      return 'profile.password_mismatch'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                AppButton(
                  text: isLoading
                      ? 'loading'.tr()
                      : 'reset_password.submit'.tr(),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() != true) {
                            return;
                          }
                          context
                              .read<ResetPasswordCubit>()
                              .resetPassword(_newCtl.text);
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
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
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outlineVariant
        .withOpacity(theme.brightness == Brightness.dark ? 0.6 : 0.4);
    final fillColor = theme.colorScheme.surfaceVariant.withOpacity(
      theme.brightness == Brightness.dark ? 0.35 : 0.9,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: outline),
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
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.65),
              ),
              filled: true,
              fillColor: fillColor,
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
        const SizedBox(height: 8),
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
