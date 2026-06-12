import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
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
