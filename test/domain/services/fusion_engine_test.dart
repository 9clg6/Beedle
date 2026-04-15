import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/screenshot.entity.dart';
import 'package:beedle/domain/enum/card_level.enum.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/domain/repositories/screenshot.repository.dart';
import 'package:beedle/domain/services/fusion_engine.service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockScreenshotRepository extends Mock implements ScreenshotRepository {}

class _MockCardRepository extends Mock implements CardRepository {}

void main() {
  late _MockScreenshotRepository screenshotRepository;
  late _MockCardRepository cardRepository;
  late FusionEngine engine;

  setUp(() {
    screenshotRepository = _MockScreenshotRepository();
    cardRepository = _MockCardRepository();
    engine = FusionEngine(
      screenshotRepository: screenshotRepository,
      cardRepository: cardRepository,
    );
  });

  ScreenshotEntity makeScreenshot({
    required String uuid,
    required String ocrText,
    String? cardUuid,
  }) {
    return ScreenshotEntity(
      uuid: uuid,
      filePath: '/tmp/$uuid.png',
      sha256: uuid,
      capturedAt: DateTime.now(),
      ocrText: ocrText,
      cardUuid: cardUuid,
    );
  }

  CardEntity makeCard(String uuid) => CardEntity(
        uuid: uuid,
        title: 'title',
        summary: 'summary',
        fullContent: '# content',
        level: CardLevel.beginner,
        tags: const <String>[],
        language: 'en',
        teaserHook: 'hook',
        status: IngestionStatus.completed,
        createdAt: DateTime.now(),
      );

  group('FusionEngine', () {
    test('returns null if OCR text is empty', () async {
      final newScreen = makeScreenshot(uuid: 'a', ocrText: '');
      when(() => screenshotRepository.getRecent(within: any(named: 'within')))
          .thenAnswer((_) async => <ScreenshotEntity>[]);

      final result = await engine.findFusionCandidate(newScreen);
      expect(result, isNull);
    });

    test('returns null when no recent screenshots match', () async {
      final newScreen =
          makeScreenshot(uuid: 'a', ocrText: 'Completely unrelated content about cooking');
      final other = makeScreenshot(
        uuid: 'b',
        ocrText: 'Claude code hooks automation tutorial',
        cardUuid: 'card-b',
      );

      when(() => screenshotRepository.getRecent(within: any(named: 'within')))
          .thenAnswer((_) async => <ScreenshotEntity>[other]);

      final result = await engine.findFusionCandidate(newScreen);
      expect(result, isNull);
    });

    test('returns cardUuid when Jaccard ≥ 40 %', () async {
      final newScreen = makeScreenshot(
        uuid: 'a',
        ocrText: 'Claude code hooks automation plugin tutorial step',
      );
      final existing = makeScreenshot(
        uuid: 'b',
        ocrText: 'Claude code hooks automation plugin tutorial',
        cardUuid: 'card-b',
      );

      when(() => screenshotRepository.getRecent(within: any(named: 'within')))
          .thenAnswer((_) async => <ScreenshotEntity>[existing]);
      when(() => cardRepository.getByUuid('card-b'))
          .thenAnswer((_) async => makeCard('card-b'));

      final result = await engine.findFusionCandidate(newScreen);
      expect(result, equals('card-b'));
    });
  });
}
