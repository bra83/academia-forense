import 'dart:convert';
import 'dart:math' as math;

/// Single Call Detail Record (CDR) item.
class CdrRecord {
  final String callId;
  final DateTime timestamp;
  final String callerMsisdn;
  final String calleeMsisdn;
  final int durationSec;
  final String cellTowerId;
  final double? azimuth;
  final double? latitude;
  final double? longitude;

  const CdrRecord({
    required this.callId,
    required this.timestamp,
    required this.callerMsisdn,
    required this.calleeMsisdn,
    required this.durationSec,
    required this.cellTowerId,
    this.azimuth,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() => {
    'call_id': callId,
    'timestamp': timestamp.toIso8601String(),
    'caller_msisdn': callerMsisdn,
    'callee_msisdn': calleeMsisdn,
    'duration_sec': durationSec,
    'cell_tower_id': cellTowerId,
    'azimuth': azimuth,
    'latitude': latitude,
    'longitude': longitude,
  };
}

/// Aggregated statistics per Cell Tower (ERB - Estação Rádio Base).
class ErbTowerSummary {
  final String towerId;
  final int totalHits;
  final int totalDurationSec;
  final double averageDurationSec;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final double? latitude;
  final double? longitude;

  const ErbTowerSummary({
    required this.towerId,
    required this.totalHits,
    required this.totalDurationSec,
    required this.averageDurationSec,
    required this.firstSeen,
    required this.lastSeen,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() => {
    'towerId': towerId,
    'totalHits': totalHits,
    'totalDurationSec': totalDurationSec,
    'averageDurationSec': averageDurationSec,
    'firstSeen': firstSeen.toIso8601String(),
    'lastSeen': lastSeen.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
  };
}

/// Geographic bounding box for location validation.
class GeoBoundingBox {
  final double minLat;
  final double maxLat;
  final double minLon;
  final double maxLon;

  const GeoBoundingBox({
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
  });

  bool contains(double lat, double lon) {
    return lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon;
  }
}

/// Result of geographic validation of CDR records.
class GeoValidationResult {
  final int totalRecords;
  final int validRecords;
  final int outOfBoundsRecords;
  final List<String> anomalyCallIds;

  const GeoValidationResult({
    required this.totalRecords,
    required this.validRecords,
    required this.outOfBoundsRecords,
    required this.anomalyCallIds,
  });
}

/// Executor for Telefonia e Registros de Comunicação practical tasks (§14.1).
class TelephonyExecutor {
  /// Parses synthetic or real CDR CSV data into CdrRecord list.
  static List<CdrRecord> parseCdrCsv(String csvContent) {
    final lines = const LineSplitter().convert(csvContent)
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) return [];

    final headers = lines.first.split(',').map((h) => h.trim().toLowerCase()).toList();
    final records = <CdrRecord>[];

    for (var i = 1; i < lines.length; i++) {
      final cells = lines[i].split(',').map((c) => c.trim()).toList();
      if (cells.length < headers.length) continue;

      final map = <String, String>{};
      for (var j = 0; j < headers.length; j++) {
        map[headers[j]] = cells[j];
      }

      final callId = map['call_id'] ?? 'CALL_$i';
      final timeStr = map['timestamp'] ?? DateTime.now().toIso8601String();
      final timestamp = DateTime.tryParse(timeStr) ?? DateTime.now();
      final caller = map['caller_msisdn'] ?? map['caller'] ?? '';
      final callee = map['callee_msisdn'] ?? map['callee'] ?? '';
      final duration = int.tryParse(map['duration_sec'] ?? map['duration'] ?? '0') ?? 0;
      final tower = map['cell_tower_id'] ?? map['tower_id'] ?? 'UNKNOWN_ERB';
      final azimuth = double.tryParse(map['azimuth'] ?? '');
      final lat = double.tryParse(map['latitude'] ?? map['lat'] ?? '');
      final lon = double.tryParse(map['longitude'] ?? map['lon'] ?? '');

      records.add(
        CdrRecord(
          callId: callId,
          timestamp: timestamp,
          callerMsisdn: caller,
          calleeMsisdn: callee,
          durationSec: duration,
          cellTowerId: tower,
          azimuth: azimuth,
          latitude: lat,
          longitude: lon,
        ),
      );
    }

    records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return records;
  }

  /// Aggregates hits and duration per cell tower (ERB).
  static Map<String, ErbTowerSummary> aggregateErbTowers(List<CdrRecord> records) {
    final grouped = <String, List<CdrRecord>>{};
    for (final r in records) {
      grouped.putIfAbsent(r.cellTowerId, () => []).add(r);
    }

    final result = <String, ErbTowerSummary>{};
    for (final entry in grouped.entries) {
      final towerId = entry.key;
      final towerRecords = entry.value..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final totalHits = towerRecords.length;
      final totalDuration = towerRecords.fold<int>(0, (acc, r) => acc + r.durationSec);
      final avgDuration = totalHits > 0 ? totalDuration / totalHits : 0.0;
      final firstSeen = towerRecords.first.timestamp;
      final lastSeen = towerRecords.last.timestamp;
      final lat = towerRecords.firstWhere((r) => r.latitude != null, orElse: () => towerRecords.first).latitude;
      final lon = towerRecords.firstWhere((r) => r.longitude != null, orElse: () => towerRecords.first).longitude;

      result[towerId] = ErbTowerSummary(
        towerId: towerId,
        totalHits: totalHits,
        totalDurationSec: totalDuration,
        averageDurationSec: avgDuration,
        firstSeen: firstSeen,
        lastSeen: lastSeen,
        latitude: lat,
        longitude: lon,
      );
    }

    return result;
  }

  /// Validates whether CDR geographic coordinates fall within a required bounding box.
  static GeoValidationResult validateGeographicBounds({
    required List<CdrRecord> records,
    required GeoBoundingBox boundingBox,
  }) {
    var valid = 0;
    var outOfBounds = 0;
    final anomalies = <String>[];

    for (final r in records) {
      if (r.latitude != null && r.longitude != null) {
        if (boundingBox.contains(r.latitude!, r.longitude!)) {
          valid++;
        } else {
          outOfBounds++;
          anomalies.add(r.callId);
        }
      } else {
        // Records without coordinates are not marked as out-of-bounds anomaly, or treated as valid
        valid++;
      }
    }

    return GeoValidationResult(
      totalRecords: records.length,
      validRecords: valid,
      outOfBoundsRecords: outOfBounds,
      anomalyCallIds: anomalies,
    );
  }
}
