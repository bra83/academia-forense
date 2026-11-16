import 'package:drift/drift.dart';
import 'curriculum_tables.dart';

/// 21. UserSettings Table (Key-value store for app preferences §17.1)
class UserSettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

/// 23. AIInteraction Table (Strict RAG provenance & 7 tutor modes §9.3, §10.3)
class AIInteractions extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().nullable().references(Chapters, #id)();
  TextColumn get modelId => text()();
  TextColumn get pedagogicalMode => text()(); // explicar, simplificar, aprofundar, exemplificar, meTestar, revisar, orientarLab
  TextColumn get userPrompt => text()();
  TextColumn get contextChunksJson => text()();
  TextColumn get aiResponse => text()();
  TextColumn get citationTags => text()(); // [FONTE: ...] or [INFERENCIA]
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 24. AudioSettings Table (Kokoro Braseiro / Gemini Charon §12.3, §13)
class AudioSettingsEntries extends Table {
  TextColumn get id => text().withDefault(const Constant('default'))();
  TextColumn get preferredEngine => text().withDefault(const Constant('kokoro'))(); // kokoro, geminiTts
  TextColumn get voiceName => text().withDefault(const Constant('Charon'))();
  RealColumn get playbackSpeed => real().withDefault(const Constant(1.0))(); // 0.65 to 1.50
  IntColumn get chunkCharTarget => integer().withDefault(const Constant(450))(); // target 450 chars
  BoolColumn get autoScrollFollowAlong => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
