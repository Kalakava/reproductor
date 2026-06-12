import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/playlist.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../providers/playlist_provider.dart';
import '../theme.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistProvider);
    final playlist = playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => Playlist(
          id: '', name: '', songIds: const [], createdAt: DateTime.now()),
    );

    if (playlist.id.isEmpty) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Lista no encontrada')));
    }

    final allSongs = ref.watch(libraryProvider).songs;
    final songs = playlist.songIds
        .map((id) {
          try {
            return allSongs.firstWhere((s) => s.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<SongModel>()
        .toList();

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: true,
        child: CustomScrollView(
          slivers: [
          // ── Cabecera ────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(playlist.name,
                  style: const TextStyle(
                      color: OndaTheme.textPrimary,
                      fontWeight: FontWeight.w700)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [OndaTheme.primaryDark, OndaTheme.bg],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.queue_music_rounded,
                      size: 80, color: Colors.white24),
                ),
              ),
            ),
            actions: [
              if (songs.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.shuffle_rounded),
                  tooltip: 'Reproducir en aleatorio',
                  onPressed: () => _playShuffle(context, ref, songs),
                ),
            ],
          ),

          // ── Barra de acción ─────────────────────────────────────────────
          if (songs.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      '${songs.length} canciones',
                      style: const TextStyle(color: OndaTheme.textSecondary),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _playAll(context, ref, songs),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Reproducir todo'),
                    ),
                  ],
                ),
              ),
            ),

          // ── Lista ────────────────────────────────────────────────────────
          songs.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.music_off,
                          size: 64, color: OndaTheme.textSecondary),
                      const SizedBox(height: 12),
                      const Text('Esta lista está vacía',
                          style: TextStyle(color: OndaTheme.textSecondary)),
                      const SizedBox(height: 6),
                      const Text('Añade canciones desde la pestaña Canciones',
                          style: TextStyle(
                              color: OndaTheme.textSecondary, fontSize: 12)),
                    ]),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final song = songs[i];
                      return SongTile(
                        song: song,
                        showRemoveFromPlaylist: true,
                        onTap: () => _playSongAt(context, ref, songs, i),
                        onRemoveFromPlaylist: () => ref
                            .read(playlistProvider.notifier)
                            .removeSong(playlistId, song.id),
                      );
                    },
                    childCount: songs.length,
                  ),
                ),
        ],
      ),
      ),
    );
  }

  void _navigate(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const NowPlayingScreen(),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  void _playAll(BuildContext context, WidgetRef ref, List<SongModel> songs) {
    ref.read(playerProvider.notifier).playFromQueue(songs);
    _navigate(context);
  }

  void _playSongAt(
      BuildContext context, WidgetRef ref, List<SongModel> songs, int i) {
    ref
        .read(playerProvider.notifier)
        .playFromQueue(songs, initialIndex: i);
    _navigate(context);
  }

  void _playShuffle(
      BuildContext context, WidgetRef ref, List<SongModel> songs) async {
    final notifier = ref.read(playerProvider.notifier);
    await notifier.playFromQueue(songs);
    await notifier.toggleShuffle();
    _navigate(context);
  }
}
