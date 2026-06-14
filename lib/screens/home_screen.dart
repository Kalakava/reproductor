import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/localization_provider.dart';
import '../widgets/mini_player.dart';
import 'songs_screen.dart';
import 'playlists_screen.dart';
import 'settings_screen.dart';

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
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final hasCurrentSong =
        ref.watch(playerProvider.select((s) => s.currentSong != null));
    final settings = ref.watch(settingsProvider);
    final l10n = ref.watch(l10nProvider);

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
        onDestinationSelected: (i) {
          setState(() => _tab = i);
          if (i == 2) {
            ref.read(settingsProvider.notifier).markSettingsVisited();
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.library_music_outlined),
            selectedIcon: const Icon(Icons.library_music),
            label: l10n.translate('general.songs'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.queue_music_outlined),
            selectedIcon: const Icon(Icons.queue_music),
            label: l10n.translate('general.playlists'),
          ),
          NavigationDestination(
            icon: _PulsingSettingsIcon(
              showGlow: settings.showSettingsGlow,
              isSelected: _tab == 2,
              glowColor: settings.primaryColor,
            ),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.translate('general.settings'),
          ),
        ],
      ),
    );
  }
}

class _PulsingSettingsIcon extends StatefulWidget {
  final bool showGlow;
  final bool isSelected;
  final Color glowColor;
  const _PulsingSettingsIcon({
    required this.showGlow,
    required this.isSelected,
    required this.glowColor,
  });

  @override
  State<_PulsingSettingsIcon> createState() => _PulsingSettingsIconState();
}

class _PulsingSettingsIconState extends State<_PulsingSettingsIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.showGlow) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingSettingsIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showGlow && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.showGlow && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IconData iconData = widget.isSelected ? Icons.settings : Icons.settings_outlined;

    if (!widget.showGlow) {
      return Icon(iconData);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.15);
        final opacity = 0.8 - (_controller.value * 0.6);
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor.withOpacity(opacity),
                    blurRadius: 8 * scale,
                    spreadRadius: 3 * scale,
                  ),
                ],
              ),
            ),
            Icon(iconData),
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.glowColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
