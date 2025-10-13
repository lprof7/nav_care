import 'package:flutter/material.dart';

import 'package:nav_care_app/presentation/shared/theme/colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'Inter',
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
