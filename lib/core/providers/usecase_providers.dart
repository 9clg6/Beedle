import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/usecases/delete_card.use_case.dart';
import 'package:beedle/domain/usecases/export_all_data.use_case.dart';
import 'package:beedle/domain/usecases/get_card.use_case.dart';
import 'package:beedle/domain/usecases/get_gamification_dashboard.use_case.dart';
import 'package:beedle/domain/usecases/get_home_cards.use_case.dart';
import 'package:beedle/domain/usecases/import_screenshots.use_case.dart';
import 'package:beedle/domain/usecases/mark_card_tested.use_case.dart';
import 'package:beedle/domain/usecases/mark_card_viewed.use_case.dart';
import 'package:beedle/domain/usecases/search_cards.use_case.dart';
import 'package:beedle/domain/usecases/wipe_all_data.use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<ImportScreenshotsUseCase> importScreenshotsUseCaseProvider =
    Provider<ImportScreenshotsUseCase>((Ref ref) {
      return ImportScreenshotsUseCase(
        screenshotRepository: ref.watch(screenshotRepositoryProvider),
        ingestionJobRepository: ref.watch(ingestionJobRepositoryProvider),
        gamificationEngine: ref.watch(gamificationEngineProvider),
      );
    });

final Provider<SearchCardsUseCase> searchCardsUseCaseProvider =
    Provider<SearchCardsUseCase>((Ref ref) {
      return SearchCardsUseCase(
        cardRepository: ref.watch(cardRepositoryProvider),
        embeddingsRepository: ref.watch(embeddingsRepositoryProvider),
      );
    });

final Provider<GetHomeCardsUseCase> getHomeCardsUseCaseProvider =
    Provider<GetHomeCardsUseCase>((Ref ref) {
      return GetHomeCardsUseCase(
        cardRepository: ref.watch(cardRepositoryProvider),
      );
    });

final Provider<GetCardUseCase> getCardUseCaseProvider =
    Provider<GetCardUseCase>((Ref ref) {
      return GetCardUseCase(cardRepository: ref.watch(cardRepositoryProvider));
    });

final Provider<MarkCardViewedUseCase> markCardViewedUseCaseProvider =
    Provider<MarkCardViewedUseCase>((Ref ref) {
      return MarkCardViewedUseCase(
        cardRepository: ref.watch(cardRepositoryProvider),
        gamificationEngine: ref.watch(gamificationEngineProvider),
      );
    });

final Provider<MarkCardTestedUseCase> markCardTestedUseCaseProvider =
    Provider<MarkCardTestedUseCase>((Ref ref) {
      return MarkCardTestedUseCase(
        cardRepository: ref.watch(cardRepositoryProvider),
        gamificationEngine: ref.watch(gamificationEngineProvider),
      );
    });

final Provider<DeleteCardUseCase> deleteCardUseCaseProvider =
    Provider<DeleteCardUseCase>((Ref ref) {
      return DeleteCardUseCase(
        cardRepository: ref.watch(cardRepositoryProvider),
      );
    });

final Provider<ExportAllDataUseCase> exportAllDataUseCaseProvider =
    Provider<ExportAllDataUseCase>((Ref ref) {
      return ExportAllDataUseCase(
        dataExportService: ref.watch(dataManagementServiceProvider),
      );
    });

final Provider<WipeAllDataUseCase> wipeAllDataUseCaseProvider =
    Provider<WipeAllDataUseCase>((Ref ref) {
      return WipeAllDataUseCase(
        dataWipeService: ref.watch(dataManagementServiceProvider),
      );
    });

final Provider<GetGamificationDashboardUseCase>
getGamificationDashboardUseCaseProvider =
    Provider<GetGamificationDashboardUseCase>((Ref ref) {
      return GetGamificationDashboardUseCase(
        gamificationRepository: ref.watch(gamificationRepositoryProvider),
      );
    });
