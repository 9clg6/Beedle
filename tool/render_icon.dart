// ignore_for_file: avoid_print
//
// tool/render_icon.dart — Export app icon variants as PNG master files.
//
// Renders the `BeedleIconAsset` widget at 1024×1024 into PNG files that
// serve as source of truth for `flutter_launcher_icons`. Run this script
// whenever the icon design changes in `beedle_icon_asset.dart`.
//
// Usage:
//   flutter test tool/render_icon.dart
//
// Output:
//   assets/branding/icon-source-1024.png                — light variant (main)
//   assets/branding/icon-dot-b-dark-1024.png            — dark variant
//   assets/branding/icon-adaptive-foreground-1024.png   — Android adaptive fg
//   assets/branding/icon-notification-monochrome-1024.png — Android themed
//
// After running this, generate the actual launcher icons:
//   dart run flutter_launcher_icons
//
// Why a test runner rather than a standalone `dart run`? Because rendering
// a Flutter widget to pixels requires the Flutter binding + an offscreen
// surface, which the `flutter_test` harness provides for free.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:beedle/presentation/widgets/beedle_icon_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Each entry = one PNG to export. All rendered at 1024×1024 logical
  // pixels, device pixel ratio 1.0 (so output is exactly 1024×1024 image
  // pixels — what the stores want).
  const List<_Export> exports = <_Export>[
    _Export(
      outputPath: 'assets/branding/icon-source-1024.png',
      widget: BeedleIconAsset(
        size: 1024,
        elevated: false,
      ),
    ),
    _Export(
      outputPath: 'assets/branding/icon-dot-b-dark-1024.png',
      widget: BeedleIconAsset(
        size: 1024,
        variant: BeedleIconVariant.dark,
        elevated: false,
      ),
    ),
    // Adaptive foreground: the 'b' + dot floating on transparency.
    // Android's adaptive icon system composites this over the solid
    // `adaptive_icon_background` color from pubspec.
    _Export(
      outputPath: 'assets/branding/icon-adaptive-foreground-1024.png',
      widget: _WithTransparentBackground(
        child: BeedleIconAsset(
          size: 1024,
          variant: BeedleIconVariant.monochrome,
          monochromeColor: Color(0xFF0A0A0A),
          elevated: false,
        ),
      ),
    ),
    _Export(
      outputPath: 'assets/branding/icon-notification-monochrome-1024.png',
      widget: _WithTransparentBackground(
        child: BeedleIconAsset(
          size: 1024,
          variant: BeedleIconVariant.monochrome,
          monochromeColor: Colors.white,
          elevated: false,
        ),
      ),
    ),
  ];

  testWidgets('render icon PNGs', (WidgetTester tester) async {
    for (final _Export export in exports) {
      await _renderAndSave(tester, export);
    }
  });
}

class _Export {
  const _Export({required this.outputPath, required this.widget});
  final String outputPath;
  final Widget widget;
}

/// Pumps the widget at 1024×1024 and writes the resulting image to disk.
Future<void> _renderAndSave(WidgetTester tester, _Export export) async {
  final GlobalKey key = GlobalKey();

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1024, 1024)),
        child: Center(
          child: RepaintBoundary(
            key: key,
            child: SizedBox.square(
              dimension: 1024,
              child: export.widget,
            ),
          ),
        ),
      ),
    ),
  );

  // Give GoogleFonts + figma_squircle a frame to settle.
  await tester.pumpAndSettle();

  final RenderRepaintBoundary boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage();
  final ByteData? bytes = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  if (bytes == null) {
    throw StateError('Failed to encode PNG for ${export.outputPath}');
  }

  final File file = File(export.outputPath);
  await file.create(recursive: true);
  await file.writeAsBytes(bytes.buffer.asUint8List());
  print('✓ Wrote ${export.outputPath} (${image.width}×${image.height})');
}

/// Wraps a widget so it paints on a fully transparent background. Used
/// for the adaptive foreground + monochrome silhouette, both of which
/// require an alpha-channel PNG.
class _WithTransparentBackground extends StatelessWidget {
  const _WithTransparentBackground({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: const Color(0x00000000), child: child);
  }
}
