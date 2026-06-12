import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';

class OndaApp extends ConsumerWidget {
  const OndaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Onda',
      debugShowCheckedModeBanner: false,
      theme: OndaTheme.dark(
        primaryColor: settings.primaryColor,
        fontFamily: settings.fontFamily,
      ),
      home: const HomeScreen(),
    );
  }
}
