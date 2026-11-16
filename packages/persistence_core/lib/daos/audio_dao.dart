import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../tables/settings_tables.dart';

part 'audio_dao.g.dart';

@DriftAccessor(tables: [
  AudioSettingsEntries,
])
class AudioDao extends DatabaseAccessor<AppDatabase> with _$AudioDaoMixin {
  AudioDao(super.db);

  static const String _defaultId = 'default';

  Future<AudioSettingsEntry> getAudioSettings() async {
    final existing = await (select(audioSettingsEntries)..where((t) => t.id.equals(_defaultId))).getSingleOrNull();
    if (existing != null) {
      return existing;
    }

    // Default configuration: Kokoro engine, Charon voice, 1.0x speed, 450 chars target
    final defaultEntry = AudioSettingsEntriesCompanion.insert(
      id: const Value(_defaultId),
      preferredEngine: const Value('kokoro'),
      voiceName: const Value('Charon'),
      playbackSpeed: const Value(1.0),
      chunkCharTarget: const Value(450),
      autoScrollFollowAlong: const Value(true),
      updatedAt: Value(DateTime.now()),
    );
    await into(audioSettingsEntries).insert(defaultEntry);
    return (select(audioSettingsEntries)..where((t) => t.id.equals(_defaultId))).getSingle();
  }

  Future<int> updateAudioSettings({
    String? preferredEngine,
    String? voiceName,
    double? playbackSpeed,
    int? chunkCharTarget,
    bool? autoScrollFollowAlong,
  }) {
    return (update(audioSettingsEntries)..where((t) => t.id.equals(_defaultId))).write(
      AudioSettingsEntriesCompanion(
        preferredEngine: preferredEngine != null ? Value(preferredEngine) : const Value.absent(),
        voiceName: voiceName != null ? Value(voiceName) : const Value.absent(),
        playbackSpeed: playbackSpeed != null ? Value(playbackSpeed) : const Value.absent(),
        chunkCharTarget: chunkCharTarget != null ? Value(chunkCharTarget) : const Value.absent(),
        autoScrollFollowAlong: autoScrollFollowAlong != null ? Value(autoScrollFollowAlong) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
