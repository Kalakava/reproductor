import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/settings_provider.dart';
import '../providers/player_provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Ajustes'),
        centerTitle: false,
      ),
      body: Container(
        decoration: settings.backgroundImagePath != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(settings.backgroundImagePath!)),
                  fit: BoxFit.cover,
                ),
              )
            : BackgroundThemeHelper.getDecoration(BackgroundThemeType.royalPurple), // Fondo por defecto
        child: Container(
          color: settings.backgroundImagePath != null ? Colors.black.withOpacity(0.65) : Colors.transparent,
          child: settings.backgroundImagePath != null
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: _buildBody(context, ref, settings),
                )
              : _buildBody(context, ref, settings),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, SettingsState settings) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Banner de publicidad / anuncios remotos
          const _RemoteBanner(),
          const SizedBox(height: 16),

          // Tarjeta 1: Ecualizador
          _buildCard(
            title: 'Ecualizador de Audio',
            icon: Icons.equalizer_rounded,
            settings: settings,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activar Ecualizador', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Ajusta frecuencias nativas en Android', style: TextStyle(fontSize: 12, color: OndaTheme.textSecondary)),
                  value: settings.eqEnabled,
                  onChanged: (val) => ref.read(settingsProvider.notifier).setEqEnabled(val),
                ),
                if (settings.eqEnabled) ...[
                  const Divider(color: OndaTheme.divider, height: 24),
                  const Text('Presets por Estilo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: OndaTheme.textSecondary)),
                  const SizedBox(height: 10),
                  _buildEqualizerPresets(ref, settings),
                  const SizedBox(height: 16),
                  _buildSlider(
                    label: 'Bajos (Bass)',
                    value: settings.eqBass,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).setEqValues(val, settings.eqMid, settings.eqTreble);
                    },
                  ),
                  _buildSlider(
                    label: 'Medios (Mids)',
                    value: settings.eqMid,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).setEqValues(settings.eqBass, val, settings.eqTreble);
                    },
                  ),
                  _buildSlider(
                    label: 'Agudos (Treble)',
                    value: settings.eqTreble,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).setEqValues(settings.eqBass, settings.eqMid, val);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tarjeta 2: Personalización
          _buildCard(
            title: 'Personalización de Interfaz',
            icon: Icons.palette_outlined,
            settings: settings,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipografía
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tipografía:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    DropdownButton<String>(
                      value: settings.fontFamily,
                      dropdownColor: OndaTheme.card,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                        DropdownMenuItem(value: 'Inter', child: Text('Inter')),
                        DropdownMenuItem(value: 'Montserrat', child: Text('Montserrat')),
                        DropdownMenuItem(value: 'Poppins', child: Text('Poppins')),
                      ],
                      onChanged: (font) {
                        if (font != null) {
                          ref.read(settingsProvider.notifier).setFontFamily(font);
                        }
                      },
                    ),
                  ],
                ),
                const Divider(color: OndaTheme.divider, height: 24),
                // Color Primario
                const Text('Color Principal:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildColorChooser(ref, settings),
                const Divider(color: OndaTheme.divider, height: 24),
                // Fondo personalizado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Imagen de Fondo:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(
                            settings.backgroundImagePath != null ? 'Imagen personalizada activa' : 'Usando fondo por defecto',
                            style: const TextStyle(fontSize: 11, color: OndaTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (settings.backgroundImagePath != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => ref.read(settingsProvider.notifier).setBackgroundImagePath(null),
                          ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: settings.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.image_search_rounded, size: 16),
                          label: const Text('Elegir', style: TextStyle(fontSize: 12)),
                          onPressed: () => _pickBackgroundImage(ref),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required SettingsState settings,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OndaTheme.card.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: OndaTheme.divider.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: settings.primaryColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
          const Divider(color: OndaTheme.divider, height: 28),
          child,
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: OndaTheme.textSecondary)),
              Text('${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)} dB',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: value,
            min: -10.0,
            max: 10.0,
            divisions: 20,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildEqualizerPresets(WidgetRef ref, SettingsState settings) {
    final presets = {
      'Plano': [0.0, 0.0, 0.0],
      'Rap': [6.0, 1.0, -1.0],
      'Rock': [4.0, -2.0, 5.0],
      'Metal': [5.0, -4.0, 4.0],
      'Indie': [2.0, 3.0, 1.0],
      'Pop': [3.0, 2.0, 2.0],
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: presets.keys.map((name) {
          final values = presets[name]!;
          final isSelected = settings.eqBass == values[0] &&
              settings.eqMid == values[1] &&
              settings.eqTreble == values[2];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(name, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              selectedColor: settings.primaryColor.withOpacity(0.3),
              backgroundColor: OndaTheme.card,
              labelStyle: TextStyle(
                color: isSelected ? settings.primaryColor : OndaTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? settings.primaryColor : OndaTheme.divider,
                  width: 1,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  ref.read(settingsProvider.notifier).setEqValues(values[0], values[1], values[2]);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorChooser(WidgetRef ref, SettingsState settings) {
    final colors = [
      const Color(0xFF8B5CF6), // Morado Neón
      const Color(0xFFEC4899), // Rosa Neón
      const Color(0xFF06B6D4), // Cian / Océano
      const Color(0xFFF59E0B), // Ámbar / Oro
      const Color(0xFF10B981), // Esmeralda
      const Color(0xFFEF4444), // Coral / Rojo
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: colors.map((color) {
        final isSelected = settings.primaryColorValue == color.value;
        return GestureDetector(
          onTap: () => ref.read(settingsProvider.notifier).setPrimaryColor(color),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickBackgroundImage(WidgetRef ref) async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await ref.read(settingsProvider.notifier).setBackgroundImagePath(image.path);
      }
    } catch (_) {}
  }
}

// ─── Banner Remoto / Push publicitario del desarrollador ───────────────────────

class _RemoteBanner extends StatefulWidget {
  const _RemoteBanner();

  @override
  State<_RemoteBanner> createState() => _RemoteBannerState();
}

class _RemoteBannerState extends State<_RemoteBanner> {
  bool _isLoading = true;
  Map<String, dynamic>? _bannerData;

  @override
  void initState() {
    super.initState();
    _fetchBanner();
  }

  Future<void> _fetchBanner() async {
    // Configuración por defecto local
    final fallback = {
      'show_banner': true,
      'title': 'Desarrollado por Damián Arenas',
      'message': 'Onda es un reproductor de música local moderno, libre de anuncios y de código abierto. ¡Gracias por usar la aplicación!',
      'action_text': 'Ver en GitHub',
      'action_url': 'https://github.com/Kalakava/reproductor',
    };

    try {
      final client = HttpClient();
      // Petición al repositorio de GitHub
      final request = await client.getUrl(Uri.parse(
        'https://raw.githubusercontent.com/Kalakava/reproductor/main/banner.json',
      )).timeout(const Duration(seconds: 3));

      final response = await request.close();
      if (response.statusCode == 200) {
        final content = await response.transform(utf8.decoder).join();
        final decoded = jsonDecode(content) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _bannerData = decoded;
            _isLoading = false;
          });
        }
      } else {
        throw Exception();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _bannerData = fallback;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      await OpenFilex.open(url);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final data = _bannerData;
    if (data == null || data['show_banner'] != true) {
      return const SizedBox.shrink();
    }

    final String title = data['title'] ?? 'Novedades de Onda';
    final String message = data['message'] ?? '';
    final String? imageUrl = data['image_url'];
    final String? actionText = data['action_text'];
    final String? actionUrl = data['action_url'];
    final String? streamAudioUrl = data['stream_audio_url'];

    return Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(settingsProvider);
        final isPlayingBannerSong = ref.watch(playerProvider.select((s) => s.currentSong?.id == 999999));
        final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                settings.primaryColor.withOpacity(0.2),
                OndaTheme.card.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: settings.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: settings.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: OndaTheme.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (actionUrl != null && actionUrl.isNotEmpty && actionText != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: settings.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () => _launchUrl(actionUrl),
                            child: Text(actionText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        if (actionUrl != null && actionUrl.isNotEmpty && actionText != null && streamAudioUrl != null)
                          const SizedBox(width: 12),
                        if (streamAudioUrl != null && streamAudioUrl.isNotEmpty)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: settings.primaryColor,
                              side: BorderSide(color: settings.primaryColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: Icon(
                              isPlayingBannerSong && isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 16,
                            ),
                            label: Text(
                              isPlayingBannerSong && isPlaying ? 'Pausar tema' : 'Escuchar tema',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              if (isPlayingBannerSong) {
                                if (isPlaying) {
                                  ref.read(playerProvider.notifier).pause();
                                } else {
                                  ref.read(playerProvider.notifier).resume();
                                }
                              } else {
                                final song = SongModel({
                                  '_id': 999999,
                                  '_data': streamAudioUrl,
                                  'title': data['audio_title'] ?? 'Tema Inédito',
                                  'artist': data['audio_artist'] ?? 'Damián Arenas',
                                  'album': 'Streaming',
                                  'duration': 180000,
                                  'uri': streamAudioUrl,
                                });
                                ref.read(playerProvider.notifier).play([song], 0);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
