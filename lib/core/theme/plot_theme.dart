import 'package:flutter/material.dart';

class PlotTheme {
  static const ink = Color(0xFF0A100C);
  static const surface = Color(0xFF111A14);
  static const surfaceRaised = Color(0xFF162019);
  static const border = Color(0xFF2A382F);
  static const text = Color(0xFFEAECE7);
  static const muted = Color(0xFF8E9890);
  static const gold = Color(0xFFE3B567);

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
      surface: ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme.copyWith(
        primary: gold,
        surface: ink,
        surfaceContainerHighest: surfaceRaised,
        outline: border,
      ),
      scaffoldBackgroundColor: ink,
      fontFamily: 'Georgia',
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: text,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          color: text,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: text, fontSize: 14),
        bodyMedium: TextStyle(color: muted, fontSize: 12),
        labelLarge: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ink,
        labelStyle: const TextStyle(color: muted, letterSpacing: 1.4),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: gold),
        ),
      ),
    );
  }
}
