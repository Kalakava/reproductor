import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'providers/player_provider.dart';
import 'services/audio_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializar audio_service para controles en notificación y pantalla bloqueada.
  // Si falla (dispositivo incompatible), la app sigue funcionando sin notificación.
  OndaAudioHandler? handler;
  try {
    handler = await AudioService.init(
      builder: () => OndaAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'io.onda.music.audio',
        androidNotificationChannelName: 'Onda',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  } catch (e) {
    debugPrint('[Onda] AudioService no disponible: $e');
  }

  runApp(ProviderScope(
    overrides: [
      if (handler != null)
        audioHandlerProvider.overrideWithValue(handler),
    ],
    child: const OndaApp(),
  ));
}
