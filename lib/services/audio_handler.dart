import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Handler que envuelve [AudioPlayer] y expone los controles de medios
/// al sistema Android (notificación, pantalla de bloqueo, Bluetooth).
class OndaAudioHandler extends BaseAudioHandler with SeekHandler {
  late final AudioPlayer _player;

  OndaAudioHandler() {
    _player = AudioPlayer();

    // Reenviar estado de reproducción al sistema
    _player.playbackEventStream.map(_buildPlaybackState).pipe(playbackState);

    // Actualizar el MediaItem activo cuando cambia la canción
    _player.currentIndexStream.listen((index) {
      if (index != null && index < queue.value.length) {
        mediaItem.add(queue.value[index]);
      }
    });
  }

  /// Acceso al [AudioPlayer] subyacente para los listeners de la UI.
  AudioPlayer get player => _player;



  // ── Cargar cola ────────────────────────────────────────────────────────────

  Future<void> setQueue(List<SongModel> songs, {int initialIndex = 0}) async {
    final sources = songs
        .map((s) => AudioSource.uri(
              s.uri != null ? Uri.parse(s.uri!) : Uri.file(s.data),
            ))
        .toList();

    // Metadata para la notificación y pantalla de bloqueo
    queue.add(songs
        .map((s) => MediaItem(
              id: s.id.toString(),
              title: s.title,
              artist: s.artist ?? 'Desconocido',
              album: s.album ?? '',
              artUri: s.albumId != null
                  ? Uri.parse(
                      'content://media/external/audio/albumart/${s.albumId}')
                  : null,
            ))
        .toList());

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: initialIndex.clamp(0, songs.length - 1),
    );
  }

  // ── Controles estándar ─────────────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  // ── Estado interno → PlaybackState ────────────────────────────────────────

  PlaybackState _buildPlaybackState(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState] ??
          AudioProcessingState.idle,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
