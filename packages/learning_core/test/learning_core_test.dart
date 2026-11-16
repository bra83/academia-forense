import 'package:flutter_test/flutter_test.dart';
import 'package:learning_core/learning_core.dart';

void main() {
  group('10-Step Lesson Engine (§8, §8.1)', () {
    test('defines exact 10 canonical didactic steps in proper order', () {
      final steps = LessonEngine.DIDACTIC_STEPS;
      expect(steps.length, equals(10));
      expect(steps[0].toLowerCase(), contains('objetivo'));
      expect(steps[1].toLowerCase(), contains('pré-requisito'));
      expect(steps[2].toLowerCase(), contains('problema'));
      expect(steps[3].toLowerCase(), contains('teórica'));
      expect(steps[4].toLowerCase(), contains('exemplo resolvido'));
      expect(steps[5].toLowerCase(), contains('exercício guiado'));
      expect(steps[6].toLowerCase(), contains('atividade prática'));
      expect(steps[7].toLowerCase(), contains('avaliação'));
      expect(steps[8].toLowerCase(), contains('revisão'));
      expect(steps[9].toLowerCase(), contains('resumo'));
    });

    test('step-by-step progression advances step and updates progress percentage', () {
      final engine = LessonEngine(lessonId: 'ch01_lesson');
      expect(engine.currentStepIndex, equals(0));
      expect(engine.currentStepNumber, equals(1));
      expect(engine.progressPercentage, equals(0.0));
      expect(engine.isCompleted, isFalse);

      engine.completeCurrentStep();
      expect(engine.currentStepIndex, equals(1));
      expect(engine.currentStepNumber, equals(2));
      expect(engine.progressPercentage, equals(10.0));
      expect(engine.isCompleted, isFalse);
    });

    test('completing all 10 steps reaches 100% and isCompleted is true', () {
      final engine = LessonEngine(lessonId: 'ch01_lesson');
      for (int i = 0; i < 10; i++) {
        engine.completeCurrentStep();
      }
      expect(engine.progressPercentage, equals(100.0));
      expect(engine.isCompleted, isTrue);
    });

    test('backwards navigation is allowed to previously visited/completed steps', () {
      final engine = LessonEngine(lessonId: 'ch01_lesson');
      engine.completeCurrentStep(); // done 0 -> at 1
      engine.completeCurrentStep(); // done 1 -> at 2
      expect(engine.currentStepIndex, equals(2));

      // Navigate back to step 0
      engine.currentStepIndex = 0;
      expect(engine.currentStepIndex, equals(0));
      // Progress remains intact
      expect(engine.progressPercentage, equals(20.0));

      // Navigate to step 1
      engine.currentStepIndex = 1;
      expect(engine.currentStepIndex, equals(1));
    });

    test('forward jump beyond uncompleted step raises ArgumentError', () {
      final engine = LessonEngine(lessonId: 'ch01_lesson');
      // Cannot jump to step index 7 (Step 8) when index 0 is not completed
      expect(() => engine.currentStepIndex = 7, throwsArgumentError);
    });

    test('assessment unlocking requires steps 1 to 7 completed', () {
      final engine = LessonEngine(lessonId: 'ch01_lesson');
      expect(engine.canUnlockAssessment(), isFalse);

      for (int i = 0; i < 6; i++) {
        engine.completeCurrentStep();
      }
      expect(engine.canUnlockAssessment(), isFalse);

      // Complete 7th step
      engine.completeCurrentStep();
      expect(engine.canUnlockAssessment(), isTrue);
    });

    test('rejects sequence with fewer or more than 10 steps', () {
      final invalidSteps = List.generate(
        8,
        (i) => DidacticStep(
          index: i + 1,
          title: 'Step ${i + 1}',
          content: 'Content',
        ),
      );
      expect(
        () => LessonEngine(lessonId: 'invalid', initialSteps: invalidSteps),
        throwsArgumentError,
      );
    });

    test('validates step title and content cannot be empty', () {
      expect(
        () => DidacticStep(index: 1, title: '', content: 'Content'),
        throwsArgumentError,
      );
      expect(
        () => DidacticStep(index: 1, title: 'Title', content: '   '),
        throwsArgumentError,
      );
    });

    test('step index out of bounds raises RangeError', () {
      final engine = LessonEngine(lessonId: 'ch01_lesson');
      expect(() => engine.navigateToStepNumber(0), throwsRangeError);
      expect(() => engine.navigateToStepNumber(11), throwsRangeError);
      expect(() => engine.getStep(0), throwsRangeError);
      expect(() => engine.getStep(11), throwsRangeError);
    });

    test('didactic component models serialization round-trip', () {
      const text = AcademicText(content: 'Exposição forense', sectionId: 'sec-01');
      expect(text.toJson()['type'], equals('academic_text'));
      expect(AcademicText.fromJson(text.toJson()).content, equals('Exposição forense'));

      const box = CalloutBox(title: 'Atenção', content: 'Preservar cadeia', variant: CalloutVariant.warning);
      expect(box.toJson()['variant'], equals('warning'));
      expect(CalloutBox.fromJson(box.toJson()).title, equals('Atenção'));

      const table = InteractiveTable(
        headers: ['Método', 'Sensibilidade'],
        rows: [['PCR', 'Alta'], ['ELISA', 'Média']],
        caption: 'Tabela 1',
      );
      expect(InteractiveTable.fromJson(table.toJson()).rows.length, equals(2));

      const formula = Formula(latex: 'H(X) = -\\sum P(x) \\log_2 P(x)', description: 'Entropia');
      expect(Formula.fromJson(formula.toJson()).latex, contains('\\sum'));

      const code = CodeSnippet(code: 'import hashlib', language: 'python');
      expect(CodeSnippet.fromJson(code.toJson()).language, equals('python'));

      const q = ObjectiveQuestion(
        id: 'q1',
        question: 'O que é vestígio?',
        options: ['Material bruto', 'Inferência'],
        correctIndex: 0,
      );
      expect(ObjectiveQuestion.fromJson(q.toJson()).correctIndex, equals(0));

      const assoc = ConceptAssociation(
        id: 'ca1',
        instruction: 'Associe os termos',
        pairs: [ConceptPair(left: 'Indício', right: 'Vestígio com nexo')],
      );
      expect(ConceptAssociation.fromJson(assoc.toJson()).pairs.first.left, equals('Indício'));

      const ordering = EventOrdering(
        id: 'eo1',
        instruction: 'Ordene a cadeia',
        events: ['Fixação', 'Coleta', 'Reconhecimento'],
        correctOrder: [2, 0, 1],
      );
      expect(EventOrdering.fromJson(ordering.toJson()).correctOrder, equals([2, 0, 1]));

      const errorId = ErrorIdentification(
        id: 'ei1',
        textWithErrors: 'O perito alterou a evidência antes do hash.',
        errorIndices: [1],
        corrections: ['nunca deve alterar'],
      );
      expect(ErrorIdentification.fromJson(errorId.toJson()).corrections.first, equals('nunca deve alterar'));

      final ds = DatasetInterpretation(
        id: 'ds1',
        prompt: 'Interprete o log',
        dataset: [{'ip': '192.168.1.1', 'status': 200}],
        columns: ['ip', 'status'],
        questions: [q],
      );
      expect(DatasetInterpretation.fromJson(ds.toJson()).dataset.first['ip'], equals('192.168.1.1'));
    });
  });

  group('Adaptive Study Plan & Spaced Repetition (§17.1)', () {
    test('weekly study target validation (0 < target <= 168h)', () {
      expect(() => AdaptiveStudyPlanner(weeklyTargetHours: 0.0), throwsArgumentError);
      expect(() => AdaptiveStudyPlanner(weeklyTargetHours: -5.0), throwsArgumentError);
      expect(() => AdaptiveStudyPlanner(weeklyTargetHours: 168.1), throwsArgumentError);
      expect(() => AdaptiveStudyPlanner(weeklyTargetHours: 200.0), throwsArgumentError);

      final planner = AdaptiveStudyPlanner(weeklyTargetHours: 13.0);
      expect(planner.weeklyTargetHours, equals(13.0));
      planner.weeklyTargetHours = 20.0;
      expect(planner.weeklyTargetHours, equals(20.0));
    });

    test('study session rejects non-positive duration and future timestamp', () {
      final planner = AdaptiveStudyPlanner();
      final now = DateTime.now();

      expect(
        () => planner.recordStudySession(chapterId: 'ch1', durationSeconds: 0, completedAt: now),
        throwsArgumentError,
      );
      expect(
        () => planner.recordStudySession(chapterId: 'ch1', durationSeconds: -100, completedAt: now),
        throwsArgumentError,
      );

      final futureDate = now.add(const Duration(days: 2));
      expect(
        () => planner.recordStudySession(chapterId: 'ch1', durationSeconds: 3600, completedAt: futureDate),
        throwsArgumentError,
      );
    });

    test('accumulates weekly study hours correctly', () {
      final planner = AdaptiveStudyPlanner(weeklyTargetHours: 13.0);
      final now = DateTime.now().toUtc();
      // Use time within this week in the past
      final refDate = now.subtract(const Duration(hours: 4));

      planner.recordStudySession(chapterId: 'ch01', durationSeconds: 10800, completedAt: refDate); // 3h
      planner.recordStudySession(chapterId: 'ch02', durationSeconds: 10800, completedAt: refDate.add(const Duration(hours: 1))); // 3h

      final accumulated = planner.getWeeklyAccumulatedHours(refDate);
      expect(accumulated, equals(6.0));
      final progressPct = (accumulated / planner.weeklyTargetHours) * 100.0;
      expect(progressPct, closeTo((6.0 / 13.0) * 100.0, 0.01));
    });

    test('spaced repetition interval calculation for passing score', () {
      final base = DateTime(2026, 11, 16, 10, 0);

      // Repetition 0 (first review): +1 day
      final r0 = AdaptiveStudyPlanner.calculateSpacedReviewDate(lastReviewed: base, repetitionCount: 0, score: 0.85);
      expect(r0, equals(base.add(const Duration(days: 1))));

      // Repetition 1: +3 days
      final r1 = AdaptiveStudyPlanner.calculateSpacedReviewDate(lastReviewed: base, repetitionCount: 1, score: 0.85);
      expect(r1, equals(base.add(const Duration(days: 3))));

      // Repetition 2: +7 days
      final r2 = AdaptiveStudyPlanner.calculateSpacedReviewDate(lastReviewed: base, repetitionCount: 2, score: 0.90);
      expect(r2, equals(base.add(const Duration(days: 7))));

      // Repetition 3: +14 days
      final r3 = AdaptiveStudyPlanner.calculateSpacedReviewDate(lastReviewed: base, repetitionCount: 3, score: 0.95);
      expect(r3, equals(base.add(const Duration(days: 14))));

      // Repetition 4+: +30 days
      final r4 = AdaptiveStudyPlanner.calculateSpacedReviewDate(lastReviewed: base, repetitionCount: 4, score: 1.00);
      expect(r4, equals(base.add(const Duration(days: 30))));
    });

    test('failing score (< 0.80) resets review interval to 1 day', () {
      final base = DateTime(2026, 11, 16, 10, 0);
      final rFail = AdaptiveStudyPlanner.calculateSpacedReviewDate(lastReviewed: base, repetitionCount: 3, score: 0.65);
      expect(rFail, equals(base.add(const Duration(days: 1))));
    });

    test('competency gap diagnostics detects competencies below 80%', () {
      final scores = {
        'comp_hashes': 0.95,
        'comp_custodia': 0.85,
        'comp_linguistica': 0.60,
        'comp_triangulacao': 0.70,
      };
      final gaps = AdaptiveStudyPlanner.diagnoseCompetencyGaps(scores);
      expect(gaps.length, equals(2));
      expect(gaps, contains('comp_linguistica'));
      expect(gaps, contains('comp_triangulacao'));
      expect(gaps, isNot(contains('comp_hashes')));
    });

    test('overdue review detection identifies past uncompleted schedules', () {
      final planner = AdaptiveStudyPlanner();
      final now = DateTime(2026, 11, 16, 12, 0);

      planner.addReviewSchedule(
        ReviewScheduleItem(
          id: 'rs1',
          chapterId: 'ch1',
          scheduledDate: DateTime(2026, 11, 14, 10, 0),
          isCompleted: false,
        ),
      );
      planner.addReviewSchedule(
        ReviewScheduleItem(
          id: 'rs2',
          chapterId: 'ch2',
          scheduledDate: DateTime(2026, 11, 18, 10, 0),
          isCompleted: false,
        ),
      );
      planner.addReviewSchedule(
        ReviewScheduleItem(
          id: 'rs3',
          chapterId: 'ch3',
          scheduledDate: DateTime(2026, 11, 10, 10, 0),
          isCompleted: true, // completed -> not overdue
        ),
      );

      final overdue = planner.getOverdueReviews(referenceTime: now);
      expect(overdue.length, equals(1));
      expect(overdue.first.id, equals('rs1'));
    });
  });
}
