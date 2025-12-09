import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/presentation/features/authentication/reset_password/view/reset_password_layout.dart';
import 'package:nav_care_user_app/presentation/features/authentication/reset_password/viewmodel/reset_password_cubit.dart';
import 'package:nav_care_user_app/presentation/features/authentication/reset_password/viewmodel/reset_password_state.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_text_field.dart';

class ResetPasswordEmailPage extends StatefulWidget {
  const ResetPasswordEmailPage({super.key});

  @override
  State<ResetPasswordEmailPage> createState() => _ResetPasswordEmailPageState();
}

class _ResetPasswordEmailPageState extends State<ResetPasswordEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listenWhen: (p, c) => p.sendCodeStatus != c.sendCodeStatus,
      listener: (context, state) {
        if (state.sendCodeStatus == ResetRequestStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('reset_password.code_sent'.tr())),
          );
          context.push(
            '/reset-password/code',
            extra: context.read<ResetPasswordCubit>(),
          );
        } else if (state.sendCodeStatus == ResetRequestStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'reset_password.error'.tr()),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.sendCodeStatus == ResetRequestStatus.loading;
        return ResetPasswordLayout(
          title: 'reset_password.title'.tr(),
          subtitle: 'reset_password.subtitle'.tr(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _emailController,
                  hintText: 'reset_password.email_hint'.tr(),
                  prefixIcon: const Icon(Icons.mail_outline),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'profile.email'.tr();
                    if (!v.contains('@')) return 'profile.invalid_email'.tr();
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                AppButton(
                  text: isLoading
                      ? 'loading'.tr()
                      : 'reset_password.send_code'.tr(),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() != true) {
                            return;
                          }
                          context
                              .read<ResetPasswordCubit>()
                              .sendResetCode(_emailController.text);
                        },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/signin'),
                  child: Text('sign_in'.tr()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
