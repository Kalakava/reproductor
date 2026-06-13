import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_provider.dart';

class SettingsState {
  final String fontFamily;
  final int primaryColorValue;
  final String? backgroundImagePath;
  final bool eqEnabled;
  final double eqBass;
  final double eqMid;
  final double eqTreble;
  final Map<String, String> customCovers; // songId -> local compressedWebPCoverPath
  final bool showSettingsGlow;

  const SettingsState({
    this.fontFamily = 'Roboto',
    this.primaryColorValue = 0xFF8B5CF6,
    this.backgroundImagePath,
    this.eqEnabled = false,
    this.eqBass = 0.0,
    this.eqMid = 0.0,
    this.eqTreble = 0.0,
    this.customCovers = const {},
    this.showSettingsGlow = false,
  });

  Color get primaryColor => Color(primaryColorValue);

  SettingsState copyWith({
    String? fontFamily,
    int? primaryColorValue,
    String? backgroundImagePath,
    bool? eqEnabled,
    double? eqBass,
    double? eqMid,
    double? eqTreble,
    Map<String, String>? customCovers,
    bool? showSettingsGlow,
  }) =>
      SettingsState(
        fontFamily: fontFamily ?? this.fontFamily,
        primaryColorValue: primaryColorValue ?? this.primaryColorValue,
        backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
        eqEnabled: eqEnabled ?? this.eqEnabled,
        eqBass: eqBass ?? this.eqBass,
        eqMid: eqMid ?? this.eqMid,
        eqTreble: eqTreble ?? this.eqTreble,
        customCovers: customCovers ?? this.customCovers,
        showSettingsGlow: showSettingsGlow ?? this.showSettingsGlow,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _prefFont = 'onda_font';
  static const _prefColor = 'onda_color';
  static const _prefBgImage = 'onda_bg_image';
  static const _prefEqEnabled = 'onda_eq_enabled';
  static const _prefEqBass = 'onda_eq_bass';
  static const _prefEqMid = 'onda_eq_mid';
  static const _prefEqTreble = 'onda_eq_treble';
  static const _prefCovers = 'onda_custom_covers';
  static const _prefLastVisit = 'onda_last_settings_visit';

  final Ref _ref;
  late final SharedPreferences _prefs;
  Timer? _eqDebounceTimer;

  SettingsNotifier(this._ref) : super(const SettingsState()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final font = _prefs.getString(_prefFont) ?? 'Roboto';
    final colorVal = _prefs.getInt(_prefColor) ?? 0xFF8B5CF6;
    final bgImage = _prefs.getString(_prefBgImage);
    final eqEnabled = _prefs.getBool(_prefEqEnabled) ?? false;
    final eqBass = _prefs.getDouble(_prefEqBass) ?? 0.0;
    final eqMid = _prefs.getDouble(_prefEqMid) ?? 0.0;
    final eqTreble = _prefs.getDouble(_prefEqTreble) ?? 0.0;
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
      eqEnabled: eqEnabled,
      eqBass: eqBass,
      eqMid: eqMid,
      eqTreble: eqTreble,
      customCovers: covers,
      showSettingsGlow: showGlow,
    );
    _syncEqualizer();
  }

  void _syncEqualizer() {
    final handler = _ref.read(audioHandlerProvider);
    if (handler != null) {
      handler.updateEqualizer(
        state.eqEnabled,
        state.eqBass,
        state.eqMid,
        state.eqTreble,
      );
    }
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

  Future<void> setEqEnabled(bool enabled) async {
    state = state.copyWith(eqEnabled: enabled);
    await _prefs.setBool(_prefEqEnabled, enabled);
    _syncEqualizer();
  }

  void setEqValues(double bass, double mid, double treble) {
    state = state.copyWith(eqBass: bass, eqMid: mid, eqTreble: treble);
    _eqDebounceTimer?.cancel();
    _eqDebounceTimer = Timer(const Duration(milliseconds: 100), () async {
      try {
        await _prefs.setDouble(_prefEqBass, bass);
        await _prefs.setDouble(_prefEqMid, mid);
        await _prefs.setDouble(_prefEqTreble, treble);
        _syncEqualizer();
      } catch (e) {
        debugPrint('[Onda] Error al guardar valores de ecualizador: $e');
      }
    });
  }

  @override
  void dispose() {
    _eqDebounceTimer?.cancel();
    super.dispose();
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
  return SettingsNotifier(ref);
});
