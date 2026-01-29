import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit to manage theme mode state
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  /// Toggle between light and dark theme
  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  /// Set theme mode explicitly
  void setTheme(ThemeMode mode) {
    emit(mode);
  }

  /// Check if current theme is dark
  bool get isDark => state == ThemeMode.dark;
}
