import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/repositories/subscription.repository.dart' show SubscriptionRepository;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream du statut Pro de l'utilisateur courant.
///
/// Basé sur [SubscriptionRepository.watch] (ObjectBox via mapper), donc
/// rebuild automatiquement après un achat / restore / refresh RevenueCat.
///
/// Usage UI :
/// ```dart
/// final bool isPro = ref.watch(proStatusProvider).value ?? false;
/// ```
///
/// Usage impératif (gate ponctuel) :
/// ```dart
/// final snap = await ref.read(subscriptionRepositoryProvider).load();
/// if (!snap.isPro) { showContextualPaywall(...); return; }
/// ```
final StreamProvider<bool> proStatusProvider = StreamProvider<bool>((Ref ref) {
  return ref
      .watch(subscriptionRepositoryProvider)
      .watch()
      .map((SubscriptionSnapshotEntity s) => s.isPro);
});
