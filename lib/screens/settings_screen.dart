import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/sleep_timer_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/player_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/localization_provider.dart';
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
        title: Text(ref.watch(l10nProvider).translate('general.settings')),
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
    final l10n = ref.watch(l10nProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Tarjeta de desarrollador y cumplimiento RGPD
          const _DeveloperGdprCard(),
          const SizedBox(height: 16),

          // Tarjeta 2: Personalización
          _buildCard(
            title: l10n.translate('settings_screen.customization_title'),
            icon: Icons.palette_outlined,
            settings: settings,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de Idioma
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Idioma / Language:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    DropdownButton<String>(
                      value: settings.languageCode,
                      dropdownColor: OndaTheme.card,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'system',
                          child: Text('Automático (Sistema)', style: TextStyle(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'es',
                          child: Text('Español', style: TextStyle(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English', style: TextStyle(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'fr',
                          child: Text('Français', style: TextStyle(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'it',
                          child: Text('Italiano', style: TextStyle(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'pt',
                          child: Text('Português', style: TextStyle(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'zh_Hans',
                          child: Text('中文 (简体)', style: TextStyle(color: OndaTheme.textPrimary)),
                        ),
                      ],
                      onChanged: (lang) {
                        if (lang != null) {
                          ref.read(settingsProvider.notifier).setLanguageCode(lang);
                        }
                      },
                    ),
                  ],
                ),
                const Divider(color: OndaTheme.divider, height: 24),
                // Tipografía
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.translate('settings_screen.typography'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    DropdownButton<String>(
                      value: settings.fontFamily,
                      dropdownColor: OndaTheme.card,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: 'Roboto',
                          child: Text('Roboto', style: GoogleFonts.roboto(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'Inter',
                          child: Text('Inter', style: GoogleFonts.inter(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'Montserrat',
                          child: Text('Montserrat', style: GoogleFonts.montserrat(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'Poppins',
                          child: Text('Poppins', style: GoogleFonts.poppins(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'Germania One',
                          child: Text('Germania One', style: GoogleFonts.germaniaOne(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'MedievalSharp',
                          child: Text('MedievalSharp', style: GoogleFonts.medievalSharp(color: OndaTheme.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'Cinzel',
                          child: Text('Cinzel', style: GoogleFonts.cinzel(color: OndaTheme.textPrimary)),
                        ),
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
                Text(l10n.translate('settings_screen.primary_color'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                          Text(l10n.translate('settings_screen.background_image'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(
                            settings.backgroundImagePath != null 
                                ? l10n.translate('settings_screen.background_active') 
                                : l10n.translate('settings_screen.background_default'),
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
                          label: Text(l10n.translate('settings_screen.choose'), style: const TextStyle(fontSize: 12)),
                          onPressed: () => _pickBackgroundImage(ref),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSleepTimerCard(ref, settings),
          SizedBox(height: ref.watch(playerProvider.select((s) => s.currentSong != null)) ? 110 : 40),
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

  Widget _buildSleepTimerCard(WidgetRef ref, SettingsState settings) {
    final sleepTimer = ref.watch(sleepTimerProvider);
    final l10n = ref.watch(l10nProvider);

    String formatDuration(Duration? duration) {
      if (duration == null) return '';
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      if (hours > 0) {
        return '$hours:$minutes:$seconds';
      } else {
        return '$minutes:$seconds';
      }
    }

    final presets = {
      '15 min': const Duration(minutes: 15),
      '30 min': const Duration(minutes: 30),
      '60 min': const Duration(minutes: 60),
      '2 h': const Duration(hours: 2),
      '3 h': const Duration(hours: 3),
    };

    return _buildCard(
      title: l10n.translate('settings_screen.sleep_timer_title'),
      icon: Icons.timer_outlined,
      settings: settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sleepTimer.isActive
                          ? '${l10n.translate('settings_screen.sleep_timer_active')} ${formatDuration(sleepTimer.remainingTime)}'
                          : l10n.translate('settings_screen.sleep_timer_inactive'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.translate('settings_screen.sleep_timer_sub'),
                      style: const TextStyle(fontSize: 11, color: OndaTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (sleepTimer.isActive)
                TextButton.icon(
                  onPressed: () {
                    ref.read(sleepTimerProvider.notifier).cancelTimer();
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                  label: Text(l10n.translate('general.cancel'), style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: presets.keys.map((name) {
                final duration = presets[name]!;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(name, style: const TextStyle(fontSize: 12)),
                    backgroundColor: OndaTheme.card,
                    labelStyle: TextStyle(
                      color: settings.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: OndaTheme.divider, width: 1),
                    ),
                    onPressed: () {
                      ref.read(sleepTimerProvider.notifier).setTimer(duration);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta del Desarrollador y Cumplimiento RGPD ──────────────────────────────

class _DeveloperGdprCard extends ConsumerWidget {
  const _DeveloperGdprCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final primaryColor = settings.primaryColor;
    final l10n = ref.watch(l10nProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.12),
            OndaTheme.card.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.15),
                  radius: 18,
                  child: Icon(Icons.security_rounded, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('settings_screen.developed_by'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.translate('settings_screen.gdpr_title'),
                        style: TextStyle(
                          fontSize: 11,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.translate('settings_screen.gdpr_summary'),
              style: const TextStyle(
                fontSize: 12,
                color: OndaTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const Divider(color: OndaTheme.divider, height: 24),
            _buildBullet(
              Icons.visibility_off_outlined,
              l10n.translate('settings_screen.gdpr_total_privacy_title'),
              l10n.translate('settings_screen.gdpr_total_privacy_desc'),
            ),
            const SizedBox(height: 8),
            _buildBullet(
              Icons.storage_rounded,
              l10n.translate('settings_screen.gdpr_local_data_title'),
              l10n.translate('settings_screen.gdpr_local_data_desc'),
            ),
            const SizedBox(height: 8),
            _buildBullet(
              Icons.gavel_rounded,
              l10n.translate('settings_screen.gdpr_responsible_title'),
              l10n.translate('settings_screen.gdpr_responsible_desc'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(IconData icon, String title, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: OndaTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: OndaTheme.textSecondary, height: 1.3),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: OndaTheme.textPrimary),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
