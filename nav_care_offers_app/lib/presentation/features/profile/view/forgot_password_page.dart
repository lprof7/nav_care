import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/presentation/features/profile/viewmodel/user_profile_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/profile/viewmodel/user_profile_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();

  @override
  void dispose() {
    _emailCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile.forgot_password'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<UserProfileCubit, UserProfileState>(
          listenWhen: (p, c) => p.resetStatus != c.resetStatus && c.resetStatus != PasswordResetStatus.sending,
          listener: (context, state) {
            if (state.resetStatus == PasswordResetStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('profile.reset_link_sent'.tr())),
              );
              context.pop();
            } else if (state.resetStatus == PasswordResetStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'profile.reset_link_failed'.tr())),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state.resetStatus == PasswordResetStatus.sending;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('profile.reset_password_hint'.tr()),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailCtl,
                      hintText: 'profile.email'.tr(),
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'profile.email'.tr();
                        if (!v.contains('@')) return 'profile.invalid_email'.tr();
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: isLoading ? 'profile.updating'.tr() : 'profile.send_reset'.tr(),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() != true) return;
                              context.read<UserProfileCubit>().requestPasswordReset(_emailCtl.text.trim());
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
