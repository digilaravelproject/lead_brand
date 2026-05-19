import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors (updated to premium dark gold theme for branding consistency)
  static const Color primaryColor = Color(0xFFEAA515); // Premium Gold
  static const Color secondaryColor = Color(0xFFF5B01E); // Secondary Gold
  static const Color accentColor = Color(0xFFFFD700); // Accent Gold

  static const Color backgroundColor = Color(0xFF080B11); // Dark Obsidian Background
  static const Color cardColor = Color(0xFF121722); // Slate-black Card Color
  static const Color scaffoldBackgroundColor = Color(0xFF080B11);

  static const Color textColorPrimary = Color(0xFFFFFFFF); // White text
  static const Color textColorSecondary = Color(0xFF8F9CAE); // Slate-grey text
  static const Color textColorHint = Color(0xFF5A6E85);

  static const Color borderColor = Color(0xFF1A2333);
  static const Color dividerColor = Color(0xFF131A26);

  // Dark theme colors (matching premium dark gold theme)
  static const Color darkPrimaryColor = Color(0xFFEAA515);
  static const Color darkSecondaryColor = Color(0xFFF5B01E);
  static const Color darkAccentColor = Color(0xFFFFD700);

  static const Color darkBackgroundColor = Color(0xFF080B11);
  static const Color darkCardColor = Color(0xFF121722);
  static const Color darkScaffoldBackgroundColor = Color(0xFF080B11);

  static const Color darkTextColorPrimary = Color(0xFFFFFFFF);
  static const Color darkTextColorSecondary = Color(0xFF8F9CAE);
  static const Color darkTextColorHint = Color(0xFF5A6E85);

  static const Color darkBorderColor = Color(0xFF1A2333);
  static const Color darkDividerColor = Color(0xFF131A26);

  // Common colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

  // Stats Card Colors
  static const Color leadColor = Color(0xFFAB47BC); // Purple tint
  static const Color appointmentColor = Color(0xFF29B6F6); // Blue tint
  static const Color followUpColor = Color(0xFF66BB6A); // Green tint
  static const Color trainingColor = Color(0xFFFFA726); // Orange/Gold tint

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFEAA515), Color(0xFFF7B500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
