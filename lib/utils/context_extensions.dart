
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  /// Returns `true` if the current theme is dark.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Returns the current ColorScheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Returns the current ThemeData.
  ThemeData get theme => Theme.of(this);
}


//  color: context.isDark ? AppColors.sortFilterbg : AppColors.white,
//  backgroundColor: context.colorScheme.background,