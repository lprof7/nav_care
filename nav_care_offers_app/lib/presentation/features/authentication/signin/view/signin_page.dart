import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/core/routing/app_router.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/signin/viewmodel/signin_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_text_field.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/social_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/password_field.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/colors.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

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

    return BlocProvider(
      create: (context) => sl<SigninCubit>(),
      child: Scaffold(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 32),
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
                    child: BlocListener<SigninCubit, SigninState>(
                      listener: (context, state) {
                        if (state is SigninSuccess) {
                          context.go('/home');
                        } else if (state is SigninFailure) {
                          debugPrint(state.message);
                          final message =
                              (state.message.startsWith('signin.') ||
                                      state.message.startsWith('signin_'))
                                  ? state.message.tr()
                                  : 'signin_error_message'.tr(
                                      namedArgs: {'message': state.message},
                                    );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                            ),
                          );
                        }
                      },
                      child: const SigninForm(),
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

class SigninForm extends StatefulWidget {
  const SigninForm({super.key});

  @override
  State<SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;
    final secondaryTextColor =
        isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final dividerColor = isDarkMode ? AppColors.borderDark : AppColors.border;
    final headingColor =
        isDarkMode ? AppColors.textPrimaryDark : AppColors.headingPrimary;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'sign_in'.tr(),
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'sign_in_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 32),
          AppTextField(
            controller: _identifierController,
            hintText: 'email_or_phone'.tr(),
            prefixIcon: const Icon(Icons.mail_outline),
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return 'profile.invalid_email'.tr();
              if (!RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$').hasMatch(trimmed)) {
                return 'profile.invalid_email'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: _passwordController,
            hintText: 'password'.tr(),
            textDirection: TextDirection.ltr,
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'profile.password_invalid'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Text(
                  'remember_me'.tr(),
                  style: textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoute.resetPasswordEmail.path),
                child: Text('forgot_password'.tr()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<SigninCubit, SigninState>(
            builder: (context, state) {
              final isLoading = state is SigninLoading;
              return AppButton(
                text: 'sign_in'.tr(),
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<SigninCubit>().signin(
                                _identifierController.text.trim(),
                                _passwordController.text,
                                localeTag: context.locale.toLanguageTag(),
                              );
                        }
                      },
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'dont_have_account'.tr(),
                style: textTheme.bodyMedium?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoute.signUp.path),
                child: Text(
                  'sign_up'.tr(),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          /*Row(
            children: [
              Expanded(
                child: Divider(
                  color: dividerColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or'.tr(),
                  style: textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: dividerColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SocialButton(
            text: 'sign_in_with_google'.tr(),
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
          const SizedBox(height: 16),
          SocialButton(
            text: 'sign_in_with_apple'.tr(),
            color: AppColors.brandApple,
            textColor: AppColors.textOnPrimary,
            onPressed: () {},
            icon: const Icon(
              Icons.apple,
              color: AppColors.textOnPrimary,
            ),
          ),*/
        ],
      ),
    );
  }
}
