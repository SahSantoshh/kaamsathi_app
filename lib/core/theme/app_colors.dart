import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF3F51B5); // Indigo
  static const Color primaryLight = Color(0xFF757DE8);
  static const Color primaryDark = Color(0xFF002984);

  // Secondary/Accent Palette
  static const Color secondary = Color(0xFFFFC107); // Amber
  static const Color secondaryLight = Color(0xFFFFF350);
  static const Color secondaryDark = Color(0xFFC79100);

  // Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  
  // Text Colors
  static const Color onBackground = Color(0xFF1A1C1E);
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Color(0xFF1A1C1E);

  // Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color info = Color(0xFF0288D1);
}
