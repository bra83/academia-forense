import 'package:flutter_test/flutter_test.dart';
import 'package:assessment_core/assessment_core.dart';

void main() {
  group('Milestone 3 Adversarial: 80% Passing Benchmark (§8.2, §14)', () {
    test('exact 80.00% passes benchmark and returns APROVADO', () {
      final res = AssessmentEvaluator.evaluateScore(80.00);
      expect(res.passed, isTrue);
      expect(res.status, equals('APROVADO'));
      expect(res.scorePercent, equals(80.0));
      expect(res.score, equals(0.80));
    });

    test('exact 79.99% strictly fails benchmark and returns REPROVADO', () {
      final res = AssessmentEvaluator.evaluateScore(79.99);
      expect(res.passed, isFalse);
      expect(res.status, equals('REPROVADO'));
      expect(res.scorePercent, equals(79.99));
      expect(res.score, equals(0.7999));
    });

    test('normalized 0.8000 passes and 0.7999 fails', () {
      final passNorm = AssessmentEvaluator.evaluateScore(0.80);
      expect(passNorm.passed, isTrue);
      expect(passNorm.status, equals('APROVADO'));

      final failNorm = AssessmentEvaluator.evaluateScore(0.7999);
      expect(failNorm.passed, isFalse);
      expect(failNorm.status, equals('REPROVADO'));
    });

    test('boundary 0.0% fails benchmark', () {
      final res = AssessmentEvaluator.evaluateScore(0.0);
      expect(res.passed, isFalse);
      expect(res.status, equals('REPROVADO'));
      expect(res.scorePercent, equals(0.0));
      expect(res.score, equals(0.0));
    });

    test('boundary 100.0% passes benchmark', () {
      final res = AssessmentEvaluator.evaluateScore(100.0);
      expect(res.passed, isTrue);
      expect(res.status, equals('APROVADO'));
      expect(res.scorePercent, equals(100.0));
      expect(res.score, equals(1.0));
    });

    test('adversarial negative scores (< 0.0) throw ArgumentError', () {
      expect(() => AssessmentEvaluator.evaluateScore(-0.0001), throwsArgumentError);
      expect(() => AssessmentEvaluator.evaluateScore(-1.0), throwsArgumentError);
      expect(() => AssessmentEvaluator.evaluateScore(-50.0), throwsArgumentError);
      expect(() => AssessmentEvaluator.evaluateScore(-100.0), throwsArgumentError);
      expect(() => AssessmentEvaluator.evaluateScore(double.negativeInfinity), throwsArgumentError);
    });

    test('adversarial out-of-bounds scores (> 100.0) throw ArgumentError', () {
      expect(() => AssessmentEvaluator.evaluateScore(100.001), throwsArgumentError);
      expect(() => AssessmentEvaluator.evaluateScore(105.0), throwsArgumentError);
      expect(() => AssessmentEvaluator.evaluateScore(200.0), throwsArgumentError);
      expect(() => AssessmentEvaluator.evaluateScore(double.infinity), throwsArgumentError);
    });

    test('multiple choice question count boundary combinations', () {
      // 4 out of 5 = 80.0% -> PASS
      final pass5 = AssessmentEvaluator.evaluateObjective(
        userAnswers: [1, 2, 3, 4, 0],
        answerKey: [1, 2, 3, 4, 1],
      );
      expect(pass5.passed, isTrue);
      expect(pass5.scorePercent, equals(80.0));

      // 7 out of 10 = 70.0% -> FAIL
      final fail10 = AssessmentEvaluator.evaluateObjective(
        userAnswers: [1, 2, 3, 4, 5, 6, 7, 0, 0, 0],
        answerKey: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );
      expect(fail10.passed, isFalse);
      expect(fail10.scorePercent, equals(70.0));

      // 8 out of 10 = 80.0% -> PASS
      final pass10 = AssessmentEvaluator.evaluateObjective(
        userAnswers: [1, 2, 3, 4, 5, 6, 7, 8, 0, 0],
        answerKey: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );
      expect(pass10.passed, isTrue);
      expect(pass10.scorePercent, equals(80.0));
    });

    test('adversarial objective evaluator empty and length mismatch validations', () {
      expect(
        () => AssessmentEvaluator.evaluateObjective(userAnswers: [], answerKey: []),
        throwsArgumentError,
      );
      expect(
        () => AssessmentEvaluator.evaluateObjective(userAnswers: [1], answerKey: [1, 2]),
        throwsArgumentError,
      );
      expect(
        () => AssessmentEvaluator.evaluateObjective(userAnswers: [1, 2, 3], answerKey: [1]),
        throwsArgumentError,
      );
    });

    test('adversarial rubric evaluation with extreme weight distributions', () {
      final criteriaScores = {'crit1': 1.0, 'crit2': 0.0};
      final criteriaWeights = {'crit1': 0.80, 'crit2': 0.20};
      final res = AssessmentEvaluator.evaluateRubric(
        criteriaScores: criteriaScores,
        criteriaWeights: criteriaWeights,
      );
      // 1.0 * 0.8 + 0.0 * 0.2 = 0.80 -> EXACT PASS
      expect(res.score, closeTo(0.80, 0.0001));
      expect(res.passed, isTrue);

      final failWeights = {'crit1': 0.79, 'crit2': 0.21};
      final resFail = AssessmentEvaluator.evaluateRubric(
        criteriaScores: criteriaScores,
        criteriaWeights: failWeights,
      );
      // 1.0 * 0.79 + 0.0 * 0.21 = 0.79 -> FAIL
      expect(resFail.passed, isFalse);
    });
  });
}
