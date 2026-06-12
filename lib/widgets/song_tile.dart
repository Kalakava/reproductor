import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../providers/library_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/settings_provider.dart';
import '../services/library_service.dart';

class SongTile extends ConsumerWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRemoveFromPlaylist;
  final bool showRemoveFromPlaylist;
  final bool selectionMode;
  final bool isSelected;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onLongPress,
    this.onRemoveFromPlaylist,
    this.showRemoveFromPlaylist = false,
    this.selectionMode = false,
    this.isSelected = false,
  });

  String _fmt(int? ms) {
    final d = Duration(milliseconds: ms ?? 0);
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: isSelected
          ? OndaTheme.primary.withOpacity(0.15)
          : Colors.transparent,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: selectionMode
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Container(
                        key: const ValueKey('check'),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: OndaTheme.primary,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 24),
                      )
                    : _Artwork(albumId: song.albumId ?? 0, songId: song.id.toString(), size: 50),
              )
            : _Artwork(albumId: song.albumId ?? 0, songId: song.id.toString(), size: 50),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: OndaTheme.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 15),
        ),
        subtitle: Text(
          '${song.artist ?? 'Desconocido'} · ${_fmt(song.duration)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              const TextStyle(color: OndaTheme.textSecondary, fontSize: 12),
        ),
        trailing: selectionMode
            ? null
            : IconButton(
                icon: const Icon(Icons.more_vert,
                    color: OndaTheme.textSecondary, size: 20),
                onPressed: () => _showOptions(context, ref),
              ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                _Artwork(albumId: song.albumId ?? 0, songId: song.id.toString(), size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: OndaTheme.textPrimary,
                              fontWeight: FontWeight.w600)),
                      Text(song.artist ?? 'Desconocido',
                          style: const TextStyle(
                              color: OndaTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ]),
            ),
            const Divider(color: OndaTheme.divider, height: 24),
            _opt(ctx, Icons.playlist_add, 'Añadir a lista de reproducción',
                OndaTheme.primary, () {
              Navigator.pop(ctx);
              _showAddToPlaylist(context, ref);
            }),
            _opt(ctx, Icons.edit_note_rounded, 'Renombrar canción',
                OndaTheme.primary, () {
              Navigator.pop(ctx);
              _showRenameDialog(context, ref);
            }),
            _opt(ctx, Icons.photo_library_outlined, 'Cambiar carátula',
                OndaTheme.primary, () {
              Navigator.pop(ctx);
              _changeCover(context, ref);
            }),
            _opt(ctx, Icons.share_outlined, 'Compartir archivo',
                OndaTheme.primary, () async {
              Navigator.pop(ctx);
              await Share.shareXFiles([XFile(song.data)], text: song.title);
            }),
            _opt(ctx, Icons.folder_open_outlined, 'Mostrar en carpeta',
                OndaTheme.primary, () {
              Navigator.pop(ctx);
              _showInFolder(context);
            }),
            if (showRemoveFromPlaylist && onRemoveFromPlaylist != null)
              _opt(ctx, Icons.playlist_remove, 'Quitar de esta lista',
                  Colors.orangeAccent, () {
                Navigator.pop(ctx);
                onRemoveFromPlaylist!();
              }),
            _opt(ctx, Icons.delete_outline, 'Eliminar del dispositivo',
                Colors.redAccent, () {
              Navigator.pop(ctx);
              _confirmDelete(context, ref);
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _handle() => Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
          color: OndaTheme.textSecondary.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2)));

  Widget _opt(BuildContext ctx, IconData icon, String label, Color iconColor,
      VoidCallback onTap) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(label, style: TextStyle(color: iconColor == OndaTheme.primary ? OndaTheme.textPrimary : iconColor)),
      onTap: onTap,
    );
  }

  void _showInFolder(BuildContext context) async {
    final filePath = song.data;
    final dir = File(filePath).parent.path;
    final success = await LibraryService.openFolder(filePath);
    if (!success && context.mounted) {
      final result = await OpenFilex.open(dir);
      if (result.type != ResultType.done && context.mounted) {
      // Fallback: mostrar ruta
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ubicación del archivo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Carpeta:',
                  style: TextStyle(
                      color: OndaTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              SelectableText(dir,
                  style: const TextStyle(
                      fontSize: 13, color: OndaTheme.textPrimary)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar'))
          ],
        ),
      );
      }
    }
  }

  void _showAddToPlaylist(BuildContext context, WidgetRef ref) {
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
                  style: Theme.of(ctx).textTheme.titleMedium),
            ),
            Expanded(
              child: playlists.isEmpty
                  ? const Center(
                      child: Text('No hay listas. Crea una primero.',
                          style: TextStyle(color: OndaTheme.textSecondary)))
                  : ListView.builder(
                      controller: sc,
                      itemCount: playlists.length,
                      itemBuilder: (_, i) {
                        final p = playlists[i];
                        final already = p.songIds.contains(song.id);
                        return ListTile(
                          leading: const Icon(Icons.queue_music,
                              color: OndaTheme.primary),
                          title: Text(p.name),
                          subtitle: Text('${p.songIds.length} canciones',
                              style: const TextStyle(
                                  color: OndaTheme.textSecondary,
                                  fontSize: 12)),
                          trailing: already
                              ? const Icon(Icons.check,
                                  color: OndaTheme.primary, size: 18)
                              : null,
                          onTap: () {
                            ref
                                .read(playlistProvider.notifier)
                                .addSong(p.id, song.id);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Añadida a "${p.name}"')));
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar canción'),
        content: Text(
            '¿Eliminar "${song.title}" del dispositivo? Esta acción no se puede deshacer.'),
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
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _changeCover(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final compressedPath = await LibraryService.compressArtwork(image.path, song.id.toString());
        if (compressedPath != null) {
          await ref.read(settingsProvider.notifier).setCustomCover(song.id.toString(), compressedPath);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carátula actualizada con éxito.')));
          }
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al procesar la carátula.')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: song.title);
    final currentFileName = File(song.data).uri.pathSegments.last;
    final fileController = TextEditingController(text: currentFileName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renombrar Canción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título de la canción',
                hintText: 'Ej. Mi Canción',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fileController,
              decoration: const InputDecoration(
                labelText: 'Nombre del archivo',
                hintText: 'Ej. cancion.mp3',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final newTitle = titleController.text.trim();
              final newFileName = fileController.text.trim();
              if (newTitle.isNotEmpty && newFileName.isNotEmpty) {
                Navigator.pop(ctx);
                final success = await ref
                    .read(libraryProvider.notifier)
                    .renameSong(song, newTitle, newFileName);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Canción renombrada correctamente.')));
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al renombrar el archivo. Verifica los permisos.')));
                }
              }
            },
            child: const Text('Renombrar'),
          ),
        ],
      ),
    );
  }
}

// ─── Artwork helper ───────────────────────────────────────────────────────────

class _Artwork extends ConsumerWidget {
  final int albumId;
  final String songId;
  final double size;
  const _Artwork({required this.albumId, required this.songId, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final customCoverPath = settings.customCovers[songId];

    if (customCoverPath != null && File(customCoverPath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.18),
        child: Image.file(
          File(customCoverPath),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    final primaryColor = settings.primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.18),
      child: QueryArtworkWidget(
        id: albumId,
        type: ArtworkType.ALBUM,
        artworkWidth: size,
        artworkHeight: size,
        artworkFit: BoxFit.cover,
        keepOldArtwork: true,
        nullArtworkWidget: Container(
          width: size,
          height: size,
          color: OndaTheme.card,
          child: Icon(Icons.music_note,
              color: primaryColor, size: size * 0.45),
        ),
      ),
    );
  }
}
