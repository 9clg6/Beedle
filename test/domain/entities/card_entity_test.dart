import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/enum/card_level.enum.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CardEntity make({DateTime? viewedAt, IngestionStatus status = IngestionStatus.completed}) => CardEntity(
        uuid: 'u',
        title: 't',
        summary: 's',
        fullContent: '# test content',
        level: CardLevel.beginner,
        tags: const <String>[],
        language: 'en',
        teaserHook: 'h',
        status: status,
        createdAt: DateTime.now(),
        viewedAt: viewedAt,
      );

  group('CardEntity extensions', () {
    test('isStale when viewedAt is null', () {
      expect(make().isStale, isTrue);
    });

    test('isStale when viewedAt > 14 days ago', () {
      expect(
        make(viewedAt: DateTime.now().subtract(const Duration(days: 30))).isStale,
        isTrue,
      );
    });

    test('not stale when viewed recently', () {
      expect(
        make(viewedAt: DateTime.now().subtract(const Duration(days: 2))).isStale,
        isFalse,
      );
    });

    test('isGenerated returns true when status=completed', () {
      expect(make().isGenerated, isTrue);
    });

    test('isPending when queued or processing', () {
      expect(make(status: IngestionStatus.queued).isPending, isTrue);
      expect(make(status: IngestionStatus.processing).isPending, isTrue);
    });
  });
}
