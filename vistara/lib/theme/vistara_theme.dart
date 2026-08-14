import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VistaraColors {
  // ─────────────────────────────────────────────
  // BRAND
  // ─────────────────────────────────────────────

  static const Color lilacWhite = Color(0xFFF4F0F5);
  static const Color lavenderGray = Color(0xFFB8A9C9);
  static const Color softLavender = Color(0xFFEFE7F5);

  static const Color ochreAmber = Color(0xFFE0A458);
  static const Color plumCharcoal = Color(0xFF3E3546);

  // ─────────────────────────────────────────────
  // TEXT
  // ─────────────────────────────────────────────

  static const Color bodyText = Color(0xFF554C43);
  static const Color mutedText = Color(0xFF6E6478);
  static const Color neutral = Color(0xFF8A8290);

  // ─────────────────────────────────────────────
  // RISK COLORS
  // ─────────────────────────────────────────────

  static const Color highRisk = Color(0xFFB15E56);
  static const Color mediumRisk = Color(0xFFC98A3E);
  static const Color lowRisk = Color(0xFF9C9268);

  static Color riskColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return highRisk;

      case 'medium':
        return mediumRisk;

      case 'low':
        return lowRisk;

      default:
        return neutral;
    }
  }
}
class VistaraTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor:
    VistaraColors.lilacWhite,

    colorScheme: const ColorScheme.light(
      primary: VistaraColors.ochreAmber,
      secondary: VistaraColors.lavenderGray,
      surface: Colors.white,
      onPrimary: VistaraColors.plumCharcoal,
      onSecondary: VistaraColors.plumCharcoal,
      onSurface: VistaraColors.plumCharcoal,
    ),

    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: VistaraColors.plumCharcoal,
      displayColor: VistaraColors.plumCharcoal,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: VistaraColors.lilacWhite,
      foregroundColor: VistaraColors.plumCharcoal,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      indicatorColor:
      VistaraColors.ochreAmber.withValues(
        alpha: 0.18,
      ),

      labelTextStyle:
      WidgetStateProperty.resolveWith(
            (states) {
          final selected =
          states.contains(
            WidgetState.selected,
          );

          return GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w500,
            color: selected
                ? VistaraColors.plumCharcoal
                : VistaraColors.mutedText,
          );
        },
      ),

      iconTheme:
      WidgetStateProperty.resolveWith(
            (states) {
          final selected =
          states.contains(
            WidgetState.selected,
          );

          return IconThemeData(
            size: 22,
            color: selected
                ? VistaraColors.ochreAmber
                : VistaraColors.mutedText,
          );
        },
      ),
    ),

    elevatedButtonTheme:
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
        VistaraColors.ochreAmber,
        foregroundColor:
        VistaraColors.plumCharcoal,
        elevation: 0,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    inputDecorationTheme:
    InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      hintStyle: GoogleFonts.poppins(
        color: VistaraColors.neutral,
        fontSize: 13,
      ),

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: BorderSide(
          color: VistaraColors
              .lavenderGray
              .withValues(alpha: 0.25),
        ),
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: BorderSide(
          color: VistaraColors
              .lavenderGray
              .withValues(alpha: 0.25),
        ),
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: VistaraColors.ochreAmber,
          width: 1.5,
        ),
      ),
    ),
  );
}