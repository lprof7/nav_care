import 'package:flutter/material.dart';

import 'package:nav_care_user_app/presentation/shared/theme/colors.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(isDark: false);

  static ThemeData get dark => _buildTheme(isDark: true);

  static ThemeData _buildTheme({required bool isDark}) {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final colorScheme =
        (isDark ? const ColorScheme.dark() : const ColorScheme.light())
            .copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.primaryLight,
      onSecondary: AppColors.textOnPrimary,
      background: isDark ? AppColors.backgroundDark : AppColors.background,
      onBackground: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      surface: isDark ? AppColors.surfaceDark : AppColors.neutral100,
      onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
    );

    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return base.copyWith(
      colorScheme: colorScheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: colorScheme.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: base.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: colorScheme.background,
        foregroundColor: textColor,
        elevation: 0,
      ),
      inputDecorationTheme: _inputDecorationTheme(isDark),
      elevatedButtonTheme: _elevatedButtonTheme(isDark),
      textButtonTheme: _textButtonTheme(),
      checkboxTheme: _checkboxTheme(isDark),
      iconTheme: base.iconTheme.copyWith(color: secondaryTextColor),
      dividerColor: isDark ? AppColors.borderDark : AppColors.border,
      cardColor: colorScheme.surface,
      canvasColor: colorScheme.background,
    );
  }

  static InputDecorationTheme _inputDecorationTheme(bool isDark) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final fillColor = isDark ? AppColors.surfaceDark : AppColors.neutral100;
    final hintColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final labelColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(AppColors.primary),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error),
      hintStyle: TextStyle(color: hintColor),
      labelStyle: TextStyle(color: labelColor),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(bool isDark) {
    final disabledBackground = isDark ? AppColors.borderDark : AppColors.border;
    final disabledForeground =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: disabledBackground,
        disabledForegroundColor: disabledForeground,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static CheckboxThemeData _checkboxTheme(bool isDark) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return borderColor;
      }),
      checkColor: MaterialStateProperty.all(AppColors.textOnPrimary),
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
