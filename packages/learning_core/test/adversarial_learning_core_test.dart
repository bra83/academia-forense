import 'package:flutter_test/flutter_test.dart';
import 'package:learning_core/learning_core.dart';

void main() {
  group('Milestone 3 Adversarial: 10-Step Lesson Engine (§8, §8.1)', () {
    test('enforces strict out-of-order forward jump prevention', () {
      final engine = LessonEngine(lessonId: 'ch01');
      expect(engine.currentStepIndex, equals(0));

      // Attempt illegal jumps from index 0
      for (int target = 2; target < 10; target++) {
        expect(
          () => engine.currentStepIndex = target,
          throwsArgumentError,
          reason: 'Cannot jump from step 0 to step $target without completing prerequisites',
        );
      }

      // Can navigate to current step
      engine.currentStepIndex = 0;
      expect(engine.currentStepIndex, equals(0));

      // Complete step 0 -> current becomes 1
      engine.completeCurrentStep();
      expect(engine.currentStepIndex, equals(1));

      // Cannot jump past step 1
      expect(() => engine.currentStepIndex = 3, throwsArgumentError);
      expect(() => engine.currentStepIndex = 7, throwsArgumentError);
    });

    test('step 8 (Assessment) remains locked until all steps 1-7 are completed', () {
      final engine = LessonEngine(lessonId: 'ch01');
      expect(engine.canUnlockAssessment(), isFalse);

      // Complete steps 0 through 5 (steps 1 through 6)
      for (int i = 0; i < 6; i++) {
        engine.completeCurrentStep();
        expect(engine.canUnlockAssessment(), isFalse,
            reason: 'Step 8 must remain locked when only ${i + 1} steps are completed');
      }

      // Complete 7th step (index 6, step 7)
      engine.completeCurrentStep();
      expect(engine.canUnlockAssessment(), isTrue,
          reason: 'Step 8 must unlock once steps 1-7 are completed');
    });

    test('backwards navigation is unrestricted and preserves progress percentage', () {
      final engine = LessonEngine(lessonId: 'ch01');
      for (int i = 0; i < 5; i++) {
        engine.completeCurrentStep();
      }
      // Completed steps 0, 1, 2, 3, 4 -> at step 5
      expect(engine.currentStepIndex, equals(5));
      expect(engine.progressPercentage, equals(50.0));

      // Jump back to step 0
      engine.currentStepIndex = 0;
      expect(engine.currentStepIndex, equals(0));
      expect(engine.progressPercentage, equals(50.0));

      // Jump forward to step 3 (previously completed)
      engine.currentStepIndex = 3;
      expect(engine.currentStepIndex, equals(3));
      expect(engine.progressPercentage, equals(50.0));

      // Jump back to step 5 (next uncompleted)
      engine.currentStepIndex = 5;
      expect(engine.currentStepIndex, equals(5));
      expect(engine.progressPercentage, equals(50.0));
    });

    test('progress percentage scales strictly from 0.0% to 100.0%', () {
      final engine = LessonEngine(lessonId: 'ch01');
      expect(engine.progressPercentage, equals(0.0));
      expect(engine.isCompleted, isFalse);

      for (int step = 1; step <= 10; step++) {
        engine.completeCurrentStep();
        final expectedPercent = step * 10.0;
        expect(engine.progressPercentage, equals(expectedPercent));
        if (step < 10) {
          expect(engine.isCompleted, isFalse);
        } else {
          expect(engine.isCompleted, isTrue);
        }
      }
    });

    test('adversarial boundary step numbers and indices throw RangeError', () {
      final engine = LessonEngine(lessonId: 'ch01');
      // Step indices: [0, 9]
      expect(() => engine.currentStepIndex = -1, throwsRangeError);
      expect(() => engine.currentStepIndex = 10, throwsRangeError);
      expect(() => engine.currentStepIndex = 99, throwsRangeError);

      // Step numbers: [1, 10]
      expect(() => engine.navigateToStepNumber(0), throwsRangeError);
      expect(() => engine.navigateToStepNumber(-5), throwsRangeError);
      expect(() => engine.navigateToStepNumber(11), throwsRangeError);
      expect(() => engine.navigateToStepNumber(100), throwsRangeError);
      expect(() => engine.getStep(0), throwsRangeError);
      expect(() => engine.getStep(11), throwsRangeError);
    });

    test('rejects didactic sequences with non-canonical step count or blank steps', () {
      expect(
        () => LessonEngine(lessonId: 'bad', initialSteps: []),
        throwsArgumentError,
      );
      expect(
        () => LessonEngine(
          lessonId: 'bad',
          initialSteps: List.generate(
            9,
            (i) => DidacticStep(index: i + 1, title: 'T', content: 'C'),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => LessonEngine(
          lessonId: 'bad',
          initialSteps: List.generate(
            11,
            (i) => DidacticStep(index: ((i % 10) + 1), title: 'T', content: 'C'),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => DidacticStep(index: 1, title: '   ', content: 'Valid'),
        throwsArgumentError,
      );
      expect(
        () => DidacticStep(index: 1, title: 'Valid', content: '  \n\t '),
        throwsArgumentError,
      );
    });
  });

  group('Milestone 3 Adversarial: Spaced Repetition Progression & Reset (§17.1)', () {
    final baseDate = DateTime(2026, 11, 16, 10, 0, 0);

    test('passing score (>= 80%) advances intervals: 1 -> 3 -> 7 -> 14 -> 30 days', () {
      final expectedOffsets = [1, 3, 7, 14, 30];

      for (int rep = 0; rep < expectedOffsets.length; rep++) {
        final reviewDate = AdaptiveStudyPlanner.calculateSpacedReviewDate(
          lastReviewed: baseDate,
          repetitionCount: rep,
          score: 0.80, // exact 80% passing
        );
        final difference = reviewDate.difference(baseDate).inDays;
        expect(difference, equals(expectedOffsets[rep]),
            reason: 'Repetition $rep with 80% score should schedule in ${expectedOffsets[rep]} days');
      }

      // Repetition >= 4 caps at 30 days
      for (final highRep in [4, 5, 10, 50]) {
        final reviewDate = AdaptiveStudyPlanner.calculateSpacedReviewDate(
          lastReviewed: baseDate,
          repetitionCount: highRep,
          score: 1.0,
        );
        expect(reviewDate.difference(baseDate).inDays, equals(30));
      }
    });

    test('failing score (< 80%) immediately resets interval to 1 day regardless of repetition count', () {
      for (final failingScore in [0.7999, 0.79, 0.50, 0.10, 0.0]) {
        for (int rep = 0; rep <= 5; rep++) {
          final reviewDate = AdaptiveStudyPlanner.calculateSpacedReviewDate(
            lastReviewed: baseDate,
            repetitionCount: rep,
            score: failingScore,
          );
          final diff = reviewDate.difference(baseDate).inDays;
          expect(diff, equals(1),
              reason: 'Failing score $failingScore at repetition $rep must reset to 1 day');
        }
      }
    });

    test('negative repetition count gracefully handles with first interval (1 day)', () {
      final reviewDate = AdaptiveStudyPlanner.calculateSpacedReviewDate(
        lastReviewed: baseDate,
        repetitionCount: -1,
        score: 0.95,
      );
      expect(reviewDate.difference(baseDate).inDays, equals(1));
    });
  });

  group('Milestone 3 Adversarial: Weekly Study Target & Rollover (§17.1)', () {
    test('weekly target boundary validation (0.0h, negative, > 168.0h)', () {
      expect(() => AdaptiveStudyPlanner.validateWeeklyStudyTarget(0.0), throwsArgumentError);
      expect(() => AdaptiveStudyPlanner.validateWeeklyStudyTarget(-0.01), throwsArgumentError);
      expect(() => AdaptiveStudyPlanner.validateWeeklyStudyTarget(-13.0), throwsArgumentError);
      expect(() => AdaptiveStudyPlanner.validateWeeklyStudyTarget(168.001), throwsArgumentError);
      expect(() => AdaptiveStudyPlanner.validateWeeklyStudyTarget(200.0), throwsArgumentError);

      // Boundaries exactly at 0.001h and 168.0h are accepted
      expect(() => AdaptiveStudyPlanner.validateWeeklyStudyTarget(0.001), returnsNormally);
      expect(() => AdaptiveStudyPlanner.validateWeeklyStudyTarget(168.0), returnsNormally);
    });

    test('weekly rollover isolates study sessions to their calendar week', () {
      final planner = AdaptiveStudyPlanner(weeklyTargetHours: 13.0);

      // Reference week in past: Nov 2 - Nov 8, 2026 (Monday Nov 2 to Sunday Nov 8)
      final mondayWeekB = DateTime.utc(2026, 11, 2, 10, 0); // Monday
      final wednesdayWeekB = DateTime.utc(2026, 11, 4, 14, 0); // Wednesday
      final sundayWeekB = DateTime.utc(2026, 11, 8, 22, 0); // Sunday

      // Prior week: Sunday Nov 1, 2026 23:59
      final sundayPriorWeek = DateTime.utc(2026, 11, 1, 23, 59);

      // Next week: Monday Nov 9, 2026 00:01
      final mondayNextWeek = DateTime.utc(2026, 11, 9, 0, 1);

      // Record 2 hours in prior week
      planner.recordStudySession(
        chapterId: 'ch01',
        durationSeconds: 7200, // 2h
        completedAt: sundayPriorWeek,
      );

      // Record 3h + 4h + 2h in reference week (total 9h)
      planner.recordStudySession(
        chapterId: 'ch02',
        durationSeconds: 10800, // 3h
        completedAt: mondayWeekB,
      );
      planner.recordStudySession(
        chapterId: 'ch03',
        durationSeconds: 14400, // 4h
        completedAt: wednesdayWeekB,
      );
      planner.recordStudySession(
        chapterId: 'ch04',
        durationSeconds: 7200, // 2h
        completedAt: sundayWeekB,
      );

      // Record 5 hours in next week
      planner.recordStudySession(
        chapterId: 'ch05',
        durationSeconds: 18000, // 5h
        completedAt: mondayNextWeek,
      );

      // Verify reference week accumulation is exactly 9.0h (does not bleed prior or next week)
      final accumulatedWeekB = planner.getWeeklyAccumulatedHours(wednesdayWeekB);
      expect(accumulatedWeekB, equals(9.0));

      // Verify prior week accumulation is exactly 2.0h
      final accumulatedPrior = planner.getWeeklyAccumulatedHours(sundayPriorWeek);
      expect(accumulatedPrior, equals(2.0));

      // Verify next week accumulation is exactly 5.0h
      final accumulatedNext = planner.getWeeklyAccumulatedHours(mondayNextWeek);
      expect(accumulatedNext, equals(5.0));
    });
  });
}
