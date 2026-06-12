import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OndaTheme {
  static const Color bg = Color(0xFF0A0A14);
  static const Color surface = Color(0xFF13131F);
  static const Color card = Color(0xFF1C1C2E);
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color accent = Color(0xFFEC4899);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color divider = Color(0xFF1E1E30);

  static ThemeData dark() {
    final base = GoogleFonts.spaceGroteskTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: textPrimary, displayColor: textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: base,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.spaceGrotesk(color: primary, fontSize: 12, fontWeight: FontWeight.w600);
          }
          return GoogleFonts.spaceGrotesk(color: textSecondary, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return const IconThemeData(color: textSecondary);
        }),
      ),
      cardTheme: const CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: card,
        thumbColor: primary,
        overlayColor: Color(0x208B5CF6),
        trackHeight: 4,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textSecondary),
      ),
    );
  }
}
