import 'package:beedle/domain/entities/onboarding_sample_card.entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingSampleCard.fromJson', () {
    test('parses a complete payload', () {
      final OnboardingSampleCard card = OnboardingSampleCard.fromJson(
        const <String, dynamic>{
          'title': 'Prompt eval cheatsheet',
          'summary': '5 prompts pour évaluer un LLM en 30 secondes.',
          'actionLabel': 'Tester maintenant',
          'intent': 'apply',
          'tags': <String>['llm', 'eval'],
        },
      );

      expect(card.title, 'Prompt eval cheatsheet');
      expect(card.summary, '5 prompts pour évaluer un LLM en 30 secondes.');
      expect(card.actionLabel, 'Tester maintenant');
      expect(card.intent, 'apply');
      expect(card.tags, <String>['llm', 'eval']);
    });

    test('roundtrips through toJson/fromJson', () {
      const OnboardingSampleCard original = OnboardingSampleCard(
        title: 't',
        summary: 's',
        actionLabel: 'a',
        intent: 'read',
        tags: <String>['x'],
      );

      final OnboardingSampleCard reparsed = OnboardingSampleCard.fromJson(
        original.toJson(),
      );

      expect(reparsed, original);
    });
  });
}
