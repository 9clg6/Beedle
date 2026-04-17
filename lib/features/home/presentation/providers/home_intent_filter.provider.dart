import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Filtre d'intent actif sur la Home — session-only, pas persisté.
///
/// `null` = "Toutes" (pas de filter).
final NotifierProvider<HomeIntentFilter, CardIntent?> homeIntentFilterProvider =
    NotifierProvider<HomeIntentFilter, CardIntent?>(HomeIntentFilter.new);

class HomeIntentFilter extends Notifier<CardIntent?> {
  @override
  CardIntent? build() => null;

  void set(CardIntent? value) => state = value;
}
