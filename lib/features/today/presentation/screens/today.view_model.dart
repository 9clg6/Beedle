import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today.view_model.g.dart';

@riverpod
class TodayViewModel extends _$TodayViewModel {
  @override
  Future<CardEntity?> build() async {
    return ref.read(dailyLessonServiceProvider).pickTodayLesson();
  }

  /// User tape "C'est fait" → mark testedAt + refresh.
  Future<void> markDone(String uuid) async {
    await ref.read(cardRepositoryProvider).markTested(uuid);
    ref.invalidateSelf();
  }

  /// User tape "Remettre à demain" → ne rien marquer, juste refresh (qui
  /// potentiellement surface une autre card).
  Future<void> skip() async {
    ref.invalidateSelf();
  }
}
