// This is a basic Flutter widget test for OndaApp.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reproductor/app.dart';

void main() {
  testWidgets('OndaApp loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: OndaApp()));

    // Verify that the app root widget exists.
    expect(find.byType(OndaApp), findsOneWidget);
  });
}

