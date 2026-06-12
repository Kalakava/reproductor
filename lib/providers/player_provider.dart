import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../services/audio_handler.dart';

// ─── Provider del handler (se sobreescribe en main si AudioService está OK) ───

final audioHandlerProvider = Provider<OndaAudioHandler?>((ref) => null);

// ─── Estado ───────────────────────────────────────────────────────────────────

class PlayerStateModel {
  final SongModel? currentSong;
  final List<SongModel> queue;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final LoopMode loopMode;
  final bool shuffle;
  final bool isLoading;

  const PlayerStateModel({
    this.currentSong,
    this.queue = const [],
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.loopMode = LoopMode.off,
    this.shuffle = false,
    this.isLoading = false,
  });

  PlayerStateModel copyWith({
    SongModel? currentSong,
    List<SongModel>? queue,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    LoopMode? loopMode,
    bool? shuffle,
    bool? isLoading,
  }) =>
      PlayerStateModel(
        currentSong: currentSong ?? this.currentSong,
        queue: queue ?? this.queue,
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        loopMode: loopMode ?? this.loopMode,
        shuffle: shuffle ?? this.shuffle,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class PlayerNotifier extends StateNotifier<PlayerStateModel> {
  final OndaAudioHandler? _handler;

  // Usa el AudioPlayer del handler si existe; si no, crea uno propio.
  late final AudioPlayer _player;

  PlayerNotifier(this._handler) : super(const PlayerStateModel()) {
    _player = _handler?.player ?? AudioPlayer();
    _initStreams();
  }

  void _initStreams() {
    _player.currentIndexStream.listen((index) {
      if (index != null && index < state.queue.length) {
        state = state.copyWith(currentSong: state.queue[index]);
      }
    });
    _player.playingStream.listen((v) => state = state.copyWith(isPlaying: v));
    _player.positionStream.listen((v) => state = state.copyWith(position: v));
    _player.durationStream
        .listen((v) => state = state.copyWith(duration: v ?? Duration.zero));
    _player.loopModeStream.listen((v) => state = state.copyWith(loopMode: v));
    _player.shuffleModeEnabledStream
        .listen((v) => state = state.copyWith(shuffle: v));
  }

  Future<void> playFromQueue(List<SongModel> songs,
      {int initialIndex = 0}) async {
    if (songs.isEmpty) return;
    state = state.copyWith(queue: songs, isLoading: true);
    try {
      if (_handler != null) {
        // Con audio_service: metadata en notificación + pantalla de bloqueo
        await _handler!.setQueue(songs, initialIndex: initialIndex);
        await _handler!.play();
      } else {
        // Sin audio_service: solo reproducción local
        final sources = songs
            .map((s) => AudioSource.uri(
                  s.uri != null ? Uri.parse(s.uri!) : Uri.file(s.data ?? ''),
                ))
            .toList();
        await _player.setAudioSource(
          ConcatenatingAudioSource(children: sources),
          initialIndex: initialIndex.clamp(0, songs.length - 1),
        );
        await _player.play();
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> play(List<SongModel> songs, int initialIndex) async {
    await playFromQueue(songs, initialIndex: initialIndex);
  }

  Future<void> pause() async {
    _handler != null ? await _handler!.pause() : await _player.pause();
  }

  Future<void> resume() async {
    _handler != null ? await _handler!.play() : await _player.play();
  }

  Future<void> togglePlay() async {
    if (_handler != null) {
      _player.playing ? await _handler!.pause() : await _handler!.play();
    } else {
      _player.playing ? await _player.pause() : await _player.play();
    }
  }

  Future<void> next() async {
    _handler != null ? await _handler!.skipToNext() : await _player.seekToNext();
  }

  Future<void> previous() async {
    _handler != null
        ? await _handler!.skipToPrevious()
        : await _player.seekToPrevious();
  }

  Future<void> seekTo(Duration pos) async {
    _handler != null ? await _handler!.seek(pos) : await _player.seek(pos);
  }

  Future<void> cycleLoopMode() async {
    final next = switch (state.loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await _player.setLoopMode(next);
  }

  Future<void> toggleShuffle() async {
    final enable = !state.shuffle;
    if (enable) await _player.shuffle();
    await _player.setShuffleModeEnabled(enable);
  }

  @override
  void dispose() {
    if (_handler == null) _player.dispose();
    super.dispose();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerStateModel>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return PlayerNotifier(handler);
});
