import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../providers/playlist_provider.dart';
import '../theme.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';
import 'credits_screen.dart';

class SongsScreen extends ConsumerStatefulWidget {
  const SongsScreen({super.key});

  @override
  ConsumerState<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends ConsumerState<SongsScreen> {
  final _searchCtrl = TextEditingController();
  bool _searching = false;

  // ── Selección en lote ──────────────────────────────────────────────────────
  final Set<int> _selectedIds = {};
  bool get _selectionMode => _selectedIds.isNotEmpty;

  void _toggleSelect(int songId) {
    setState(() {
      if (_selectedIds.contains(songId)) {
        _selectedIds.remove(songId);
      } else {
        _selectedIds.add(songId);
      }
    });
  }

  void _clearSelection() => setState(() => _selectedIds.clear());

  void _selectAll(List<SongModel> songs) {
    setState(() {
      _selectedIds.addAll(songs.map((s) => s.id));
    });
  }

  // ── Añadir selección a lista ───────────────────────────────────────────────
  void _showAddBatchToPlaylist(BuildContext context, List<int> songIds) {
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
              child: Text(
                'Añadir ${songIds.length} canciones a lista',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
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
                        return ListTile(
                          leading: const Icon(Icons.queue_music,
                              color: OndaTheme.primary),
                          title: Text(p.name),
                          subtitle: Text('${p.songIds.length} canciones',
                              style: const TextStyle(
                                  color: OndaTheme.textSecondary,
                                  fontSize: 12)),
                          onTap: () {
                            for (final id in songIds) {
                              ref
                                  .read(playlistProvider.notifier)
                                  .addSong(p.id, id);
                            }
                            Navigator.pop(ctx);
                            _clearSelection();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${songIds.length} canciones añadidas a "${p.name}"'),
                              ),
                            );
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

  Widget _handle() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: OndaTheme.textSecondary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2)),
        ),
      );

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lib = ref.watch(libraryProvider);

    return Scaffold(
      appBar: _selectionMode
          ? _selectionAppBar(lib.filteredSongs)
          : _normalAppBar(),
      body: _body(lib),
    );
  }

  // ── App bar normal ─────────────────────────────────────────────────────────
  AppBar _normalAppBar() => AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(
                    color: OndaTheme.textPrimary, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Buscar canción, artista…',
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (q) =>
                    ref.read(libraryProvider.notifier).search(q),
              )
            : const Text('Onda'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) {
                _searchCtrl.clear();
                ref.read(libraryProvider.notifier).search('');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reescanear biblioteca',
            onPressed: () =>
                ref.read(libraryProvider.notifier).loadSongs(forceScan: true),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Acerca de',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreditsScreen()),
            ),
          ),
        ],
      );

  // ── App bar modo selección ─────────────────────────────────────────────────
  AppBar _selectionAppBar(List<SongModel> allSongs) => AppBar(
        backgroundColor: OndaTheme.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _clearSelection,
        ),
        title: Text('${_selectedIds.length} seleccionadas'),
        actions: [
          TextButton(
            onPressed: () => _selectAll(allSongs),
            child: const Text('Todas',
                style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Añadir a lista',
            onPressed: () => _showAddBatchToPlaylist(
                context, _selectedIds.toList()),
          ),
        ],
      );

  Widget _body(LibraryState lib) {
    return switch (lib.status) {
      LibraryStatus.initial || LibraryStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      LibraryStatus.noPermission => _PermissionPrompt(
          onGrant: () =>
              ref.read(libraryProvider.notifier).requestPermission()),
      LibraryStatus.error => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(lib.errorMessage ?? 'Error desconocido',
                style:
                    const TextStyle(color: OndaTheme.textSecondary)),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: () =>
                    ref.read(libraryProvider.notifier).loadSongs(),
                child: const Text('Reintentar')),
          ])),
      LibraryStatus.loaded => _SongsList(
          songs: lib.filteredSongs,
          selectedIds: _selectedIds,
          selectionMode: _selectionMode,
          onToggleSelect: _toggleSelect,
          onLongPress: (id) {
            if (!_selectionMode) setState(() => _selectedIds.add(id));
          },
        ),
    };
  }
}

// ─── Lista ────────────────────────────────────────────────────────────────────

class _SongsList extends ConsumerWidget {
  final List<SongModel> songs;
  final Set<int> selectedIds;
  final bool selectionMode;
  final void Function(int) onToggleSelect;
  final void Function(int) onLongPress;

  const _SongsList({
    required this.songs,
    required this.selectedIds,
    required this.selectionMode,
    required this.onToggleSelect,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (songs.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off, size: 56, color: OndaTheme.textSecondary),
          SizedBox(height: 12),
          Text('Sin resultados',
              style: TextStyle(color: OndaTheme.textSecondary)),
        ]),
      );
    }

    return ListView.builder(
      // Padding inferior para que el mini-player flotante no tape el último item
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: songs.length,
      itemBuilder: (_, i) {
        final song = songs[i];
        final selected = selectedIds.contains(song.id);
        return SongTile(
          song: song,
          isSelected: selected,
          selectionMode: selectionMode,
          onTap: () {
            if (selectionMode) {
              onToggleSelect(song.id);
            } else {
              ref
                  .read(playerProvider.notifier)
                  .playFromQueue(songs, initialIndex: i);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, a, __) => const NowPlayingScreen(),
                  transitionsBuilder: (_, a, __, child) =>
                      SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero)
                        .animate(CurvedAnimation(
                            parent: a,
                            curve: Curves.easeOutCubic)),
                    child: child,
                  ),
                ),
              );
            }
          },
          onLongPress: () => onLongPress(song.id),
        );
      },
    );
  }
}

// ─── Prompt de permisos ───────────────────────────────────────────────────────

class _PermissionPrompt extends StatelessWidget {
  final VoidCallback onGrant;
  const _PermissionPrompt({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: OndaTheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_open_rounded,
                size: 48, color: OndaTheme.primary),
          ),
          const SizedBox(height: 28),
          const Text('Acceso a tu música',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: OndaTheme.textPrimary)),
          const SizedBox(height: 12),
          const Text(
            'Onda necesita permiso para leer los archivos de audio '
            'de tu dispositivo. No accede a internet ni comparte nada.',
            style:
                TextStyle(color: OndaTheme.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onGrant,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Conceder permiso'),
          ),
        ]),
      ),
    );
  }
}
