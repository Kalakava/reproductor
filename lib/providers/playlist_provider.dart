import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
import '../services/playlist_storage.dart';

class PlaylistNotifier extends StateNotifier<List<Playlist>> {
  PlaylistNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await PlaylistStorage.load();
  }

  Future<void> _save() => PlaylistStorage.save(state);

  Future<void> create(String name) async {
    state = [...state, Playlist.create(name)];
    await _save();
  }

  Future<void> rename(String id, String name) async {
    state = [for (final p in state) if (p.id == id) p.copyWith(name: name) else p];
    await _save();
  }

  Future<void> delete(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _save();
  }

  Future<void> addSong(String playlistId, int songId) async {
    state = [
      for (final p in state)
        if (p.id == playlistId && !p.songIds.contains(songId))
          p.copyWith(songIds: [...p.songIds, songId])
        else
          p
    ];
    await _save();
  }

  Future<void> removeSong(String playlistId, int songId) async {
    state = [
      for (final p in state)
        if (p.id == playlistId)
          p.copyWith(songIds: p.songIds.where((id) => id != songId).toList())
        else
          p
    ];
    await _save();
  }
}

final playlistProvider =
    StateNotifierProvider<PlaylistNotifier, List<Playlist>>((ref) {
  return PlaylistNotifier();
});
