/// Standalone entry point to render store screenshots on the iOS simulator.
///
/// Run with:
///   flutter run -t lib/tool/store_screenshots/main.dart -d "iPhone 15 Pro Max"
///
/// Then swipe horizontally to navigate between the 9 screens and capture each
/// one with Cmd+S (Simulator › File › Save Screen).
library;

import 'package:beedle/presentation/theme/app_theme.dart';
import 'package:beedle/tool/store_screenshots/gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Hide the real iOS/Android status bar so the fake MockStatusBar (9:41,
  // full wifi, full battery) is the only one visible on screenshots.
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: <SystemUiOverlay>[],
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const _ScreenshotApp());
}

class _ScreenshotApp extends StatelessWidget {
  const _ScreenshotApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beedle — Store Screenshots',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const ScreenshotGallery(),
    );
  }
}
