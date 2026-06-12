import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LibraryService {
  static final OnAudioQuery _query = OnAudioQuery();
  static const _channel = MethodChannel('io.onda.reproductor/file_manager');

  static Future<bool> openFolder(String path) async {
    if (!Platform.isAndroid) return false;
    try {
      final bool success =
          await _channel.invokeMethod('openFolder', {'path': path});
      return success;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestPermission() => _query.permissionsRequest();
  static Future<bool> checkPermission() => _query.permissionsStatus();

  static Future<List<SongModel>> getAllSongs() => _query.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

  /// Realiza un barrido manual en las carpetas comunes buscando archivos de audio
  /// y registrándolos en el MediaStore de Android para forzar su detección.
  static Future<void> scanForNewFiles() async {
    if (!Platform.isAndroid) return;

    final pathsToScan = [
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Audio',
    ];

    for (final path in pathsToScan) {
      try {
        final dir = Directory(path);
        if (await dir.exists()) {
          final entities = dir.listSync(recursive: true, followLinks: false);
          for (final entity in entities) {
            if (entity is File) {
              final ext = entity.path.split('.').last.toLowerCase();
              if (const ['mp3', 'm4a', 'wav', 'ogg', 'flac', 'opus', 'aac'].contains(ext)) {
                await _query.scanMedia(entity.path);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[Onda] Error al escanear ruta de búsqueda $path: $e');
      }
    }
  }

  // Borra el archivo directamente. En Android 11+ puede requerir
  // permiso adicional; si falla devuelve false y el UI lo indica.
  static Future<bool> deleteSong(BuildContext context, SongModel song) async {
    try {
      final file = File(song.data);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

