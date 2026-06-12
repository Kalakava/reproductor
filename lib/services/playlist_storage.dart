import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';

class PlaylistStorage {
  static const String _key = 'onda_playlists_v1';

  static Future<List<Playlist>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Playlist.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Playlist.encodeList(playlists));
  }
}
