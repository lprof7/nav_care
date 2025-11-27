import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/users/models/user_profile_model.dart';
import 'package:nav_care_user_app/presentation/features/authentication/session/auth_session_cubit.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_cubit.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_state.dart';
import 'package:nav_care_user_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_user_app/presentation/shared/ui/molecules/sign_in_required_card.dart';
import 'package:nav_care_user_app/presentation/shared/theme/colors.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthSessionCubit>().state;
    if (!authState.isAuthenticated) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SignInRequiredCard(
                  onSignIn: () => context.go('/signin'),
                  onCreateAccount: () => context.go('/signup'),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, state) {
            if (state.loadStatus == ProfileLoadStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.loadStatus == ProfileLoadStatus.failure) {
              return _ProfileError(
                message: state.errorMessage ?? 'profile.load_error'.tr(),
                onRetry: () => context.read<UserProfileCubit>().loadProfile(),
              );
            }
            if (state.profile == null) {
              return _ProfileEmpty(onReload: () => context.read<UserProfileCubit>().loadProfile());
            }

            final profile = state.profile!;
            final appConfig = sl<AppConfig>();
            final avatarUrl = profile.avatarUrl(appConfig.api.baseUrl);

            return RefreshIndicator(
              onRefresh: () => context.read<UserProfileCubit>().loadProfile(),
              color: colorScheme.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  _ProfileHeader(
                    name: profile.name,
                    email: profile.email,
                    phone: profile.phone,
                    avatarUrl: avatarUrl,
                    backgroundColor: colorScheme.primary,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ProfileDetailsCard(
                        emailLabel: 'profile.email'.tr(),
                        email: profile.email,
                        phoneLabel: 'profile.phone'.tr(),
                        phone: profile.phone,
                        addressLabel: 'profile.address_label'.tr(),
                        address: _buildAddress(profile),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppButton(
                          text: 'profile.edit_profile'.tr(),
                          onPressed: () => context.push('/profile/edit'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.lock_reset_rounded),
                          onPressed: () => context.push('/profile/password'),
                          label: Text('profile.update_password_short'.tr()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        if (state.updateStatus == ProfileUpdateStatus.failure ||
                            state.passwordStatus == PasswordUpdateStatus.failure ||
                            state.resetStatus == PasswordResetStatus.failure)
                          _StatusBanner(
                            message: state.errorMessage ?? '',
                            color: Colors.red.shade100,
                            textColor: Colors.red.shade800,
                          )
                        else if (state.updateStatus == ProfileUpdateStatus.success)
                          _StatusBanner(
                            message: 'profile.update_success'.tr(),
                            color: Colors.green.shade100,
                            textColor: Colors.green.shade800,
                          )
                        else if (state.passwordStatus == PasswordUpdateStatus.success)
                          _StatusBanner(
                            message: 'profile.password_update_success'.tr(),
                            color: Colors.green.shade100,
                            textColor: Colors.green.shade800,
                          )
                        else if (state.resetStatus == PasswordResetStatus.success)
                          _StatusBanner(
                            message: 'profile.reset_link_sent'.tr(),
                            color: Colors.green.shade100,
                            textColor: Colors.green.shade800,
                          ),
                      ],
                    ),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.backgroundColor,
    this.phone,
  });

  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  backgroundColor,
                  backgroundColor.withOpacity(0.82),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(34),
                bottomRight: Radius.circular(34),
              ),
            ),
          ),
          Positioned(
            top: -24,
            right: -36,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 32,
            left: -32,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
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
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null
                        ? Icon(Icons.person_rounded, size: 56, color: backgroundColor.withOpacity(0.18))
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
                if (phone != null && phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    phone!,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  const _ProfileDetailsCard({
    required this.emailLabel,
    required this.email,
    required this.phoneLabel,
    required this.addressLabel,
    required this.address,
    this.phone,
  });

  final String emailLabel;
  final String email;
  final String phoneLabel;
  final String? phone;
  final String addressLabel;
  final String address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surface;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 16),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.mail_outline_rounded,
            label: emailLabel,
            value: email,
          ),
          const Divider(height: 26),
          _InfoRow(
            icon: Icons.phone_rounded,
            label: phoneLabel,
            value: phone?.isNotEmpty == true ? phone! : '-',
          ),
          const Divider(height: 26),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: addressLabel,
            value: address,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text('profile.retry'.tr())),
        ],
      ),
    );
  }
}

class _ProfileEmpty extends StatelessWidget {
  const _ProfileEmpty({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 48),
          const SizedBox(height: 8),
          Text('profile.empty'.tr()),
          const SizedBox(height: 12),
          FilledButton(onPressed: onReload, child: Text('profile.retry'.tr())),
        ],
      ),
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

String _buildAddress(UserProfileModel profile) {
  final parts = [
    profile.address,
    profile.city,
    profile.state,
    profile.country,
  ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
  return parts.isEmpty ? '-' : parts.join(', ');
}
