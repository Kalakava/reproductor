import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../widgets/mini_player.dart';
import 'songs_screen.dart';
import 'playlists_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  static const _screens = [
    SongsScreen(),
    PlaylistsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final hasCurrentSong =
        ref.watch(playerProvider.select((s) => s.currentSong != null));

    return Scaffold(
      // El cuerpo usa Stack para que el mini-reproductor flote encima del contenido
      body: Stack(
        children: [
          IndexedStack(index: _tab, children: _screens),
          if (hasCurrentSong)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: const MiniPlayer(),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Canciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.queue_music_outlined),
            selectedIcon: Icon(Icons.queue_music),
            label: 'Listas',
          ),
        ],
      ),
    );
  }
}
