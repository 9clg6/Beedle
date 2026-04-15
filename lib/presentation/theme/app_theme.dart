import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Thèmes Beedle — CalmSurface Warm (light prioritaire, dark secondaire).
abstract final class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.ink, // flat ink pour CTA in-app (anti-gradient)
      onPrimary: AppColors.canvas,
      secondary: AppColors.ember,
      onSecondary: AppColors.canvas,
      tertiary: AppColors.mint,
      onTertiary: AppColors.ink,
      error: AppColors.danger,
      onError: AppColors.canvas,
      surface: AppColors.glassStrong,
      onSurface: AppColors.neutral8,
      onSurfaceVariant: AppColors.neutral6,
      surfaceContainer: AppColors.glassMedium,
      surfaceContainerLow: AppColors.glassSoft,
      surfaceContainerHighest: AppColors.glassStrong,
      outline: AppColors.neutral3,
      outlineVariant: AppColors.glassBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      textTheme: AppTypography.textTheme(
        primary: AppColors.neutral8,
        secondary: AppColors.neutral6,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.neutral8,
        iconTheme: const IconThemeData(color: AppColors.neutral8, size: 22),
        actionsIconTheme:
            const IconThemeData(color: AppColors.neutral8, size: 22),
        titleTextStyle: AppTypography.textTheme(
          primary: AppColors.neutral8,
          secondary: AppColors.neutral6,
        ).titleLarge,
      ),
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: CupertinoSlidingTransitionBuilder(),
          TargetPlatform.android: CupertinoSlidingTransitionBuilder(),
        },
      ),
    );
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.inkDark,
      onPrimary: AppColors.canvasDark,
      secondary: AppColors.ember,
      onSecondary: AppColors.canvasDark,
      tertiary: AppColors.mint,
      onTertiary: AppColors.canvasDark,
      error: AppColors.danger,
      onError: AppColors.canvasDark,
      surface: AppColors.glassDarkStrong,
      onSurface: AppColors.neutral8Dark,
      onSurfaceVariant: AppColors.neutral6Dark,
      surfaceContainer: AppColors.glassDarkMedium,
      surfaceContainerLow: AppColors.glassDarkSoft,
      surfaceContainerHighest: AppColors.glassDarkStrong,
      outline: AppColors.neutral3Dark,
      outlineVariant: AppColors.glassDarkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      textTheme: AppTypography.textTheme(
        primary: AppColors.neutral8Dark,
        secondary: AppColors.neutral6Dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.neutral8Dark,
        iconTheme: const IconThemeData(color: AppColors.neutral8Dark, size: 22),
        actionsIconTheme:
            const IconThemeData(color: AppColors.neutral8Dark, size: 22),
        titleTextStyle: AppTypography.textTheme(
          primary: AppColors.neutral8Dark,
          secondary: AppColors.neutral6Dark,
        ).titleLarge,
      ),
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: CupertinoSlidingTransitionBuilder(),
          TargetPlatform.android: CupertinoSlidingTransitionBuilder(),
        },
      ),
    );
  }
}

/// Transition slide cupertino-like pour Android aussi.
class CupertinoSlidingTransitionBuilder extends PageTransitionsBuilder {
  const CupertinoSlidingTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = Tween<Offset>(
      begin: const Offset(0.25, 0),
      end: Offset.zero,
    );
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return SlideTransition(
      position: tween.animate(curved),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
