/// Study session entry for tracking learning progress (§17.1).
class StudySessionEntry {
  StudySessionEntry({
    required this.chapterId,
    required this.durationSeconds,
    required this.completedAt,
    this.sessionId,
  }) {
    if (durationSeconds <= 0) {
      throw ArgumentError('Session duration must be positive, got $durationSeconds');
    }
  }

  final String? sessionId;
  final String chapterId;
  final int durationSeconds;
  final DateTime completedAt;

  double get durationHours => durationSeconds / 3600.0;
  double get durationMinutes => durationSeconds / 60.0;

  Map<String, dynamic> toJson() => {
        if (sessionId != null) 'sessionId': sessionId,
        'chapterId': chapterId,
        'durationSeconds': durationSeconds,
        'completedAt': completedAt.toIso8601String(),
      };
}

/// Spaced review schedule recommendation / item (§17.1).
class ReviewScheduleItem {
  ReviewScheduleItem({
    required this.id,
    required this.chapterId,
    required this.scheduledDate,
    this.competencyId,
    this.repetitionIntervalDays = 1,
    this.isCompleted = false,
  });

  final String id;
  final String chapterId;
  final String? competencyId;
  final DateTime scheduledDate;
  final int repetitionIntervalDays;
  bool isCompleted;

  bool isOverdue(DateTime referenceTime) =>
      !isCompleted && referenceTime.isAfter(scheduledDate);
}

/// Adaptive Study Planner & Spaced Repetition Engine (§17.1)
class AdaptiveStudyPlanner {
  AdaptiveStudyPlanner({
    double weeklyTargetHours = DEFAULT_WEEKLY_TARGET_HOURS,
  }) : _weeklyTargetHours = weeklyTargetHours {
    validateWeeklyStudyTarget(weeklyTargetHours);
  }

  static const double DEFAULT_WEEKLY_TARGET_HOURS = 13.0;
  static const double MAX_WEEKLY_HOURS = 168.0;

  double _weeklyTargetHours;
  final List<StudySessionEntry> _sessions = [];
  final List<ReviewScheduleItem> _reviewSchedules = [];

  double get weeklyTargetHours => _weeklyTargetHours;

  set weeklyTargetHours(double hours) {
    validateWeeklyStudyTarget(hours);
    _weeklyTargetHours = hours;
  }

  List<StudySessionEntry> get sessions => List.unmodifiable(_sessions);
  List<ReviewScheduleItem> get reviewSchedules => List.unmodifiable(_reviewSchedules);

  /// Validates weekly target hours strictly: 0 < target <= 168.0 hours.
  static void validateWeeklyStudyTarget(double target) {
    if (target <= 0.0) {
      throw ArgumentError('Weekly study target must be greater than 0, got $target');
    }
    if (target > MAX_WEEKLY_HOURS) {
      throw ArgumentError(
        'Weekly study target cannot exceed total hours in a week ($MAX_WEEKLY_HOURS), got $target',
      );
    }
  }

  /// Records study session with validation against negative durations and future timestamps (§17.1).
  void recordStudySession({
    required String chapterId,
    required int durationSeconds,
    required DateTime completedAt,
    String? sessionId,
  }) {
    if (durationSeconds <= 0) {
      throw ArgumentError('Session duration must be positive, got $durationSeconds');
    }

    // Check future timestamp (> 5 minutes into the future)
    final nowUtc = DateTime.now().toUtc();
    final completedUtc = completedAt.toUtc();
    if (completedUtc.isAfter(nowUtc.add(const Duration(minutes: 5)))) {
      throw ArgumentError(
        'Session timestamp ${completedAt.toIso8601String()} cannot be in the future',
      );
    }

    _sessions.add(
      StudySessionEntry(
        chapterId: chapterId,
        durationSeconds: durationSeconds,
        completedAt: completedAt,
        sessionId: sessionId,
      ),
    );
  }

  /// Calculates accumulated study hours for the calendar week (Monday 00:00 to Sunday 23:59:59) of referenceDate.
  double getWeeklyAccumulatedHours(DateTime referenceDate) {
    final ref = referenceDate.toUtc();
    // In Dart DateTime.weekday: Monday = 1, Sunday = 7
    final daysSinceMonday = ref.weekday - 1;
    final startOfWeek = DateTime.utc(ref.year, ref.month, ref.day)
        .subtract(Duration(days: daysSinceMonday));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    int totalSeconds = 0;
    for (final s in _sessions) {
      final sessionTime = s.completedAt.toUtc();
      if ((sessionTime.isAtSameMomentAs(startOfWeek) || sessionTime.isAfter(startOfWeek)) &&
          sessionTime.isBefore(endOfWeek)) {
        totalSeconds += s.durationSeconds;
      }
    }
    return totalSeconds / 3600.0;
  }

  /// Spaced repetition review date calculator (§17.1).
  /// Passing benchmark is 0.80 (or 80.0 on 100-point scale).
  /// Intervals: 1, 3, 7, 14, 30 days. Failing score triggers 1-day immediate review.
  static DateTime calculateSpacedReviewDate({
    required DateTime lastReviewed,
    required int repetitionCount,
    required double score,
  }) {
    final normalizedScore = score > 1.0 ? score / 100.0 : score;

    if (normalizedScore < 0.80) {
      // Failing score triggers immediate review next day
      return lastReviewed.add(const Duration(days: 1));
    }

    // Standard intervals: 1 -> 3 -> 7 -> 14 -> 30 days
    const intervals = [1, 3, 7, 14, 30];
    final safeIndex = repetitionCount < 0 ? 0 : repetitionCount;
    final intervalIdx = safeIndex >= intervals.length ? intervals.length - 1 : safeIndex;
    final days = intervals[intervalIdx];

    if (days <= 0) {
      throw ArgumentError('Review interval must be at least 1 day, got $days');
    }

    return lastReviewed.add(Duration(days: days));
  }

  /// Identifies competency gaps where score < 80% passing benchmark (§8.2, §17.1).
  static List<String> diagnoseCompetencyGaps(Map<String, double> competencyScores) {
    final gaps = <String>[];
    for (final entry in competencyScores.entries) {
      final score = entry.value > 1.0 ? entry.value / 100.0 : entry.value;
      if (score < 0.80) {
        gaps.add(entry.key);
      }
    }
    return gaps;
  }

  /// Detects overdue reviews where scheduledDate is before referenceTime and not completed.
  List<ReviewScheduleItem> getOverdueReviews({DateTime? referenceTime}) {
    final now = referenceTime ?? DateTime.now();
    return _reviewSchedules.where((item) => item.isOverdue(now)).toList();
  }

  void addReviewSchedule(ReviewScheduleItem item) {
    if (item.repetitionIntervalDays <= 0) {
      throw ArgumentError(
        'Review interval must be at least 1 day, got ${item.repetitionIntervalDays}',
      );
    }
    _reviewSchedules.add(item);
  }
}
