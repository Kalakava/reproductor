import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handler que envuelve [AudioPlayer] y expone los controles de medios
/// al sistema Android (notificación, pantalla de bloqueo, Bluetooth).
class OndaAudioHandler extends BaseAudioHandler with SeekHandler {
  late final AudioPlayer _player;
  AndroidEqualizer? _equalizer;
  List<AndroidEqualizerBand>? _cachedBands;
  bool _isInitializingBands = false;
  bool? _lastEqEnabled;

  OndaAudioHandler({bool enableEqPipeline = false}) {
    if (enableEqPipeline) {
      _equalizer = AndroidEqualizer();
    }
    _player = AudioPlayer(
      audioPipeline: AudioPipeline(
        androidAudioEffects: [
          if (_equalizer != null) _equalizer!,
        ],
      ),
    );

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

  Future<void> _ensureBandsInitialized() async {
    if (_cachedBands != null || _equalizer == null || _isInitializingBands) return;
    _isInitializingBands = true;
    try {
      final params = await _equalizer!.parameters;
      _cachedBands = params.bands;
      debugPrint('[Onda] Bandas del ecualizador cargadas con éxito: ${_cachedBands?.length}');
    } catch (e) {
      debugPrint('[Onda] Error al inicializar bandas del ecualizador: $e');
    } finally {
      _isInitializingBands = false;
    }
  }

  /// Actualiza las ganancias del ecualizador nativo
  Future<void> updateEqualizer(bool enabled, double bass, double mid, double treble) async {
    if (_equalizer == null) return;
    try {
      if (_lastEqEnabled != enabled) {
        await _equalizer!.setEnabled(enabled);
        _lastEqEnabled = enabled;
        debugPrint('[Onda] Ecualizador ${enabled ? "activado" : "desactivado"}');
      }
      if (enabled) {
        await _ensureBandsInitialized();
        final bands = _cachedBands;
        if (bands != null && bands.isNotEmpty) {
          // Aplicar ganancias de forma asíncrona sin bloquear el event loop
          if (bands.isNotEmpty) bands[0].setGain(bass);
          if (bands.length > 1) bands[1].setGain(bass * 0.7);
          if (bands.length > 2) bands[2].setGain(mid);
          if (bands.length > 3) bands[3].setGain(treble * 0.7);
          if (bands.length > 4) bands[4].setGain(treble);
          debugPrint('[Onda] Ganancias aplicadas -> Bass: $bass dB, Mid: $mid dB, Treble: $treble dB');
        }
      }
    } catch (e) {
      debugPrint('[Onda] Error al actualizar ecualizador: $e');
    }
  }

  /// Carga y aplica los ajustes del ecualizador guardados en SharedPreferences
  Future<void> applySavedEqualizerSettings() async {
    if (_equalizer == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('onda_eq_enabled') ?? false;
      final bass = prefs.getDouble('onda_eq_bass') ?? 0.0;
      final mid = prefs.getDouble('onda_eq_mid') ?? 0.0;
      final treble = prefs.getDouble('onda_eq_treble') ?? 0.0;
      
      await updateEqualizer(enabled, bass, mid, treble);
    } catch (e) {
      debugPrint('[Onda] Error al aplicar ajustes guardados del ecualizador: $e');
    }
  }

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

    // Aplicar el ecualizador una vez que la sesión de audio está activa
    await applySavedEqualizerSettings();
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
