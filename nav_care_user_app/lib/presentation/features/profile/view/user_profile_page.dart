import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/users/models/user_profile_model.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_cubit.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_state.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserProfileModel? _lastProfile;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listenWhen: (previous, current) =>
          previous.actionId != current.actionId && current.lastAction != null,
      listener: (context, state) {
        if (!context.mounted) return;
        final action = state.lastAction;
        if (action == UserProfileAction.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('profile.update_success'.tr())),
          );
        } else if (action == UserProfileAction.updateFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('profile.update_error'.tr())),
          );
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        if (state.status == UserProfileStatus.loading && profile == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == UserProfileStatus.failure && profile == null) {
          return _ProfileError(
            message: state.errorMessage ?? 'profile.load_error'.tr(),
            onRetry: () => context.read<UserProfileCubit>().loadProfile(),
          );
        }
        if (profile == null) {
          return Center(
            child: Text(
              'profile.empty'.tr(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        _syncControllers(profile);
        final hasChanges = _hasFormChanges(profile);

        return RefreshIndicator(
          onRefresh: () => context.read<UserProfileCubit>().refreshProfile(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _ProfileHeaderCard(profile: profile),
              const SizedBox(height: 16),
              _EditProfileForm(
                formKey: _formKey,
                nameController: _nameController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                isUpdating: state.isUpdating,
                hasChanges: hasChanges,
                onSave: () => _submitChanges(context, profile),
              ),
            ],
          ),
        );
      },
    );
  }

  void _syncControllers(UserProfileModel profile) {
    if (_lastProfile != null &&
        _lastProfile!.id == profile.id &&
        _lastProfile!.name == profile.name) {
      return;
    }
    _nameController.text = profile.name;
    _passwordController.clear();
    _confirmPasswordController.clear();
    _lastProfile = profile;
  }

  bool _hasFormChanges(UserProfileModel profile) {
    final nameChanged = _nameController.text.trim() != profile.name;
    final hasPassword = _passwordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty;
    return nameChanged || hasPassword;
  }

  void _submitChanges(BuildContext context, UserProfileModel profile) {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasFormChanges(profile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.no_changes'.tr())),
      );
      return;
    }

    final cubit = context.read<UserProfileCubit>();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    cubit.updateProfile(
      name: name != profile.name ? name : null,
      password: password.isEmpty ? null : password,
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final UserProfileModel profile;

  const _ProfileHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appConfig = sl<AppConfig>();
    final avatar = profile.avatarUrl(appConfig.api.baseUrl);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                  child: avatar == null
                      ? const Icon(Icons.person_rounded, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (profile.phone != null && profile.phone!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            profile.phone!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (profile.address != null && profile.address!.isNotEmpty)
                  _InfoChip(
                    icon: Icons.place_rounded,
                    label: profile.address!,
                  ),
                if (profile.isVerified)
                  _InfoChip(
                    icon: Icons.verified_rounded,
                    label: 'profile.verified'.tr(),
                  )
                else
                  _InfoChip(
                    icon: Icons.privacy_tip_rounded,
                    label: 'profile.not_verified'.tr(),
                  ),
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: profile.createdAt != null
                      ? DateFormat.yMMMd().format(profile.createdAt!)
                      : 'profile.member_since_unknown'.tr(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isUpdating;
  final bool hasChanges;
  final VoidCallback onSave;

  const _EditProfileForm({
    required this.formKey,
    required this.nameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isUpdating,
    required this.hasChanges,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'profile.edit_section'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'profile.name_label'.tr(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'field_required'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'profile.password_label'.tr(),
                  helperText: 'profile.password_helper'.tr(),
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  if (value.length < 8) {
                    return 'profile.password_invalid'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'profile.confirm_password_label'.tr(),
                ),
                obscureText: true,
                validator: (value) {
                  if (passwordController.text.isEmpty) {
                    return null;
                  }
                  if (value == null || value.isEmpty) {
                    return 'profile.confirm_password_required'.tr();
                  }
                  if (value != passwordController.text) {
                    return 'profile.password_mismatch'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onSave,
                icon: isUpdating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(isUpdating
                    ? 'profile.updating'.tr()
                    : 'profile.save_changes'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.6),
    );
  }
}

class _ProfileError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: Text('profile.retry'.tr()),
          ),
        ],
      ),
    );
  }
}
