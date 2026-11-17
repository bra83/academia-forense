/// Types shared by the 26 curated, instructor-authored lessons.
/// The PDFs are supporting source material; these are new didactic explanations.
enum LessonSceneKind {
  process,
  comparison,
  timeline,
  evidence,
  code,
  data,
  statistics,
}

class LessonDeepSection {
  const LessonDeepSection({
    required this.title,
    required this.explanation,
    required this.demonstration,
    required this.practicalQuestion,
  });

  final String title;
  final String explanation;
  final String demonstration;
  final String practicalQuestion;
}

class LessonDeepPlan {
  const LessonDeepPlan({
    required this.kind,
    required this.challenge,
    required this.sections,
    required this.visualLabels,
    required this.visualDetails,
    required this.nextInvestigation,
  });

  final LessonSceneKind kind;
  final String challenge;
  final List<LessonDeepSection> sections;
  final List<String> visualLabels;
  final List<String> visualDetails;
  final String nextInvestigation;
}
