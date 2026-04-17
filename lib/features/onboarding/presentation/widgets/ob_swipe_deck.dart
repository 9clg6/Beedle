import 'package:flutter/material.dart';

/// Décalage vertical entre les cards en arrière-plan (px).
const double _kStackTopOffset = 8;

/// Décalage horizontal (px).
const double _kStackHorizontalOffset = 6;

/// Atténuation d'opacité par carte d'arrière-plan.
const double _kStackOpacityStep = 0.18;

/// Nombre max de cards visibles en arrière-plan.
const int _kStackMaxBackground = 2;

/// Stack de cards swipables type Tinder, partagé entre l'écran 04 (Tinder)
/// et l'écran 13 (Demo).
///
/// - [total] : nombre total d'items dans le deck
/// - [currentIndex] : prochain index à présenter (0-based ; >= total = stack
///   épuisé, [emptyChild] est rendu)
/// - [cardBuilder] : construit le visuel de la carte à un index donné
/// - [onDismissed] : appelé quand la top card est dismissée
/// - [emptyChild] : rendu quand il ne reste plus de carte (par défaut
///   `SizedBox.shrink()`)
class ObSwipeDeck extends StatelessWidget {
  const ObSwipeDeck({
    required this.total,
    required this.currentIndex,
    required this.cardBuilder,
    required this.onDismissed,
    this.emptyChild = const SizedBox.shrink(),
    super.key,
  });

  final int total;
  final int currentIndex;
  final Widget Function(BuildContext context, int index) cardBuilder;
  final void Function(DismissDirection direction) onDismissed;
  final Widget emptyChild;

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= total) return emptyChild;

    final int remaining = total - currentIndex - 1;
    final int maxBackground = remaining.clamp(0, _kStackMaxBackground);

    final List<Widget> cards = <Widget>[];
    for (int i = maxBackground; i >= 1; i--) {
      cards.add(
        Positioned.fill(
          top: i * _kStackTopOffset,
          left: i * _kStackHorizontalOffset,
          right: i * _kStackHorizontalOffset,
          child: Opacity(
            opacity: 1.0 - (i * _kStackOpacityStep),
            child: cardBuilder(context, currentIndex + i),
          ),
        ),
      );
    }
    cards.add(
      Positioned.fill(
        child: Dismissible(
          key: ValueKey<int>(currentIndex),
          direction: DismissDirection.horizontal,
          onDismissed: onDismissed,
          child: cardBuilder(context, currentIndex),
        ),
      ),
    );
    return Stack(children: cards);
  }
}
