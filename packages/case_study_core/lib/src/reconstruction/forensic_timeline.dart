/// Source type of a timeline event.
enum TimelineSourceType {
  testimony('Depoimento / Testemunho'),
  systemLog('Registro de Log / Sistema'),
  telephonyCdr('Registro Telefônico / ERB'),
  physicalEvidence('Evidência Física / Câmera'),
  forensicReport('Laudo Pericial Anterior');

  final String label;
  const TimelineSourceType(this.label);
}

/// A forensic event in a multi-source chronological reconstruction (§15.2).
class TimelineEvent {
  final String id;
  final DateTime timestamp;
  final TimelineSourceType sourceType;
  final String sourceIdentifier;
  final String description;
  final String? location;
  final Map<String, dynamic> metadata;

  const TimelineEvent({
    required this.id,
    required this.timestamp,
    required this.sourceType,
    required this.sourceIdentifier,
    required this.description,
    this.location,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'sourceType': sourceType.name,
    'sourceIdentifier': sourceIdentifier,
    'description': description,
    'location': location,
    'metadata': metadata,
  };
}

/// Gap detected in chronological reconstruction.
class TimelineGap {
  final TimelineEvent beforeEvent;
  final TimelineEvent afterEvent;
  final Duration gapDuration;

  const TimelineGap({
    required this.beforeEvent,
    required this.afterEvent,
    required this.gapDuration,
  });
}

/// Reconstruction engine that unifies multi-source evidence into an objective chronological timeline (§15.2).
class ForensicTimelineReconstruction {
  /// Sorts events into strict chronological order.
  static List<TimelineEvent> sortChronologically(List<TimelineEvent> events) {
    final copy = List<TimelineEvent>.from(events);
    copy.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return copy;
  }

  /// Filters events by source type.
  static List<TimelineEvent> filterBySource(List<TimelineEvent> events, TimelineSourceType type) {
    return events.where((e) => e.sourceType == type).toList();
  }

  /// Detects chronological gaps where no logged events occur for longer than maxAllowedGap.
  static List<TimelineGap> detectGaps(List<TimelineEvent> events, Duration maxAllowedGap) {
    final sorted = sortChronologically(events);
    final gaps = <TimelineGap>[];

    for (var i = 0; i < sorted.length - 1; i++) {
      final current = sorted[i];
      final next = sorted[i + 1];
      final diff = next.timestamp.difference(current.timestamp);
      if (diff > maxAllowedGap) {
        gaps.add(
          TimelineGap(
            beforeEvent: current,
            afterEvent: next,
            gapDuration: diff,
          ),
        );
      }
    }

    return gaps;
  }
}
