import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// Screen 3 — Lock screen with a content-based push notification.
/// The differentiator: Beedle relaunches the user with contextual reminders.
class Screen03LockScreen extends StatelessWidget {
  const Screen03LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.dusk),
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _LockBackdrop()),
            Column(
              children: <Widget>[
                _LockClock(),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: CalmSpace.s5,
                  ),
                  child: _PushNotification(),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LockBackdrop extends StatelessWidget {
  const _LockBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 1.1,
          colors: <Color>[
            AppColors.ember.withValues(alpha: 0.22),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _LockClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'mardi 17 avril',
          style: AppTypography.mono(const TextStyle()).copyWith(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '9:41',
          style: AppTypography.textTheme(
            primary: Colors.white,
            secondary: Colors.white,
          ).displayLarge?.copyWith(fontSize: 86, height: 1, letterSpacing: -4),
        ),
      ],
    );
  }
}

class _PushNotification extends StatelessWidget {
  const _PushNotification();

  @override
  Widget build(BuildContext context) {
    final TextTheme t = AppTypography.textTheme(
      primary: Colors.white,
      secondary: Colors.white.withValues(alpha: 0.75),
    );
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: CalmRadius.xl,
        cornerSmoothing: 0.55,
      ),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.ember,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                'b',
                style: AppTypography.digital(const TextStyle()).copyWith(
                  fontSize: 28,
                  color: AppColors.ink,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'BEEDLE',
                        style: AppTypography.mono(const TextStyle()).copyWith(
                          fontSize: 11,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      Text(
                        'maintenant',
                        style: AppTypography.mono(const TextStyle()).copyWith(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Cette astuce que tu as gardée lundi',
                    style: t.titleMedium?.copyWith(fontSize: 14.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "« Demande un plan avant d'agir » — 2 min à relire avant ta journée.",
                    style: t.bodySmall?.copyWith(fontSize: 13, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
