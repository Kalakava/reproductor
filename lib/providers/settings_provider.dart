import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final String fontFamily;
  final int primaryColorValue;
  final String? backgroundImagePath;
  final Map<String, String> customCovers; // songId -> local compressedWebPCoverPath
  final bool showSettingsGlow;

  const SettingsState({
    this.fontFamily = 'Roboto',
    this.primaryColorValue = 0xFF8B5CF6,
    this.backgroundImagePath,
    this.customCovers = const {},
    this.showSettingsGlow = false,
  });

  Color get primaryColor => Color(primaryColorValue);

  SettingsState copyWith({
    String? fontFamily,
    int? primaryColorValue,
    String? backgroundImagePath,
    Map<String, String>? customCovers,
    bool? showSettingsGlow,
  }) =>
      SettingsState(
        fontFamily: fontFamily ?? this.fontFamily,
        primaryColorValue: primaryColorValue ?? this.primaryColorValue,
        backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
        customCovers: customCovers ?? this.customCovers,
        showSettingsGlow: showSettingsGlow ?? this.showSettingsGlow,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _prefFont = 'onda_font';
  static const _prefColor = 'onda_color';
  static const _prefBgImage = 'onda_bg_image';
  static const _prefCovers = 'onda_custom_covers';
  static const _prefLastVisit = 'onda_last_settings_visit';

  late final SharedPreferences _prefs;

  SettingsNotifier() : super(const SettingsState()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final font = _prefs.getString(_prefFont) ?? 'Roboto';
    final colorVal = _prefs.getInt(_prefColor) ?? 0xFF8B5CF6;
    final bgImage = _prefs.getString(_prefBgImage);
    final coversJson = _prefs.getString(_prefCovers);
    Map<String, String> covers = {};
    if (coversJson != null) {
      try {
        final decoded = jsonDecode(coversJson) as Map<String, dynamic>;
        covers = decoded.map((key, value) => MapEntry(key, value.toString()));
      } catch (_) {}
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastVisit = _prefs.getString(_prefLastVisit);
    final showGlow = lastVisit != today;

    state = SettingsState(
      fontFamily: font,
      primaryColorValue: colorVal,
      backgroundImagePath: bgImage,
      customCovers: covers,
      showSettingsGlow: showGlow,
    );
  }

  Future<void> setFontFamily(String font) async {
    state = state.copyWith(fontFamily: font);
    await _prefs.setString(_prefFont, font);
  }

  Future<void> setPrimaryColor(Color color) async {
    state = state.copyWith(primaryColorValue: color.value);
    await _prefs.setInt(_prefColor, color.value);
  }

  Future<void> setBackgroundImagePath(String? path) async {
    state = state.copyWith(backgroundImagePath: path);
    if (path == null) {
      await _prefs.remove(_prefBgImage);
    } else {
      await _prefs.setString(_prefBgImage, path);
    }
  }

  Future<void> setCustomCover(String songId, String? localPath) async {
    final updated = Map<String, String>.from(state.customCovers);
    if (localPath == null) {
      updated.remove(songId);
    } else {
      updated[songId] = localPath;
    }
    state = state.copyWith(customCovers: updated);
    await _prefs.setString(_prefCovers, jsonEncode(updated));
  }

  Future<void> markSettingsVisited() async {
    if (!state.showSettingsGlow) return;
    state = state.copyWith(showSettingsGlow: false);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _prefs.setString(_prefLastVisit, today);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
