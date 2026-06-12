import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BackgroundThemeType {
  amoled,
  royalPurple,
  neonPink,
  electricOcean,
}

class BackgroundThemeNotifier extends StateNotifier<BackgroundThemeType> {
  static const _prefKey = 'onda_background_theme';
  late final SharedPreferences _prefs;

  BackgroundThemeNotifier() : super(BackgroundThemeType.royalPurple) {
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final index = _prefs.getInt(_prefKey);
      if (index != null && index >= 0 && index < BackgroundThemeType.values.length) {
        state = BackgroundThemeType.values[index];
      }
    } catch (_) {
      // Ignorar fallos de persistencia inicial
    }
  }

  Future<void> setTheme(BackgroundThemeType theme) async {
    state = theme;
    try {
      await _prefs.setInt(_prefKey, theme.index);
    } catch (_) {}
  }
}

final backgroundThemeProvider =
    StateNotifierProvider<BackgroundThemeNotifier, BackgroundThemeType>((ref) {
  return BackgroundThemeNotifier();
});

class BackgroundThemeHelper {
  static Decoration getDecoration(BackgroundThemeType type) {
    switch (type) {
      case BackgroundThemeType.amoled:
        return const BoxDecoration(
          color: Color(0xFF000000),
        );
      case BackgroundThemeType.royalPurple:
        return const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E0B36), // Púrpura oscuro
              Color(0xFF0A0A14), // Fondo base
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      case BackgroundThemeType.neonPink:
        return const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3A0B2E), // Magenta oscuro
              Color(0xFF0A0A14),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      case BackgroundThemeType.electricOcean:
        return const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B2836), // Cian oscuro
              Color(0xFF0A0A14),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
    }
  }

  static String getName(BackgroundThemeType type) {
    switch (type) {
      case BackgroundThemeType.amoled:
        return 'Espacio Profundo (AMOLED)';
      case BackgroundThemeType.royalPurple:
        return 'Onda Púrpura';
      case BackgroundThemeType.neonPink:
        return 'Aurora Rosa';
      case BackgroundThemeType.electricOcean:
        return 'Océano Eléctrico';
    }
  }

  static Color getPreviewColor(BackgroundThemeType type) {
    switch (type) {
      case BackgroundThemeType.amoled:
        return Colors.black;
      case BackgroundThemeType.royalPurple:
        return const Color(0xFF7C3AED);
      case BackgroundThemeType.neonPink:
        return const Color(0xFFEC4899);
      case BackgroundThemeType.electricOcean:
        return const Color(0xFF06B6D4);
    }
  }
}
