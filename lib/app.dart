import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

class OndaApp extends ConsumerWidget {
  const OndaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Onda',
      debugShowCheckedModeBanner: false,
      theme: OndaTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
