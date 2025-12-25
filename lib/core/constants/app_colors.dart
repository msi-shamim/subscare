import 'package:flutter/material.dart';

/// App color palette based on Project Requirements
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secondary Colors
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF7C3AED);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color credit = success;
  static const Color error = Color(0xFFEF4444);
  static const Color debit = error;
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color dividerLight = Color(0xFFE2E8F0);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color dividerDark = Color(0xFF334155);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
