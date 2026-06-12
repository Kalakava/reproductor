import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/player_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/library_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../services/library_service.dart';
import '../theme.dart';

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final song = state.currentSong;

    if (song == null) {
      return const Scaffold(
          body: Center(child: Text('No hay nada en reproducción')));
    }

    final screenHeight = MediaQuery.sizeOf(context).height;
    final isSmallScreen = screenHeight < 620;
    final settings = ref.watch(settingsProvider);
    final bgTheme = ref.watch(backgroundThemeProvider);
    final hasBgImage = settings.backgroundImagePath != null && File(settings.backgroundImagePath!).existsSync();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reproduciendo',
            style: TextStyle(fontSize: 14, color: OndaTheme.textSecondary)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Cambiar fondo',
            onPressed: () => _showThemeSelector(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context, ref, song),
          ),
        ],
      ),
      body: Container(
        decoration: hasBgImage
            ? BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(settings.backgroundImagePath!)),
                  fit: BoxFit.cover,
                ),
              )
            : BackgroundThemeHelper.getDecoration(bgTheme),
        child: ClipRect(
          child: BackdropFilter(
            filter: hasBgImage
                ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              color: hasBgImage ? Colors.black.withOpacity(0.65) : Colors.transparent,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      // ── Portada ──────────────────────────────────────────────────
                      _AlbumArt(
                        songId: song.id.toString(),
                        albumId: song.albumId ?? 0,
                        isPlaying: state.isPlaying,
                      ),
                      const Spacer(flex: 2),
                      // ── Título ───────────────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: isSmallScreen ? 20 : 22,
                                      fontWeight: FontWeight.w700,
                                      color: OndaTheme.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  song.artist ?? 'Artista desconocido',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: OndaTheme.textSecondary, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.playlist_add,
                                color: OndaTheme.primary, size: 28),
                            onPressed: () =>
                                _showAddToPlaylist(context, ref, song.id),
                            tooltip: 'Añadir a lista',
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 28),
                      // ── Barra de progreso ─────────────────────────────────────────
                      _ProgressBar(state: state, ref: ref),
                      SizedBox(height: isSmallScreen ? 12 : 20),
                      // ── Controles principales ─────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _LoopButton(state: state, ref: ref),
                          _NavButton(
                            icon: Icons.skip_previous_rounded,
                            size: isSmallScreen ? 30 : 36,
                            onTap: () => ref.read(playerProvider.notifier).previous(),
                          ),
                          _PlayPauseButton(isPlaying: state.isPlaying, ref: ref),
                          _NavButton(
                            icon: Icons.skip_next_rounded,
                            size: isSmallScreen ? 30 : 36,
                            onTap: () => ref.read(playerProvider.notifier).next(),
                          ),
                          _ShuffleButton(state: state, ref: ref),
                        ],
                      ),
                      const Spacer(flex: 3),
                      // ── Marca de agua de autoría ─────────────────────────────────
                      Text(
                        'Onda • Desarrollado por Damián Arenas',
                        style: TextStyle(
                          color: OndaTheme.textSecondary.withOpacity(0.25),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OndaTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final current = ref.watch(backgroundThemeProvider);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: OndaTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Personalizar fondo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: OndaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...BackgroundThemeType.values.map((theme) {
                  final selected = theme == current;
                  return ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: BackgroundThemeHelper.getPreviewColor(theme),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    title: Text(
                      BackgroundThemeHelper.getName(theme),
                      style: TextStyle(
                        color: selected ? OndaTheme.primary : OndaTheme.textPrimary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check_circle, color: OndaTheme.primary)
                        : null,
                    onTap: () {
                      ref.read(backgroundThemeProvider.notifier).setTheme(theme);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OndaTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _handle(),
            const SizedBox(height: 8),
            ListTile(
              leading:
                  const Icon(Icons.playlist_add, color: OndaTheme.primary),
              title: const Text('Añadir a lista de reproducción'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddToPlaylist(context, ref, song.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: OndaTheme.primary),
              title: const Text('Compartir archivo'),
              onTap: () async {
                Navigator.pop(ctx);
                await Share.shareXFiles([XFile(song.data)], text: song.title);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined,
                  color: OndaTheme.primary),
              title: const Text('Mostrar en carpeta'),
              subtitle: Text(File(song.data).parent.path,
                  style: const TextStyle(
                      fontSize: 11, color: OndaTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              onTap: () async {
                Navigator.pop(ctx);
                final filePath = song.data;
                final dir = File(filePath).parent.path;
                final success = await LibraryService.openFolder(filePath);
                if (!success && context.mounted) {
                  final res = await OpenFilex.open(dir);
                  if (res.type != ResultType.done && context.mounted) {
                    _showPathDialog(context, dir);
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Eliminar del dispositivo',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref, song);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPathDialog(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubicación del archivo'),
        content: SelectableText(path,
            style: const TextStyle(color: OndaTheme.textPrimary, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'))
        ],
      ),
    );
  }

  void _showAddToPlaylist(BuildContext context, WidgetRef ref, int songId) {
    final playlists = ref.read(playlistProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: OndaTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, sc) => Column(
          children: [
            const SizedBox(height: 8),
            _handle(),
            Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Añadir a lista',
                    style: Theme.of(ctx).textTheme.titleMedium)),
            Expanded(
              child: playlists.isEmpty
                  ? const Center(
                      child: Text('No hay listas. Crea una primero.',
                          style:
                              TextStyle(color: OndaTheme.textSecondary)))
                  : ListView.builder(
                      controller: sc,
                      itemCount: playlists.length,
                      itemBuilder: (_, i) {
                        final p = playlists[i];
                        return ListTile(
                          leading: const Icon(Icons.queue_music,
                              color: OndaTheme.primary),
                          title: Text(p.name),
                          subtitle: Text('${p.songIds.length} canciones',
                              style: const TextStyle(
                                  color: OndaTheme.textSecondary,
                                  fontSize: 12)),
                          trailing: p.songIds.contains(songId)
                              ? const Icon(Icons.check,
                                  color: OndaTheme.primary, size: 18)
                              : null,
                          onTap: () {
                            ref
                                .read(playlistProvider.notifier)
                                .addSong(p.id, songId);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Añadida a "${p.name}"')));
                          },
                        );
                      },
                    ),
            ),
            const SafeArea(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, SongModel song) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar canción'),
        content: Text(
            '¿Eliminar "${song.title}" del dispositivo? Esta acción es permanente.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(libraryProvider.notifier)
                  .deleteSong(context, song);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _handle() => Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
          color: OndaTheme.textSecondary.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2)));
}

// ─── Portada animada ──────────────────────────────────────────────────────────

// ─── Portada animada ──────────────────────────────────────────────────────────

class _AlbumArt extends ConsumerWidget {
  final String songId;
  final int albumId;
  final bool isPlaying;
  const _AlbumArt({
    required this.songId,
    required this.albumId,
    required this.isPlaying,
  });

  Future<void> _editCover(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final compressedPath = await LibraryService.compressArtwork(image.path, songId);
        if (compressedPath != null) {
          await ref.read(settingsProvider.notifier).setCustomCover(songId, compressedPath);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Carátula actualizada con éxito.')),
            );
          }
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al procesar la carátula.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final customCoverPath = settings.customCovers[songId];
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Adaptar dinámicamente el tamaño de la portada en función de la altura disponible
    final double maxSize = (screenHeight * 0.35).clamp(160.0, 280.0);
    final double currentSize = isPlaying ? maxSize : maxSize * 0.85;

    Widget artwork;
    if (customCoverPath != null && File(customCoverPath).existsSync()) {
      artwork = Image.file(
        File(customCoverPath),
        width: currentSize,
        height: currentSize,
        fit: BoxFit.cover,
      );
    } else {
      artwork = QueryArtworkWidget(
        id: albumId,
        type: ArtworkType.ALBUM,
        artworkWidth: 300,
        artworkHeight: 300,
        artworkFit: BoxFit.cover,
        keepOldArtwork: true,
        nullArtworkWidget: Container(
          color: OndaTheme.card,
          child: Icon(Icons.music_note,
              size: currentSize * 0.35, color: settings.primaryColor),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _editCover(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: currentSize,
        height: currentSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: settings.primaryColor.withOpacity(isPlaying ? 0.35 : 0.15),
              blurRadius: isPlaying ? 50 : 20,
              spreadRadius: isPlaying ? 8 : 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: artwork,
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Barra de progreso ────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final PlayerStateModel state;
  final WidgetRef ref;
  const _ProgressBar({required this.state, required this.ref});

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final pct = state.duration.inMilliseconds > 0
        ? (state.position.inMilliseconds / state.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: pct,
            onChanged: (v) {
              final pos = Duration(
                  milliseconds: (v * state.duration.inMilliseconds).round());
              ref.read(playerProvider.notifier).seekTo(pos);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(state.position),
                  style: const TextStyle(
                      color: OndaTheme.textSecondary, fontSize: 12)),
              Text(_fmt(state.duration),
                  style: const TextStyle(
                      color: OndaTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Botón play/pausa ────────────────────────────────────────────────────────

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final WidgetRef ref;
  const _PlayPauseButton({required this.isPlaying, required this.ref});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isSmallScreen = screenHeight < 620;
    final double buttonSize = isSmallScreen ? 60.0 : 72.0;
    final double iconSize = isSmallScreen ? 32.0 : 38.0;

    return GestureDetector(
      onTap: () => ref.read(playerProvider.notifier).togglePlay(),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [OndaTheme.primary, OndaTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: OndaTheme.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: OndaTheme.textPrimary),
      onPressed: onTap,
      splashRadius: 28,
    );
  }
}

class _LoopButton extends StatelessWidget {
  final PlayerStateModel state;
  final WidgetRef ref;
  const _LoopButton({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final active = state.loopMode != LoopMode.off;
    return IconButton(
      icon: Icon(
        state.loopMode == LoopMode.one
            ? Icons.repeat_one_rounded
            : Icons.repeat_rounded,
        color: active ? OndaTheme.primary : OndaTheme.textSecondary,
        size: 22,
      ),
      onPressed: () => ref.read(playerProvider.notifier).cycleLoopMode(),
      tooltip: state.loopMode == LoopMode.off
          ? 'Bucle desactivado'
          : state.loopMode == LoopMode.all
              ? 'Bucle de lista'
              : 'Bucle de una',
    );
  }
}

class _ShuffleButton extends StatelessWidget {
  final PlayerStateModel state;
  final WidgetRef ref;
  const _ShuffleButton({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.shuffle_rounded,
        color: state.shuffle ? OndaTheme.primary : OndaTheme.textSecondary,
        size: 22,
      ),
      onPressed: () => ref.read(playerProvider.notifier).toggleShuffle(),
      tooltip: state.shuffle ? 'Aleatorio activado' : 'Aleatorio desactivado',
    );
  }
}
