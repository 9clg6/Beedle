import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart' show SquircleButton;
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Variante visuelle du bouton de provider auth.
enum AuthProviderButtonVariant {
  /// Fond noir, texte/icone blanc — pour Apple (cohérent guidelines Apple).
  apple,

  /// Fond blanc, bord neutral, texte ink — pour Google.
  google,
}

/// Bouton dédié à un provider OAuth (Apple, Google).
///
/// Forme squircle pill cohérente avec [SquircleButton], mais avec un slot
/// pour l'icône brand. Si [loading] vaut true, l'icône est remplacée par un
/// loader inline et le tap est désactivé.
class AuthProviderButton extends StatelessWidget {
  const AuthProviderButton({
    required this.label,
    required this.variant,
    required this.onPressed,
    this.loading = false,
    super.key,
  });

  final String label;
  final AuthProviderButtonVariant variant;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final _ButtonSpec spec = _resolveSpec(variant);

    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(cornerRadius: CalmRadius.pill),
      side: spec.borderColor != null
          ? BorderSide(color: spec.borderColor!)
          : BorderSide.none,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: shape,
        onTap: loading ? null : onPressed,
        child: AnimatedContainer(
          duration: CalmDuration.quick,
          curve: CalmCurves.standard,
          decoration: ShapeDecoration(shape: shape, color: spec.background),
          padding: const EdgeInsets.symmetric(
            horizontal: CalmSpace.s6,
            vertical: CalmSpace.s4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (loading)
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: spec.foreground,
                  ),
                )
              else
                Icon(spec.icon, size: 20, color: spec.foreground),
              const Gap(CalmSpace.s4),
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(color: spec.foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ButtonSpec _resolveSpec(AuthProviderButtonVariant v) {
    switch (v) {
      case AuthProviderButtonVariant.apple:
        return const _ButtonSpec(
          icon: Icons.apple_rounded,
          foreground: AppColors.canvas,
          background: AppColors.ink,
        );
      case AuthProviderButtonVariant.google:
        return const _ButtonSpec(
          icon: Icons.g_mobiledata_rounded,
          foreground: AppColors.ink,
          background: AppColors.canvas,
          borderColor: AppColors.neutral3,
        );
    }
  }
}

class _ButtonSpec {
  const _ButtonSpec({
    required this.icon,
    required this.foreground,
    required this.background,
    this.borderColor,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
  final Color? borderColor;
}
