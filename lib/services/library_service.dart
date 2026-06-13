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

  // Borra el archivo del dispositivo utilizando la API nativa de Android (MediaStore)
  static Future<bool> deleteSong(BuildContext context, SongModel song) async {
    if (!Platform.isAndroid) return false;
    try {
      final bool success = await _channel.invokeMethod('deleteSong', {'path': song.data});
      if (success) {
        // Forzar escaneo para que el MediaStore refleje el cambio de inmediato
        await _query.scanMedia(song.data);
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  // Renombra físicamente el archivo y su título en el MediaStore de Android
  static Future<bool> renameSong(SongModel song, String newTitle, String newFileName) async {
    if (!Platform.isAndroid) return false;
    try {
      final bool success = await _channel.invokeMethod('renameSong', {
        'path': song.data,
        'newTitle': newTitle,
        'newFileName': newFileName,
      });
      if (success) {
        // Escanear la ruta vieja y la nueva para forzar la actualización del MediaStore
        final parentDir = File(song.data).parent.path;
        final newPath = '$parentDir/$newFileName';
        await _query.scanMedia(song.data);
        await _query.scanMedia(newPath);
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  // Comprime a WebP y escala a 200x200 una carátula personalizada seleccionada de la galería
  static Future<String?> compressArtwork(String sourcePath, String songId) async {
    if (!Platform.isAndroid) return null;
    try {
      final String? path = await _channel.invokeMethod('compressCoverImage', {
        'sourcePath': sourcePath,
        'songId': songId,
      });
      return path;
    } catch (_) {
      return null;
    }
  }

  // Abre una URL externa (web o mailto) en el navegador del dispositivo nativamente
  static Future<bool> openUrl(String url) async {
    if (!Platform.isAndroid) return false;
    try {
      final bool success = await _channel.invokeMethod('openUrl', {'url': url});
      return success;
    } catch (_) {
      return false;
    }
  }
}

