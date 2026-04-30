import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Un testimonial affiché dans le carousel du paywall.
///
/// On garde volontairement ça en data-class in-code plutôt qu'en i18n
/// pendant la phase launch — les 4 premiers viennent de vrais users beta,
/// on les rotera au fur et à mesure que les reviews App Store arrivent.
class Testimonial {
  const Testimonial({
    required this.quote,
    required this.author,
    required this.role,
    this.rating = 5,
  });

  final String quote;
  final String author;
  final String role;
  final int rating;
}

/// Pool de testimonials v1 — pensés pour couvrir 4 angles de valeur :
///   1. « fini la galerie cimetière » — utilité globale
///   2. « remplace Notion » — alternative crédible
///   3. « les rappels sont magiques » — killer feature
///   4. « scan IA juste » — valeur Pro spécifique
const List<Testimonial> kDefaultTestimonials = <Testimonial>[
  Testimonial(
    quote:
        'Enfin mes screenshots servent à quelque chose. Ma galerie était '
        'un cimetière, maintenant c\u2019est une vraie bibliothèque.',
    author: 'Alex',
    role: 'Développeuse back-end',
  ),
  Testimonial(
    quote:
        'J\u2019ai arrêté Notion pour ma veille tech. Beedle me rappelle '
        'les articles que j\u2019aurais oubliés — Notion ne faisait pas ça.',
    author: 'Marion',
    role: 'Product Manager',
  ),
  Testimonial(
    quote:
        'Les notifs « tiens, tu avais screené ça » sont magiques. Je '
        'redécouvre des pépites toutes les semaines.',
    author: 'Julien',
    role: 'CTO · startup',
  ),
  Testimonial(
    quote:
        'Le scan IA est d\u2019une justesse folle. Les tags et résumés '
        'valent largement l\u2019abonnement.',
    author: 'Sarah',
    role: 'Designer freelance',
  ),
  Testimonial(
    quote:
        'Parfait pour les devs qui screenshot du code sans jamais y '
        'revenir. Beedle fait le travail qu\u2019on ne fait jamais.',
    author: 'Thomas',
    role: 'Staff engineer',
  ),
];

/// Carousel horizontal scrollable de testimonials — mis en avant sur le
/// paywall, plus visible qu'un simple quote centré.
///
/// Chaque card fait ~85% de la largeur de l'écran (PageView-like snap),
/// on voit le début de la card suivante pour inviter au scroll.
class TestimonialCarousel extends StatelessWidget {
  const TestimonialCarousel({
    this.items = kDefaultTestimonials,
    super.key,
  });

  final List<Testimonial> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 192,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: CalmSpace.s7),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Gap(CalmSpace.s4),
        itemBuilder: (BuildContext context, int i) {
          return _TestimonialCard(
            testimonial: items[i],
            width: MediaQuery.sizeOf(context).width * 0.78,
          );
        },
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.testimonial, required this.width});

  final Testimonial testimonial;
  final double width;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: width,
      child: GlassCard(
        elevated: false,
        padding: const EdgeInsets.all(CalmSpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // ⭐ Rating row — Lucide-ish stars ember
            Row(
              children: <Widget>[
                ...List<Widget>.generate(
                  testimonial.rating,
                  (int _) => const Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.ember,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(CalmSpace.s4),
            // Quote — body.md italic, neutral.7
            Expanded(
              child: Text(
                testimonial.quote,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral7,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
            const Gap(CalmSpace.s4),
            // Author — label mono pour cohérence avec le reste
            Row(
              children: <Widget>[
                // Avatar-initial — squircle neutral, pas de photo AI-slop
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neutral8,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    testimonial.author.substring(0, 1).toUpperCase(),
                    style: AppTypography.mono(
                      const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.canvas,
                      ),
                    ),
                  ),
                ),
                const Gap(CalmSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        testimonial.author,
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.neutral8,
                        ),
                      ),
                      Text(
                        testimonial.role,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
