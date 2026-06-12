import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/library_service.dart';

enum LibraryStatus { initial, loading, loaded, error, noPermission }

// ─── Estado ───────────────────────────────────────────────────────────────────

class LibraryState {
  final LibraryStatus status;
  final List<SongModel> songs;
  final String searchQuery;
  final String? errorMessage;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.songs = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  List<SongModel> get filteredSongs {
    if (searchQuery.isEmpty) return songs;
    final q = searchQuery.toLowerCase();
    return songs
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            (s.artist?.toLowerCase().contains(q) ?? false) ||
            (s.album?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  LibraryState copyWith({
    LibraryStatus? status,
    List<SongModel>? songs,
    String? searchQuery,
    String? errorMessage,
  }) =>
      LibraryState(
        status: status ?? this.status,
        songs: songs ?? this.songs,
        searchQuery: searchQuery ?? this.searchQuery,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class LibraryNotifier extends StateNotifier<LibraryState> {
  LibraryNotifier() : super(const LibraryState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(status: LibraryStatus.loading);

    // Solicitar permiso de notificaciones en Android para los controles flotantes
    if (Platform.isAndroid) {
      try {
        final status = await Permission.notification.status;
        if (status.isDenied) {
          await Permission.notification.request();
        }
      } catch (e) {
        debugPrint('[Onda] Error al solicitar permiso de notificación: $e');
      }
    }

    final hasPermission = await LibraryService.checkPermission();
    if (!hasPermission) {
      final granted = await LibraryService.requestPermission();
      if (!granted) {
        state = state.copyWith(status: LibraryStatus.noPermission);
        return;
      }
    }
    await loadSongs();
  }

  Future<void> loadSongs({bool forceScan = false}) async {
    state = state.copyWith(status: LibraryStatus.loading);
    try {
      if (forceScan) {
        await LibraryService.scanForNewFiles();
      }
      final songs = await LibraryService.getAllSongs();
      state = state.copyWith(status: LibraryStatus.loaded, songs: songs);
    } catch (e) {
      state = state.copyWith(
          status: LibraryStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> requestPermission() => _init();

  void search(String query) => state = state.copyWith(searchQuery: query);

  Future<void> deleteSong(BuildContext context, SongModel song) async {
    final ok = await LibraryService.deleteSong(context, song);
    if (ok) {
      state = state.copyWith(
          songs: state.songs.where((s) => s.id != song.id).toList());
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final libraryProvider =
    StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier();
});
