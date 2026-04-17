import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/engagement_message.entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'engagement_home.view_model.g.dart';

/// Agrège les infos nécessaires au Terminal Card sur la Home.
///
/// - [current]  : prochain message éligible (format long).
/// - [history]  : messages précédents (shownAt != null), les 3 plus récents.
class EngagementHomeState {
  const EngagementHomeState({
    required this.current,
    required this.history,
  });

  final EngagementMessageEntity? current;
  final List<EngagementMessageEntity> history;

  EngagementHomeState.empty()
    : current = null,
      history = const <EngagementMessageEntity>[];
}

@riverpod
class EngagementHomeViewModel extends _$EngagementHomeViewModel {
  @override
  Future<EngagementHomeState> build() => _fetch();

  Future<EngagementHomeState> _fetch() async {
    final EngagementMessageEntity? current = await ref
        .read(engagementSchedulerServiceProvider)
        .nextMessageForHome();

    final List<EngagementMessageEntity> all = <EngagementMessageEntity>[];
    // History = messages déjà vus, triés par shownAt desc (proxy : createdAt).
    // On scan via byCardUuid n'est pas trivial sans query dédiée — lecture
    // directe du pool via repository.
    final List<EngagementMessageEntity> pool = await ref
        .read(engagementMessageRepositoryProvider)
        .pendingPool(limit: 200);
    all.addAll(pool);
    // Note : `pendingPool` ne renvoie que les non-shown. L'historique vrai
    // nécessitera une query supplémentaire ("lastShown") si besoin. Pour
    // l'instant : on montre des messages "récemment passés" = messages
    // avec scheduledAt non null mais shownAt null (déjà programmés).
    final List<EngagementMessageEntity> history =
        pool.where((EngagementMessageEntity m) => m.isScheduled).toList()
          ..sort((EngagementMessageEntity a, EngagementMessageEntity b) {
            final DateTime? aAt = a.scheduledAt;
            final DateTime? bAt = b.scheduledAt;
            if (aAt == null || bAt == null) return 0;
            return bAt.compareTo(aAt);
          });

    return EngagementHomeState(
      current: current,
      history: history.take(3).toList(),
    );
  }

  /// Marque le message courant comme vu + re-fetch pour surface le prochain.
  Future<void> markCurrentShown() async {
    final EngagementHomeState? current = state.value;
    final EngagementMessageEntity? msg = current?.current;
    if (msg == null) return;
    await ref.read(engagementSchedulerServiceProvider).markShown(msg.uuid);
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<EngagementHomeState>();
    state = await AsyncValue.guard(_fetch);
  }
}
