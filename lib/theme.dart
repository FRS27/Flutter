import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ------------------------------------------------------------
  // COPILOT BLUE COLOR PALETTE
  // ------------------------------------------------------------
  static const Color copilotBlue = Color(0xFF0A84FF);        // Accent blue
  static const Color copilotBlueLight = Color(0xFFE8F2FF);  // Soft background tint
  static const Color copilotSurface = Color(0xFFF7F9FC);    // Very light blue-grey
  static const Color copilotGrey = Color(0xFF6B7280);       // Neutral text
  static const Color copilotDark = Color(0xFF1F2937);       // Dark text

  // ------------------------------------------------------------
  // LIGHT THEME
  // ------------------------------------------------------------
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Background
    scaffoldBackgroundColor: copilotSurface,

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: copilotBlue,
      onPrimary: Colors.white,
      primaryContainer: copilotBlueLight,
      surface: copilotSurface,
      surfaceContainerHighest: Colors.white,
      onSurface: copilotDark,
      outline: Colors.grey.shade300,
    ),

    // Typography
    textTheme: GoogleFonts.interTextTheme().copyWith(
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: copilotDark,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: copilotDark,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: copilotGrey,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: copilotGrey,
      ),
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: copilotDark,
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(
        color: copilotGrey.withOpacity(0.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );

  // ------------------------------------------------------------
  // DARK THEME (Optional, but polished)
  // ------------------------------------------------------------
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.dark(
      primary: copilotBlue,
      onPrimary: Colors.white,
      primaryContainer: Colors.white10,
      surface: const Color(0xFF111827),
      surfaceContainerHighest: const Color(0xFF1F2937),
      onSurface: Colors.white,
      outline: Colors.white24,
    ),

    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  );
}
