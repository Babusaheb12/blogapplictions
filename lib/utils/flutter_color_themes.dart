import 'package:flutter/material.dart';

class AppColors {

  // =========================
  // PRIMARY COLORS
  // =========================

  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF3F4F46);
  static const Color tertiary = Color(0xFFBC4800);

  // =========================
  // NEUTRAL COLORS
  // =========================

  static const Color black = Color(0xFF111827);
  static const Color darkGrey = Color(0xFF374151);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFD1D5DB);
  static const Color background = Color(0xFFF3F4F6);
  static const Color white = Color(0xFFFFFFFF);

  // =========================
  // TEXT COLORS
  // =========================

  static const Color headingText = Color(0xFF111827);
  static const Color bodyText = Color(0xFF4B5563);
  static const Color labelText = Color(0xFF6B7280);

  // =========================
  // BUTTON COLORS
  // =========================

  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = lightGrey;

  // =========================
  // BORDER & INPUT
  // =========================

  static const Color border = Color(0xFFE5E7EB);
  static const Color inputFill = Color(0xFFF9FAFB);

  // =========================
  // STATUS COLORS
  // =========================

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = primary;

  // =========================
  // GRADIENTS
  // =========================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF1D4ED8),
    ],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFBC4800),
      Color(0xFFD97706),
    ],
  );
}