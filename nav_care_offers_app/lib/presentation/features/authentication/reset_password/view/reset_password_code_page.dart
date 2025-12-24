import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/reset_password/view/reset_password_layout.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/reset_password/viewmodel/reset_password_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/reset_password/viewmodel/reset_password_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/colors.dart';

class ResetPasswordCodePage extends StatefulWidget {
  const ResetPasswordCodePage({super.key});

  @override
  State<ResetPasswordCodePage> createState() => _ResetPasswordCodePageState();
}

class _ResetPasswordCodePageState extends State<ResetPasswordCodePage> {
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final email = context.read<ResetPasswordCubit>().state.email;
    if (email.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/reset-password/email');
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listenWhen: (p, c) => p.verifyCodeStatus != c.verifyCodeStatus,
      listener: (context, state) {
        if (state.verifyCodeStatus == ResetRequestStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('reset_password.code_verified'.tr())),
          );
          context.push(
            '/reset-password/new-password',
            extra: context.read<ResetPasswordCubit>(),
          );
        } else if (state.verifyCodeStatus == ResetRequestStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'reset_password.error'.tr()),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state.verifyCodeStatus == ResetRequestStatus.loading;
        final isExpired = state.secondsRemaining <= 0;
        final code = _codeController.text.trim();
        final email = state.email;
        final timerText = state.secondsRemaining.toString().padLeft(2, '0');
        final theme = Theme.of(context);
        final borderColor = theme.colorScheme.outlineVariant;
        final focusColor = theme.colorScheme.primary;
        final fillColor = theme.colorScheme.surface;
        final hintColor = theme.colorScheme.onSurfaceVariant;

        return ResetPasswordLayout(
          title: 'reset_password.code_title'.tr(),
          subtitle:
              'reset_password.code_subtitle'.tr(namedArgs: {'email': email}),
          onBack: () {
            context.go('/reset-password/email');
            context.read<ResetPasswordCubit>().resetFlow();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.primary.withOpacity(0.25)),
                  color: AppColors.primary.withOpacity(0.04),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'reset_password.timer_title'.tr(),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            color: AppColors.primary.withOpacity(0.8)),
                        const SizedBox(width: 8),
                        Text(
                          isExpired
                              ? 'reset_password.timer_expired'.tr()
                              : 'reset_password.timer_label'
                                  .tr(namedArgs: {'seconds': timerText}),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(letterSpacing: 8),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  hintText: 'reset_password.code_hint'.tr(),
                  hintStyle: TextStyle(color: hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: focusColor),
                  ),
                  filled: true,
                  fillColor: fillColor,
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                text: isLoading
                    ? 'loading'.tr()
                    : 'reset_password.verify'.tr(),
                onPressed: (!isExpired && code.length == 6 && !isLoading)
                    ? () =>
                        context.read<ResetPasswordCubit>().verifyResetCode(code)
                    : null,
              ),
              if (isExpired) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    context.go('/reset-password/email');
                    context.read<ResetPasswordCubit>().resetFlow();
                  },
                  child: Text('reset_password.back_to_email'.tr()),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
