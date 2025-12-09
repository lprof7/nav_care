import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit({ThemeMode initialMode = ThemeMode.system})
      : super(initialMode);

  void toggle() {
    switch (state) {
      case ThemeMode.light:
        emit(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        emit(ThemeMode.light);
        break;
      case ThemeMode.system:
      default:
        emit(ThemeMode.dark);
        break;
    }
  }

  void setMode(ThemeMode mode) => emit(mode);
}
