import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System tokens and switchable themes for Stock Advisory Mobile App
class AppTheme {
  // Common Colors
  static const Color greenPass = Color(0xFF10B981);
  static const Color greenPassBg = Color(0xFFECFDF5);
  static const Color redFail = Color(0xFFEF4444);
  static const Color redFailBg = Color(0xFFFEF2F2);
  static const Color amberWarn = Color(0xFFF59E0B);
  static const Color amberWarnBg = Color(0xFFFFFBEB);
  static const Color blueInfo = Color(0xFF2563EB);
  static const Color blueInfoBg = Color(0xFFEFF6FF);

  // Theme 1: Minimal iOS / SaaS (Default)
  static ThemeData get minimalLight {
    final baseText = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2563EB),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF0F172A),
        outline: Color(0xFFE2E8F0),
      ),
      textTheme: baseText.copyWith(
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          fontSize: 13,
          color: const Color(0xFF334155),
        ),
      ),
      cardTheme: const CardTheme(
        color: Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  // Theme 2: Dark Institutional Pro Terminal
  static ThemeData get darkInstitutional {
    final monoText = GoogleFonts.jetBrainsMonoTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF090D16),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF38BDF8),
        surface: Color(0xFF111827),
        onSurface: Color(0xFFF3F4F6),
        outline: Color(0xFF1F2937),
      ),
      textTheme: monoText,
      cardTheme: const CardTheme(
        color: Color(0xFF111827),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          side: BorderSide(color: Color(0xFF1F2937)),
        ),
      ),
    );
  }
}
