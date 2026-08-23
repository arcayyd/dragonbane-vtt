import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VttTheme {
  // Theme Color Palette
  static const Color background = Color(0xff121212);
  static const Color surface = Color(0xff1e1e1e);
  static const Color surfaceLight = Color(0xff2d2d2d);
  
  static const Color primary = Color(0xff8a1c1c); // Dragon Red
  static const Color primaryLight = Color(0xffa83232);
  static const Color accent = Color(0xffd4af37); // Gold/Aged Brass
  
  static const Color textLight = Color(0xffefebe4); // Warm Parchment
  static const Color textDark = Color(0xff1a1a1a);
  static const Color textMuted = Color(0xff9e9e9e);
  
  static const Color conditionExhausted = Color(0xffe57373);
  static const Color conditionSickly = Color(0xff81c784);
  static const Color conditionDazed = Color(0xff64b5f6);
  static const Color conditionAngry = Color(0xffffb74d);
  static const Color conditionScared = Color(0xffba68c8);
  static const Color conditionDisheartened = Color(0xffa1887f);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onPrimary: textLight,
        onSecondary: textDark,
        onSurface: textLight,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textLight,
          letterSpacing: 1.2,
        ),
        displayMedium: GoogleFonts.cinzel(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        titleLarge: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          color: textLight,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 12,
          color: textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: accent,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xff333333), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: accent, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
