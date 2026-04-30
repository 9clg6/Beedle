import 'package:beedle/tool/store_screenshots/screens/screen_01_before_after.dart';
import 'package:beedle/tool/store_screenshots/screens/screen_02_fiche.dart';
import 'package:beedle/tool/store_screenshots/screens/screen_03_lockscreen.dart';
import 'package:beedle/tool/store_screenshots/screens/screen_04_sharesheet.dart';
import 'package:beedle/tool/store_screenshots/screens/screen_05_home.dart';
import 'package:beedle/tool/store_screenshots/screens/screen_06_search.dart';
import 'package:beedle/tool/store_screenshots/screens/screen_07_actions.dart';
import 'package:beedle/tool/store_screenshots/screens/screen_08_fusion.dart';
import 'package:beedle/tool/store_screenshots/screens/screen_09_social.dart';
import 'package:flutter/material.dart';

class ScreenshotGallery extends StatelessWidget {
  const ScreenshotGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: const BouncingScrollPhysics(),
      children: const <Widget>[
        _Page(child: Screen01BeforeAfter()),
        _Page(child: Screen02Fiche()),
        _Page(child: Screen03LockScreen()),
        _Page(child: Screen04ShareSheet()),
        _Page(child: Screen05Home()),
        _Page(child: Screen06Search()),
        _Page(child: Screen07Actions()),
        _Page(child: Screen08Fusion()),
        _Page(child: Screen09Social()),
      ],
    );
  }
}

/// Wraps a screen with a transparent [Material] so Flutter can resolve the
/// default text style (avoids the yellow-underline debug signal).
class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: child,
    );
  }
}
