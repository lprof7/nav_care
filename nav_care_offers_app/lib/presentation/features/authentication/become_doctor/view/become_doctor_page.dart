import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/colors.dart';

class BecomeDoctorPage extends StatelessWidget {
  final User? user;

  const BecomeDoctorPage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      color: isDarkMode ? AppColors.textPrimaryDark : AppColors.headingPrimary,
      fontWeight: FontWeight.w700,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('become_doctor_title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'become_doctor_heading'.tr(),
                  style: titleStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'become_doctor_description'.tr(
                    namedArgs: {
                      'name': user?.name ?? 'become_doctor_default_name'.tr(),
                    },
                  ),
                  style: bodyStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'become_doctor_next_steps'.tr(),
                  style: bodyStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text('become_doctor_back_to_signin'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
