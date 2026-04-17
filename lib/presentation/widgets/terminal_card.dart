import 'dart:ui';

import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// CalmSurface Terminal Card — surface signature "Beedle's Voice".
///
/// Monospace dark-inverse sur fond Aurora warm, message courant en typing
/// animation + historique fade-up. Read-only strict (pas d'input user).
/// Tap → expand drawer avec historique complet.
///
/// Voir `docs/DESIGN.md` §2 signature patterns (extension Voice) et
/// `docs/tech-spec-engagement-layer-2026-04-15.md` story 5.
class TerminalCard extends StatefulWidget {
  const TerminalCard({
    required this.currentMessage,
    required this.history,
    this.timestamp,
    this.streakDays,
    this.onExpand,
    this.onExpandMessage,
    super.key,
  });

  /// Message courant affiché en bas du bloc, révélé avec typing animation.
  /// `null` → état "standby" (boot ou pool vide).
  final String? currentMessage;

  /// Historique plus ancien (3 max affichés en fade-up).
  final List<String> history;

  /// Timestamp optionnel du message courant, préfixé `[HH:mm]`.
  final DateTime? timestamp;

  /// Streak actuel affiché en première ligne (`[STREAK] day 12`).
  /// `null` → pas de ligne streak.
  final int? streakDays;

  /// Callback tap sur la card — expand history.
  final VoidCallback? onExpand;

  /// Callback tap sur le message courant (deep-link vers la card source).
  final VoidCallback? onExpandMessage;

  @override
  State<TerminalCard> createState() => _TerminalCardState();
}

class _TerminalCardState extends State<TerminalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _typingController;
  String _previousMessage = '';

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: _typingDurationFor(widget.currentMessage ?? ''),
    );
    _startTypingIfReady();
  }

  @override
  void didUpdateWidget(covariant TerminalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMessage != widget.currentMessage) {
      _previousMessage = oldWidget.currentMessage ?? '';
      _typingController
        ..stop()
        ..reset()
        ..duration = _typingDurationFor(widget.currentMessage ?? '');
      _startTypingIfReady();
    }
  }

  void _startTypingIfReady() {
    final String? msg = widget.currentMessage;
    if (msg == null || msg.isEmpty) return;
    _typingController.forward();
  }

  Duration _typingDurationFor(String text) =>
      Duration(milliseconds: (text.length * 24).clamp(200, 2500));

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: CalmRadius.xl2,
        cornerSmoothing: 0.6,
      ),
      side: const BorderSide(color: Color(0x33FFD9AE)),
    );

    // Current = blanc pur, high-contrast sur fond ink.
    // History = gris (fade progressif depuis neutral5 dark) pour donner un
    // vrai effet "log qui scroll", le message actuel pop.
    final TextStyle currentMono = AppTypography.mono(
      const TextStyle(
        fontSize: 13,
        height: 1.55,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
    final TextStyle historyMono = AppTypography.mono(
      const TextStyle(
        fontSize: 13,
        height: 1.55,
        color: AppColors.neutral5, // gris doux, pas blanc-fade
      ),
    );

    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: CalmBlur.floating,
          sigmaY: CalmBlur.floating,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: shape,
            onTap: widget.onExpand,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: shape,
                color: AppColors.ink,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CalmSpace.s6,
                  vertical: CalmSpace.s5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (widget.streakDays != null)
                      _StreakLine(streak: widget.streakDays!),
                    ..._historyLines(historyMono),
                    if (widget.currentMessage != null)
                      _currentLine(currentMono)
                    else
                      _standbyLine(historyMono),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _historyLines(TextStyle base) {
    // Jusqu'à 3 lignes d'historique en gris (plus vieux = plus fade).
    // Plus vieux = plus transparent sur la base gris neutral5.
    const List<double> opacities = <double>[1.0, 0.7, 0.4];
    final List<String> items = widget.history.take(3).toList();
    return <Widget>[
      for (int i = 0; i < items.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '> ${items[i]}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: base.copyWith(
              color: base.color?.withValues(
                alpha: opacities[i.clamp(0, opacities.length - 1)],
              ),
            ),
          ),
        ),
    ];
  }

  Widget _currentLine(TextStyle base) {
    final String prefix = widget.timestamp != null
        ? '[${_formatTime(widget.timestamp!)}] '
        : '> ';
    return GestureDetector(
      onTap: widget.onExpandMessage,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _typingController,
        builder: (BuildContext context, Widget? _) {
          final String full = widget.currentMessage ?? '';
          final int revealed = (_typingController.value * full.length).round();
          final String shown = full.substring(
            0,
            revealed.clamp(0, full.length),
          );
          final bool done = _typingController.isCompleted;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  '$prefix$shown',
                  style: base,
                ),
              ),
              if (!done) _BlinkingCaret(color: base.color ?? AppColors.canvas),
            ],
          );
        },
      ),
    );
  }

  Widget _standbyLine(TextStyle base) {
    return Text(
      LocaleKeys.voice_standby.tr(),
      style: base.copyWith(
        color: base.color?.withValues(alpha: 0.4),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final String h = dt.hour.toString().padLeft(2, '0');
    final String m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _StreakLine extends StatelessWidget {
  const _StreakLine({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CalmSpace.s3),
      child: Text(
        LocaleKeys.voice_streak_line.tr(
          namedArgs: <String, String>{
            'days': streak.toString().padLeft(2, '0'),
          },
        ),
        style: AppTypography.mono(
          const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.ember,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

/// Caret clignotant 500ms — seulement pendant la typing animation.
class _BlinkingCaret extends StatefulWidget {
  const _BlinkingCaret({required this.color});
  final Color color;

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _blink,
      child: Container(
        width: 8,
        height: 14,
        margin: const EdgeInsets.only(left: 4, top: 2),
        color: widget.color,
      ),
    );
  }
}
