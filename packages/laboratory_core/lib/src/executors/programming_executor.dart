import 'dart:convert';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Summary statistics for an Exploratory Data Analysis (EDA) column.
class ColumnSummary {
  final String columnName;
  final String inferredType;
  final int totalCount;
  final int nullCount;
  final int distinctCount;
  final double? numericMean;
  final double? numericMin;
  final double? numericMax;

  const ColumnSummary({
    required this.columnName,
    required this.inferredType,
    required this.totalCount,
    required this.nullCount,
    required this.distinctCount,
    this.numericMean,
    this.numericMin,
    this.numericMax,
  });

  Map<String, dynamic> toMap() => {
    'columnName': columnName,
    'inferredType': inferredType,
    'totalCount': totalCount,
    'nullCount': nullCount,
    'distinctCount': distinctCount,
    'numericMean': numericMean,
    'numericMin': numericMin,
    'numericMax': numericMax,
  };
}

/// Comprehensive EDA summary of a tabular dataset.
class EdaDatasetSummary {
  final int rowCount;
  final int columnCount;
  final List<String> columnNames;
  final List<ColumnSummary> columns;

  const EdaDatasetSummary({
    required this.rowCount,
    required this.columnCount,
    required this.columnNames,
    required this.columns,
  });

  Map<String, dynamic> toMap() => {
    'rowCount': rowCount,
    'columnCount': columnCount,
    'columnNames': columnNames,
    'columns': columns.map((c) => c.toMap()).toList(),
  };
}

/// Query result bundle from SQLite execution.
class SqliteQueryResult {
  final List<String> columnNames;
  final List<List<dynamic>> rows;
  final int rowsAffected;

  const SqliteQueryResult({
    required this.columnNames,
    required this.rows,
    required this.rowsAffected,
  });
}

/// Executor for Programação e Análise de Dados Forense practical tasks (§14.1).
class ProgrammingExecutor {
  /// Parses CSV text into a list of row maps.
  static List<Map<String, dynamic>> parseCsv(String csvContent, {String delimiter = ','}) {
    final lines = const LineSplitter().convert(csvContent)
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) return [];

    final headers = _splitCsvLine(lines.first, delimiter);
    final results = <Map<String, dynamic>>[];

    for (var i = 1; i < lines.length; i++) {
      final cells = _splitCsvLine(lines[i], delimiter);
      final rowMap = <String, dynamic>{};
      for (var j = 0; j < headers.length; j++) {
        final val = j < cells.length ? cells[j] : null;
        rowMap[headers[j]] = _inferScalar(val);
      }
      results.add(rowMap);
    }
    return results;
  }

  /// Parses JSON content into structured Dart objects.
  static dynamic parseJson(String jsonContent) {
    return jsonDecode(jsonContent);
  }

  /// Generates exploratory data analysis summary for a list of tabular maps.
  static EdaDatasetSummary summarizeDataset(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const EdaDatasetSummary(
        rowCount: 0,
        columnCount: 0,
        columnNames: [],
        columns: [],
      );
    }

    final columnNames = data.first.keys.toList();
    final summaries = <ColumnSummary>[];

    for (final col in columnNames) {
      final values = data.map((r) => r[col]).toList();
      final nonNullValues = values.where((v) => v != null && v != '').toList();
      final nullCount = values.length - nonNullValues.length;
      final distinctValues = nonNullValues.toSet();

      // Check numeric
      final numericValues = nonNullValues
          .map((v) => v is num ? v.toDouble() : double.tryParse(v.toString()))
          .whereType<double>()
          .toList();

      final isNumeric = numericValues.length == nonNullValues.length && nonNullValues.isNotEmpty;
      final String inferredType;
      double? mean;
      double? min;
      double? max;

      if (isNumeric) {
        inferredType = 'NUMERIC';
        min = numericValues.reduce((a, b) => a < b ? a : b);
        max = numericValues.reduce((a, b) => a > b ? a : b);
        mean = numericValues.reduce((a, b) => a + b) / numericValues.length;
      } else {
        inferredType = 'TEXT';
      }

      summaries.add(
        ColumnSummary(
          columnName: col,
          inferredType: inferredType,
          totalCount: values.length,
          nullCount: nullCount,
          distinctCount: distinctValues.length,
          numericMean: mean,
          numericMin: min,
          numericMax: max,
        ),
      );
    }

    return EdaDatasetSummary(
      rowCount: data.length,
      columnCount: columnNames.length,
      columnNames: columnNames,
      columns: summaries,
    );
  }

  /// Executes analytical SQL queries on an in-memory SQLite database or provided database.
  static SqliteQueryResult executeSql({
    required String query,
    sqlite.Database? existingDb,
    List<String>? setupStatements,
  }) {
    final db = existingDb ?? sqlite.sqlite3.openInMemory();
    final shouldClose = existingDb == null;

    try {
      if (setupStatements != null) {
        for (final stmt in setupStatements) {
          db.execute(stmt);
        }
      }

      final trimmedQuery = query.trim().toUpperCase();
      if (trimmedQuery.startsWith('SELECT') || trimmedQuery.startsWith('PRAGMA') || trimmedQuery.startsWith('EXPLAIN')) {
        final resultSet = db.select(query);
        final rows = resultSet.rows.map((r) => List<dynamic>.from(r)).toList();
        return SqliteQueryResult(
          columnNames: resultSet.columnNames,
          rows: rows,
          rowsAffected: rows.length,
        );
      } else {
        db.execute(query);
        return SqliteQueryResult(
          columnNames: [],
          rows: [],
          rowsAffected: db.updatedRows,
        );
      }
    } finally {
      if (shouldClose) {
        db.dispose();
      }
    }
  }

  static List<String> _splitCsvLine(String line, String delimiter) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++; // skip escaped quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == delimiter && !inQuotes) {
        result.add(current.toString().trim());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString().trim());
    return result;
  }

  static dynamic _inferScalar(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final intVal = int.tryParse(raw);
    if (intVal != null) return intVal;
    final doubleVal = double.tryParse(raw);
    if (doubleVal != null) return doubleVal;
    if (raw.toLowerCase() == 'true') return true;
    if (raw.toLowerCase() == 'false') return false;
    return raw;
  }
}
