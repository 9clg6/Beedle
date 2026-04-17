import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:beedle/domain/enum/onboarding_goal.enum.dart';
import 'package:beedle/domain/enum/pain_point.enum.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding_step_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingStepValidator.canAdvance', () {
    final OnboardingState empty = OnboardingState.initial();

    test('non-validated steps always advance', () {
      for (final int i in <int>[0, 3, 4, 5, 6, 8, 9, 10, 11, 13, 14]) {
        expect(
          OnboardingStepValidator.canAdvance(i, empty),
          isTrue,
          reason: 'index $i should not be validated',
        );
      }
    });

    test('step 1 (Goal) requires a goal selection', () {
      expect(OnboardingStepValidator.canAdvance(1, empty), isFalse);
      expect(
        OnboardingStepValidator.canAdvance(
          1,
          empty.copyWith(goal: OnboardingGoal.buildFaster),
        ),
        isTrue,
      );
    });

    test('step 2 (Pain points) requires at least one selection', () {
      expect(OnboardingStepValidator.canAdvance(2, empty), isFalse);
      expect(
        OnboardingStepValidator.canAdvance(
          2,
          empty.copyWith(painPoints: <PainPoint>{PainPoint.reGoogle}),
        ),
        isTrue,
      );
    });

    test('step 7 (Categories) requires at least one category', () {
      expect(OnboardingStepValidator.canAdvance(7, empty), isFalse);
      expect(
        OnboardingStepValidator.canAdvance(
          7,
          empty.copyWith(
            contentCategories: <ContentCategory>[ContentCategory.techAi],
          ),
        ),
        isTrue,
      );
    });

    test('step 12 (Demo) requires demoCompleted = true', () {
      expect(OnboardingStepValidator.canAdvance(12, empty), isFalse);
      expect(
        OnboardingStepValidator.canAdvance(
          12,
          empty.copyWith(demoCompleted: true),
        ),
        isTrue,
      );
    });
  });

  group('OnboardingStepValidator step categorization', () {
    test('full-immersion steps are 0, 11, 13', () {
      expect(kFullImmersionSteps, <int>{0, 11, 13});
    });

    test('auto-advance steps are 3 (tinder) and 14 (paywall)', () {
      expect(kAutoAdvanceSteps, <int>{3, 14});
    });

    test('validated steps are 1, 2, 7, 12', () {
      expect(kValidatedSteps, <int>{1, 2, 7, 12});
    });

    test('requiresValidation matches kValidatedSteps', () {
      for (int i = 0; i <= 14; i++) {
        expect(
          OnboardingStepValidator.requiresValidation(i),
          kValidatedSteps.contains(i),
          reason: 'index $i',
        );
      }
    });
  });
}
