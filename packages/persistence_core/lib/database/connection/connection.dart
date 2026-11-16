import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Database Connection Factory supporting in-memory tests and persistent disk storage
class DatabaseConnectionFactory {
  DatabaseConnectionFactory._();

  /// Creates an in-memory SQLite database connection for unit and integration testing.
  static QueryExecutor inMemory({bool logStatements = false}) {
    return NativeDatabase.memory(
      logStatements: logStatements,
      setup: (rawDb) {
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  /// Creates a persistent disk SQLite database connection in the application documents directory.
  static LazyDatabase onDisk({
    String databaseName = 'academia_forense.sqlite',
    bool logStatements = false,
  }) {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, databaseName));
      return NativeDatabase.createInBackground(
        file,
        logStatements: logStatements,
        setup: (rawDb) {
          rawDb.execute('PRAGMA foreign_keys = ON;');
          rawDb.execute('PRAGMA journal_mode = WAL;');
        },
      );
    });
  }

  /// Creates a custom file-based SQLite database connection at specified absolute path.
  static QueryExecutor atFile(File file, {bool logStatements = false}) {
    return NativeDatabase(
      file,
      logStatements: logStatements,
      setup: (rawDb) {
        rawDb.execute('PRAGMA foreign_keys = ON;');
        rawDb.execute('PRAGMA journal_mode = WAL;');
      },
    );
  }
}
