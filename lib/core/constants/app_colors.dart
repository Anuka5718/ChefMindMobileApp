import 'package:flutter/material.dart';

class AppColors {
  // Primary - Teal (from logo)
  static const Color primary = Color(0xFF00B4A6);
  static const Color primaryDark = Color(0xFF007A6E);
  static const Color primaryLight = Color(0xFF4DD0C4);

  // Accent - Orange (from logo)
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8C5A);

  // Backgrounds - Light
  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color bgLightSecondary = Color(0xFFF8FFFE);
  static const Color bgLightCard = Color(0xFFFFFFFF);

  // Backgrounds - Dark
  static const Color bgDark = Color(0xFF0D1117);
  static const Color bgDarkSecondary = Color(0xFF161B22);
  static const Color bgDarkCard = Color(0xFF1C2128);

  // Text - Light mode
  static const Color textPrimaryLight = Color(0xFF1A1A2A);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Text - Dark mode
  static const Color textPrimaryDark = Color(0xFFF0F6FC);
  static const Color textSecondaryDark = Color(0xFF8B949E);

  // Expiry status colors
  static const Color expiryRed = Color(0xFFEF4444);
  static const Color expiryAmber = Color(0xFFF59E0B);
  static const Color expiryGreen = Color(0xFF10B981);

  // Glass effect
  static const Color glassLight = Color(0x80FFFFFF);
  static const Color glassDark = Color(0x801C2128);
  static const Color glassBorderLight = Color(0x4000B4A6);
  static const Color glassBorderDark = Color(0x404DD0C4);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFE0F7F5), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}