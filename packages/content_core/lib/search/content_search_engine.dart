import 'package:sqlite3/sqlite3.dart';

class SearchHit {
  final String chapterId;
  final String title;
  final String sectionTitle;
  final String snippet;

  const SearchHit({
    required this.chapterId,
    required this.title,
    required this.sectionTitle,
    required this.snippet,
  });
}

/// Offline full-text search engine powered by real SQLite FTS5 (§7.1, §18.3).
class ContentSearchEngine {
  final Database _db;
  bool _isClosed = false;

  ContentSearchEngine({Database? customDb})
      : _db = customDb ?? sqlite3.openInMemory() {
    _initFts();
  }

  void _initFts() {
    _db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS fts_content USING fts5(
        chapter_id UNINDEXED,
        title,
        section_title,
        body_text,
        tokenize = 'unicode61'
      );
    ''');
  }

  /// Indexes a document or chapter section into SQLite FTS5.
  void indexDocument({
    required String chapterId,
    required String title,
    required String sectionTitle,
    required String bodyText,
  }) {
    if (_isClosed) throw StateError('ContentSearchEngine is closed');
    final stmt = _db.prepare(
      'INSERT INTO fts_content (chapter_id, title, section_title, body_text) VALUES (?, ?, ?, ?);',
    );
    try {
      stmt.execute([chapterId, title, sectionTitle, bodyText]);
    } finally {
      stmt.dispose();
    }
  }

  /// Searches the FTS5 index for [query] and returns snippets highlighting matches.
  List<SearchHit> search(String query) {
    if (_isClosed) throw StateError('ContentSearchEngine is closed');
    final cleanQuery = _sanitizeFtsQuery(query);
    if (cleanQuery.isEmpty) return [];

    final hits = <SearchHit>[];
    PreparedStatement? stmt;
    try {
      stmt = _db.prepare(
        'SELECT chapter_id, title, section_title, '
        "snippet(fts_content, 3, '[MATCH]', '[/MATCH]', '...', 10) "
        'FROM fts_content WHERE fts_content MATCH ? ORDER BY rank;',
      );
      final resultSet = stmt.select([cleanQuery]);
      for (final row in resultSet) {
        hits.add(
          SearchHit(
            chapterId: (row['chapter_id'] ?? '').toString(),
            title: (row['title'] ?? '').toString(),
            sectionTitle: (row['section_title'] ?? '').toString(),
            snippet: (row[3] ?? '').toString(),
          ),
        );
      }
    } catch (e) {
      // If query is an unclosed phrase or contains special SQLite FTS syntax errors, return empty list cleanly
      return [];
    } finally {
      stmt?.dispose();
    }
    return hits;
  }

  /// Sanitizes raw user input for safe FTS5 queries while supporting prefix and boolean AND.
  String _sanitizeFtsQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return '';

    // Handle AND queries
    if (trimmed.toUpperCase().contains(' AND ')) {
      final parts = trimmed.split(RegExp(r'\s+AND\s+', caseSensitive: false));
      final cleanParts = parts
          .map((p) => _cleanFtsTerm(p))
          .where((p) => p.isNotEmpty)
          .toList();
      return cleanParts.join(' AND ');
    }

    return _cleanFtsTerm(trimmed);
  }

  String _cleanFtsTerm(String term) {
    var t = term.trim();
    if (t.isEmpty) return '';

    // Support prefix queries ending in '*'
    final hasPrefix = t.endsWith('*');
    if (hasPrefix) {
      t = t.substring(0, t.length - 1);
    }

    // Strip dangerous FTS characters: " ( ) { } [ ] ^ : + -
    t = t.replaceAll(RegExp(r'["\(\)\{\}\[\]\^\:\+\-]'), ' ').trim();
    if (t.isEmpty) return '';

    return hasPrefix ? '$t*' : t;
  }

  /// Closes database connection.
  void close() {
    if (!_isClosed) {
      _db.dispose();
      _isClosed = true;
    }
  }
}
