import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';

class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    try {
      await OpenFilex.open(url);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgTheme = ref.watch(backgroundThemeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Acerca de'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BackgroundThemeHelper.getDecoration(bgTheme),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // Logotipo de la app
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: OndaTheme.primary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(
                        'assets/icon/onda_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nombre y Versión
                  const Text(
                    'Onda',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: OndaTheme.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    'Versión 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: OndaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Tarjeta del Desarrollador
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: OndaTheme.card.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: OndaTheme.divider.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'DESARROLLADO POR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: OndaTheme.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Damián Arenas',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: OndaTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Onda es un proyecto de reproductor de música local moderno, rápido y libre de anuncios. Diseñado para ofrecer una experiencia musical fluida y premium respetando tu privacidad.',
                          style: TextStyle(
                            fontSize: 13,
                            color: OndaTheme.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botones de Enlace / Redes
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: OndaTheme.card.withOpacity(0.5),
                    leading: const Icon(Icons.code_rounded, color: OndaTheme.primary),
                    title: const Text('Código fuente en GitHub'),
                    trailing: const Icon(Icons.chevron_right_rounded, color: OndaTheme.textSecondary),
                    onTap: () => _launchUrl('https://github.com/Kalakava/reproductor'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: OndaTheme.card.withOpacity(0.5),
                    leading: const Icon(Icons.mail_outline_rounded, color: OndaTheme.primary),
                    title: const Text('Contactar por correo'),
                    trailing: const Icon(Icons.chevron_right_rounded, color: OndaTheme.textSecondary),
                    onTap: () => _launchUrl('mailto:kakalavacalexera@gmail.com'),
                  ),
                  const SizedBox(height: 40),
                  // Pie de página
                  Text(
                    '© 2026 Damián Arenas. Todos los derechos reservados.',
                    style: TextStyle(
                      fontSize: 10,
                      color: OndaTheme.textSecondary.withOpacity(0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
