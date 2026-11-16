import 'package:flutter_test/flutter_test.dart';
import 'package:assessment_core/assessment_core.dart';

void main() {
  group('Assessment Evaluator & 80% Passing Benchmark (§8.2, §14)', () {
    test('exact 80% passing benchmark (4/5 questions = 80%) passes', () {
      final userAns = [1, 2, 3, 0, 9];
      final key = [1, 2, 3, 0, 0];
      final res = AssessmentEvaluator.evaluateObjective(
        userAnswers: userAns,
        answerKey: key,
      );
      expect(res.score, equals(0.80));
      expect(res.scorePercent, equals(80.0));
      expect(res.passed, isTrue);
      expect(res.status, equals('APROVADO'));
    });

    test('score below 80% (3/5 questions = 60%) fails benchmark', () {
      final userAns = [1, 2, 3, 9, 9];
      final key = [1, 2, 3, 0, 0];
      final res = AssessmentEvaluator.evaluateObjective(
        userAnswers: userAns,
        answerKey: key,
      );
      expect(res.score, equals(0.60));
      expect(res.passed, isFalse);
      expect(res.status, equals('REPROVADO'));
    });

    test('perfect score (100%) passes', () {
      final userAns = [0, 1, 2, 3, 4];
      final key = [0, 1, 2, 3, 4];
      final res = AssessmentEvaluator.evaluateObjective(
        userAnswers: userAns,
        answerKey: key,
      );
      expect(res.score, equals(1.00));
      expect(res.scorePercent, equals(100.0));
      expect(res.passed, isTrue);
      expect(res.status, equals('APROVADO'));
    });

    test('strict boundary at 79.99% strictly fails and 80.00% passes', () {
      final resFail = AssessmentEvaluator.evaluateScore(79.99);
      expect(resFail.passed, isFalse);
      expect(resFail.status, equals('REPROVADO'));

      final resPass = AssessmentEvaluator.evaluateScore(80.00);
      expect(resPass.passed, isTrue);
      expect(resPass.status, equals('APROVADO'));
    });

    test('negative or over 100 score rejected with ArgumentError', () {
      expect(() => AssessmentEvaluator.evaluateScore(-0.01), throwsArgumentError);
      expect(() => AssessmentEvaluator.evaluateScore(-50.0), throwsArgumentError);
      expect(() => AssessmentEvaluator.evaluateScore(100.01), throwsArgumentError);
      expect(() => AssessmentEvaluator.evaluateScore(150.0), throwsArgumentError);

      final r0 = AssessmentEvaluator.evaluateScore(0.0);
      expect(r0.passed, isFalse);

      final r100 = AssessmentEvaluator.evaluateScore(100.0);
      expect(r100.passed, isTrue);
    });

    test('zero questions assessment raises ArgumentError', () {
      expect(
        () => AssessmentEvaluator.evaluateObjective(userAnswers: [], answerKey: []),
        throwsArgumentError,
      );
    });

    test('mismatch in answers and key length raises ArgumentError', () {
      expect(
        () => AssessmentEvaluator.evaluateObjective(userAnswers: [1, 2], answerKey: [1]),
        throwsArgumentError,
      );
    });

    test('rubric evaluation weighted score calculation', () {
      final scores = {
        'metodologia': 0.90,
        'cadeia_custodia': 0.85,
        'precisao_tecnica': 0.80,
      };
      final weights = {
        'metodologia': 0.40,
        'cadeia_custodia': 0.30,
        'precisao_tecnica': 0.30,
      };
      final res = AssessmentEvaluator.evaluateRubric(
        criteriaScores: scores,
        criteriaWeights: weights,
      );
      // 0.90 * 0.40 + 0.85 * 0.30 + 0.80 * 0.30 = 0.36 + 0.255 + 0.24 = 0.855
      expect(res.score, closeTo(0.855, 0.001));
      expect(res.passed, isTrue);
      expect(res.status, equals('APROVADO'));
    });

    test('concept association question evaluation', () {
      final student = {0: 1, 1: 0, 2: 2};
      final key = {0: 1, 1: 0, 2: 2};
      final res = AssessmentEvaluator.evaluateConceptAssociation(
        studentMatches: student,
        correctMatches: key,
      );
      expect(res.score, equals(1.0));
      expect(res.passed, isTrue);
    });

    test('chronological ordering evaluation', () {
      final student = [2, 0, 1, 3];
      final key = [2, 0, 1, 3];
      final res = AssessmentEvaluator.evaluateChronologicalOrdering(
        studentSequence: student,
        correctSequence: key,
      );
      expect(res.score, equals(1.0));
      expect(res.passed, isTrue);

      final partial = [2, 1, 0, 3];
      final resPartial = AssessmentEvaluator.evaluateChronologicalOrdering(
        studentSequence: partial,
        correctSequence: key,
      );
      expect(resPartial.score, equals(0.5));
      expect(resPartial.passed, isFalse);
    });

    test('error identification evaluation with precision and recall', () {
      final student = {1, 3};
      final key = {1, 3};
      final res = AssessmentEvaluator.evaluateErrorIdentification(
        studentErrorIndices: student,
        correctErrorIndices: key,
      );
      expect(res.score, equals(1.0));
      expect(res.passed, isTrue);
    });

    test('dataset interpretation value evaluation', () {
      final res = AssessmentEvaluator.evaluateDatasetInterpretation(
        studentAnswer: 7.91,
        expectedAnswer: 7.90,
        tolerance: 0.02,
      );
      expect(res.score, equals(1.0));
      expect(res.passed, isTrue);

      final resFail = AssessmentEvaluator.evaluateDatasetInterpretation(
        studentAnswer: 7.80,
        expectedAnswer: 7.90,
        tolerance: 0.02,
      );
      expect(resFail.score, equals(0.0));
      expect(resFail.passed, isFalse);
    });
  });

  group('Immutable Assessment Attempt Logger (§2.2, §8.2, §17.1)', () {
    test('attempt logging and competency mastery only on pass', () {
      final logger = AssessmentAttemptLogger();
      final attemptPass = AssessmentAttemptRecord(
        id: 'att-101',
        assessmentId: 'asm-ch01',
        studentId: 'student-1',
        chapterId: 'ch01',
        revision: 'REV2',
        score: 0.85,
        passed: true,
        timestamp: DateTime.utc(2026, 11, 16, 11, 0),
        responsesJson: '{"1": 0}',
        competencyId: 'comp-custodia',
      );

      logger.recordAttempt(attemptPass);
      expect(attemptPass.isCompetencyMastered, isTrue);
      expect(logger.isCompetencyMastered('comp-custodia'), isTrue);

      final attemptFail = AssessmentAttemptRecord(
        id: 'att-102',
        assessmentId: 'asm-ch02',
        studentId: 'student-1',
        chapterId: 'ch02',
        revision: 'REV1',
        score: 0.60,
        passed: false,
        timestamp: DateTime.utc(2026, 11, 16, 11, 30),
        responsesJson: '{"1": 1}',
        competencyId: 'comp-hashes',
      );
      logger.recordAttempt(attemptFail);
      expect(attemptFail.isCompetencyMastered, isFalse);
      expect(logger.isCompetencyMastered('comp-hashes'), isFalse);
    });

    test('immutability enforcement prevents mutation of finalized attempt', () {
      final logger = AssessmentAttemptLogger();
      final attempt = AssessmentAttemptRecord(
        id: 'att-locked',
        assessmentId: 'asm-01',
        studentId: 'student-1',
        chapterId: 'ch01',
        revision: 'REV1',
        score: 0.75,
        passed: false,
        timestamp: DateTime.now(),
        responsesJson: '{}',
        isFinalized: true,
      );
      logger.recordAttempt(attempt);

      expect(
        () => logger.updateAttempt('att-locked', newScore: 0.95),
        throwsStateError,
      );
      expect(
        () => attempt.mutateAttempt(newScore: 0.95),
        throwsStateError,
      );
    });

    test('duplicate attempt id recording is rejected', () {
      final logger = AssessmentAttemptLogger();
      final att = AssessmentAttemptRecord(
        id: 'att-dup',
        assessmentId: 'asm-01',
        studentId: 's1',
        chapterId: 'ch1',
        revision: 'REV1',
        score: 0.8,
        passed: true,
        timestamp: DateTime.now(),
        responsesJson: '{}',
      );
      logger.recordAttempt(att);
      expect(() => logger.recordAttempt(att), throwsStateError);
    });
  });
}
