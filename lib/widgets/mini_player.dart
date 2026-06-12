import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/player_provider.dart';
import '../theme.dart';
import '../screens/now_playing_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final song = state.currentSong;
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const NowPlayingScreen(),
          transitionsBuilder: (_, a, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
      child: Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        decoration: BoxDecoration(
          color: OndaTheme.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: OndaTheme.primary.withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            // Artwork
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: QueryArtworkWidget(
                id: song.albumId ?? 0,
                type: ArtworkType.ALBUM,
                artworkWidth: 50,
                artworkHeight: 50,
                artworkFit: BoxFit.cover,
                keepOldArtwork: true,
                nullArtworkWidget: Container(
                  width: 50,
                  height: 50,
                  color: OndaTheme.surface,
                  child:
                      const Icon(Icons.music_note, color: OndaTheme.primary, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: OndaTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist ?? 'Desconocido',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: OndaTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Controls
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded,
                  color: OndaTheme.textSecondary),
              onPressed: () => ref.read(playerProvider.notifier).previous(),
              splashRadius: 20,
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: OndaTheme.primary, shape: BoxShape.circle),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => ref.read(playerProvider.notifier).togglePlay(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded,
                  color: OndaTheme.textSecondary),
              onPressed: () => ref.read(playerProvider.notifier).next(),
              splashRadius: 20,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
