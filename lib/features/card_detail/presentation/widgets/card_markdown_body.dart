import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:markdown/markdown.dart' as md;

/// Rendu markdown du fullContent d'une Card.
///
/// Styles calés sur le theme Beedle (sans ajout de font externe).
/// Les blocs code sont wrappés dans un glass card monospace avec bouton Copier.
class CardMarkdownBody extends StatelessWidget {
  const CardMarkdownBody({required this.markdown, super.key});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return MarkdownBody(
      data: markdown,
      selectable: true,
      builders: <String, MarkdownElementBuilder>{
        'code': _CodeBlockBuilder(colorScheme: colorScheme),
      },
      styleSheet: MarkdownStyleSheet(
        p: textTheme.bodyLarge?.copyWith(height: 1.55),
        h1: textTheme.headlineLarge,
        h2: textTheme.headlineMedium,
        h3: textTheme.headlineSmall,
        listBullet: textTheme.bodyLarge?.copyWith(height: 1.55),
        blockquote: textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        blockquoteDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: const Border(
            left: BorderSide(color: AppColors.orange500, width: 3),
          ),
        ),
        blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        a: textTheme.bodyLarge?.copyWith(
          color: AppColors.orange400,
          decoration: TextDecoration.underline,
        ),
        code: textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: colorScheme.surfaceContainerLow,
          color: AppColors.flame,
        ),
        codeblockDecoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.9),
          borderRadius: SmoothBorderRadius(cornerRadius: 18, cornerSmoothing: 0.6),
        ),
        codeblockPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _CodeBlockBuilder extends MarkdownElementBuilder {
  _CodeBlockBuilder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;
    final language = element.attributes['class']?.replaceFirst('language-', '');

    return _CodeBlockWidget(code: code, language: language, colorScheme: colorScheme);
  }
}

class _CodeBlockWidget extends StatefulWidget {
  const _CodeBlockWidget({
    required this.code,
    required this.language,
    required this.colorScheme,
  });

  final String code;
  final String? language;
  final ColorScheme colorScheme;

  @override
  State<_CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<_CodeBlockWidget> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 14),
        cornerRadius: 18,
        backgroundColor: widget.colorScheme.onSurface.withValues(alpha: 0.92),
        borderColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.language ?? 'code',
                  style: textTheme.labelSmall?.copyWith(
                    color: widget.colorScheme.surface.withValues(alpha: 0.7),
                    letterSpacing: 1.1,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _copy,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          _copied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 14,
                          color: widget.colorScheme.surface,
                        ),
                        const Gap(6),
                        Text(
                          _copied ? 'Copié' : 'Copier',
                          style: textTheme.labelSmall?.copyWith(
                            color: widget.colorScheme.surface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            SelectableText(
              widget.code,
              style: textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: widget.colorScheme.surface,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }
}
