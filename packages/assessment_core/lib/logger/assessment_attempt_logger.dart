import 'dart:convert';
import 'package:meta/meta.dart';

/// Immutable Assessment Attempt Record (§2.2, §8.2, §17.1).
@immutable
class AssessmentAttemptRecord {
  const AssessmentAttemptRecord({
    required this.id,
    required this.assessmentId,
    required this.studentId,
    required this.chapterId,
    required this.revision,
    required this.score,
    required this.passed,
    required this.timestamp,
    required this.responsesJson,
    this.feedback,
    this.competencyId,
    this.isFinalized = true,
  });

  final String id;
  final String assessmentId;
  final String studentId;
  final String chapterId;
  final String revision;
  final double score;
  final bool passed;
  final DateTime timestamp;
  final String responsesJson;
  final String? feedback;
  final String? competencyId;
  final bool isFinalized;

  /// Competency is marked mastered only on passing (>= 0.80) (§8.2, §17.1).
  bool get isCompetencyMastered {
    final normalized = score > 1.0 ? score / 100.0 : score;
    return passed && normalized >= 0.80;
  }

  /// Immutability enforcement: attempting to mutate a finalized record raises an error.
  AssessmentAttemptRecord mutateAttempt({
    double? newScore,
    bool? newPassed,
    String? newFeedback,
  }) {
    if (isFinalized) {
      throw StateError(
        "Assessment attempt '$id' is immutable and cannot be updated (§2.2, §8.2).",
      );
    }
    return AssessmentAttemptRecord(
      id: id,
      assessmentId: assessmentId,
      studentId: studentId,
      chapterId: chapterId,
      revision: revision,
      score: newScore ?? score,
      passed: newPassed ?? passed,
      timestamp: timestamp,
      responsesJson: responsesJson,
      feedback: newFeedback ?? feedback,
      competencyId: competencyId,
      isFinalized: isFinalized,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'assessmentId': assessmentId,
        'studentId': studentId,
        'chapterId': chapterId,
        'revision': revision,
        'score': score,
        'passed': passed,
        'timestamp': timestamp.toIso8601String(),
        'responsesJson': responsesJson,
        if (feedback != null) 'feedback': feedback,
        if (competencyId != null) 'competencyId': competencyId,
        'isFinalized': isFinalized,
      };

  factory AssessmentAttemptRecord.fromJson(Map<String, dynamic> json) {
    return AssessmentAttemptRecord(
      id: json['id'] as String? ?? json['attempt_id'] as String? ?? '',
      assessmentId: json['assessmentId'] as String? ?? json['assessment_id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? json['student_id'] as String? ?? 'default_student',
      chapterId: json['chapterId'] as String? ?? json['chapter_id'] as String? ?? '',
      revision: json['revision'] as String? ?? 'REV1',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      passed: json['passed'] is bool ? json['passed'] as bool : (json['passed'] as int? ?? 0) == 1,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : (json['attempted_at'] != null ? DateTime.parse(json['attempted_at'].toString()) : DateTime.now()),
      responsesJson: json['responsesJson'] as String? ?? (json['responses'] != null ? jsonEncode(json['responses']) : '{}'),
      feedback: json['feedback'] as String?,
      competencyId: json['competencyId'] as String? ?? json['competency_id'] as String?,
      isFinalized: json['isFinalized'] as bool? ?? true,
    );
  }
}

/// Logger service for persisting and querying immutable assessment attempts (§17.1).
class AssessmentAttemptLogger {
  AssessmentAttemptLogger();

  final Map<String, AssessmentAttemptRecord> _attempts = {};

  List<AssessmentAttemptRecord> get allAttempts =>
      List.unmodifiable(_attempts.values);

  /// Records a finalized attempt.
  void recordAttempt(AssessmentAttemptRecord attempt) {
    if (_attempts.containsKey(attempt.id)) {
      throw StateError(
        "Attempt '${attempt.id}' already exists and cannot be overwritten (§2.2).",
      );
    }
    _attempts[attempt.id] = attempt;
  }

  /// Attempts to modify an existing attempt, enforcing strict immutability.
  void updateAttempt(String attemptId, {double? newScore}) {
    final existing = _attempts[attemptId];
    if (existing == null) {
      throw ArgumentError("Attempt '$attemptId' not found");
    }
    existing.mutateAttempt(newScore: newScore);
  }

  /// Returns assessment attempts for a given assessment ID.
  List<AssessmentAttemptRecord> getAttemptsForAssessment(String assessmentId) {
    return _attempts.values
        .where((att) => att.assessmentId == assessmentId)
        .toList();
  }

  /// Returns assessment attempts for a given chapter ID.
  List<AssessmentAttemptRecord> getAttemptsForChapter(String chapterId) {
    return _attempts.values
        .where((att) => att.chapterId == chapterId)
        .toList();
  }

  /// Computes student's best score for an assessment.
  double? getBestScore(String assessmentId) {
    final list = getAttemptsForAssessment(assessmentId);
    if (list.isEmpty) return null;
    return list.map((a) => a.score).reduce((a, b) => a > b ? a : b);
  }

  /// Checks if competency is mastered in any attempt.
  bool isCompetencyMastered(String competencyId) {
    return _attempts.values.any(
      (att) => att.competencyId == competencyId && att.isCompetencyMastered,
    );
  }
}
