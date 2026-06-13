import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/playlist.dart';
import '../providers/library_provider.dart';
import '../providers/playlist_provider.dart';
import '../theme.dart';
import 'playlist_detail_screen.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Listas')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: OndaTheme.primary,
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: playlists.isEmpty
          ? const _EmptyPlaylists()
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: playlists.length,
              itemBuilder: (_, i) => _PlaylistTile(playlist: playlists[i]),
            ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OndaTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OndaTheme.textSecondary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Crear nueva lista',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OndaTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded, color: OndaTheme.primary),
              title: const Text('Crear lista vacía', style: TextStyle(color: OndaTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _showNameDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_rounded, color: OndaTheme.primary),
              title: const Text('Crear desde carpeta', style: TextStyle(color: OndaTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _showFolderPlaylistSheet(context, ref);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showNameDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva lista'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la lista'),
          onSubmitted: (v) => _create(ctx, ref, ctrl),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => _create(ctx, ref, ctrl),
              child: const Text('Crear')),
        ],
      ),
    );
  }

  void _create(BuildContext ctx, WidgetRef ref, TextEditingController ctrl) {
    final name = ctrl.text.trim();
    if (name.isEmpty) return;
    ref.read(playlistProvider.notifier).create(name);
    Navigator.pop(ctx);
  }

  void _showFolderPlaylistSheet(BuildContext context, WidgetRef ref) {
    final songs = ref.read(libraryProvider).songs;
    
    // Agrupar canciones por directorio padre
    final Map<String, List<SongModel>> folderMap = {};
    for (final song in songs) {
      final parentPath = File(song.data).parent.path;
      if (!folderMap.containsKey(parentPath)) {
        folderMap[parentPath] = [];
      }
      folderMap[parentPath]!.add(song);
    }

    final folderPaths = folderMap.keys.toList()..sort((a, b) {
      final nameA = a.split('/').last.toLowerCase();
      final nameB = b.split('/').last.toLowerCase();
      return nameA.compareTo(nameB);
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: OndaTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, sc) => Column(
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OndaTheme.textSecondary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Seleccionar carpeta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OndaTheme.textPrimary),
              ),
            ),
            Expanded(
              child: folderPaths.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron carpetas con música.',
                        style: TextStyle(color: OndaTheme.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      controller: sc,
                      itemCount: folderPaths.length,
                      itemBuilder: (context, index) {
                        final path = folderPaths[index];
                        final folderName = path.split('/').last;
                        final folderSongs = folderMap[path]!;

                        return ListTile(
                          leading: const Icon(Icons.folder, color: OndaTheme.primary),
                          title: Text(folderName, style: const TextStyle(color: OndaTheme.textPrimary)),
                          subtitle: Text(
                            '${folderSongs.length} canciones • $path',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: OndaTheme.textSecondary, fontSize: 11),
                          ),
                          onTap: () {
                            final songIds = folderSongs.map((s) => s.id).toList();
                            ref.read(playlistProvider.notifier).createWithSongs(folderName, songIds);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lista "$folderName" creada con ${songIds.length} canciones'),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tile de lista ────────────────────────────────────────────────────────────

class _PlaylistTile extends ConsumerWidget {
  final Playlist playlist;
  const _PlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: OndaTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.queue_music_rounded, color: OndaTheme.primary),
      ),
      title: Text(
        playlist.name,
        style: const TextStyle(
            color: OndaTheme.textPrimary, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${playlist.songIds.length} canciones',
        style: const TextStyle(color: OndaTheme.textSecondary, fontSize: 12),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: OndaTheme.textSecondary),
        color: OndaTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (v) {
          if (v == 'rename') _showRename(context, ref);
          if (v == 'delete') _confirmDelete(context, ref);
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'rename', child: Text('Renombrar')),
          PopupMenuItem(
              value: 'delete',
              child: Text('Eliminar lista',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PlaylistDetailScreen(playlistId: playlist.id),
        ),
      ),
    );
  }

  void _showRename(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renombrar lista'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nuevo nombre'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              ref.read(playlistProvider.notifier).rename(playlist.id, name);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar lista'),
        content: Text(
            '¿Eliminar "${playlist.name}"? Las canciones no se borrarán del dispositivo.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(playlistProvider.notifier).delete(playlist.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ─── Estado vacío ─────────────────────────────────────────────────────────────

class _EmptyPlaylists extends StatelessWidget {
  const _EmptyPlaylists();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.queue_music_rounded, size: 72, color: OndaTheme.textSecondary),
        SizedBox(height: 16),
        Text('Aún no hay listas',
            style: TextStyle(
                color: OndaTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text('Pulsa + para crear tu primera lista',
            style: TextStyle(color: OndaTheme.textSecondary)),
      ]),
    );
  }
}
