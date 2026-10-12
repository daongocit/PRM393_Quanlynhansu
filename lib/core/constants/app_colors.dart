import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Deep Royal Navy & Slate
  static const Color primary = Color(0xFF1E3A8A); // Blue 900
  static const Color primaryLight = Color(0xFF3B82F6); // Blue 500
  static const Color primaryDark = Color(0xFF172554); // Blue 950

  // Secondary & Accents - Emerald Green & Amber
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color secondaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color accent = Color(0xFF6366F1); // Indigo 500

  // Neutral Background & Surface
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE2E8F0); // Slate 200

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successBg = Color(0xFFD1FAE5);
  
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningBg = Color(0xFFFEF3C7);
  
  static const Color error = Color(0xFFEF4444); // Rose
  static const Color errorBg = Color(0xFFFEE2E2);
  
  static const Color info = Color(0xFF0EA5E9); // Sky
  static const Color infoBg = Color(0xFFE0F2FE);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
