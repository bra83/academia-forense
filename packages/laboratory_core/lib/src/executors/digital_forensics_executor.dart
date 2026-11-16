import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Hash calculation result containing authentic SHA-256 and MD5 digests.
class ForensicHashResult {
  final String sha256;
  final String md5;
  final int byteLength;

  const ForensicHashResult({
    required this.sha256,
    required this.md5,
    required this.byteLength,
  });

  Map<String, dynamic> toMap() => {
    'sha256': sha256,
    'md5': md5,
    'byteLength': byteLength,
  };
}

/// Integrity check comparison outcome.
class FileIntegrityResult {
  final bool matches;
  final String algorithm;
  final String expectedHash;
  final String calculatedHash;
  final String? anomalyDescription;

  const FileIntegrityResult({
    required this.matches,
    required this.algorithm,
    required this.expectedHash,
    required this.calculatedHash,
    this.anomalyDescription,
  });
}

/// Recognized magic bytes file signature.
class FileSignatureMatch {
  final String mimeType;
  final String description;
  final String extension;
  final List<int> magicBytes;

  const FileSignatureMatch({
    required this.mimeType,
    required this.description,
    required this.extension,
    required this.magicBytes,
  });
}

/// Parsed log entry.
class LogTimelineEntry {
  final DateTime timestamp;
  final String source;
  final String level;
  final String message;
  final Map<String, dynamic> extra;

  const LogTimelineEntry({
    required this.timestamp,
    required this.source,
    required this.level,
    required this.message,
    this.extra = const {},
  });
}

/// Executor for Perícia Digital practical tasks (§14.1).
class DigitalForensicsExecutor {
  /// Known forensic magic byte signatures.
  static final List<FileSignatureMatch> knownSignatures = [
    FileSignatureMatch(
      mimeType: 'application/pdf',
      description: 'Documento Portable Document Format (PDF)',
      extension: 'pdf',
      magicBytes: [0x25, 0x50, 0x44, 0x46], // %PDF
    ),
    FileSignatureMatch(
      mimeType: 'image/png',
      description: 'Imagem PNG',
      extension: 'png',
      magicBytes: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
    ),
    FileSignatureMatch(
      mimeType: 'image/jpeg',
      description: 'Imagem JPEG',
      extension: 'jpg',
      magicBytes: [0xFF, 0xD8, 0xFF],
    ),
    FileSignatureMatch(
      mimeType: 'application/zip',
      description: 'Arquivo ZIP / Pacote Office OpenXML (DOCX, XLSX)',
      extension: 'zip',
      magicBytes: [0x50, 0x4B, 0x03, 0x04],
    ),
    FileSignatureMatch(
      mimeType: 'application/x-sqlite3',
      description: 'Banco de Dados SQLite 3',
      extension: 'sqlite',
      magicBytes: utf8.encode('SQLite format 3\x00'),
    ),
    FileSignatureMatch(
      mimeType: 'image/gif',
      description: 'Imagem GIF',
      extension: 'gif',
      magicBytes: [0x47, 0x49, 0x46, 0x38], // GIF8
    ),
    FileSignatureMatch(
      mimeType: 'application/x-executable',
      description: 'Binário Executável ELF (Linux)',
      extension: 'elf',
      magicBytes: [0x7F, 0x45, 0x4C, 0x46], // \x7fELF
    ),
  ];

  /// Calculates authentic SHA-256 and MD5 cryptographic hashes using package:crypto.
  static ForensicHashResult calculateHashes(List<int> bytes) {
    final sha256Digest = sha256.convert(bytes).toString();
    final md5Digest = md5.convert(bytes).toString();
    return ForensicHashResult(
      sha256: sha256Digest,
      md5: md5Digest,
      byteLength: bytes.length,
    );
  }

  /// Verifies file integrity by checking calculated digest against expected digest.
  static FileIntegrityResult verifyIntegrity({
    required List<int> bytes,
    required String expectedHash,
    String algorithm = 'SHA-256',
  }) {
    final cleanExpected = expectedHash.trim().toLowerCase();
    final String calculated;

    if (algorithm.toUpperCase() == 'MD5') {
      calculated = md5.convert(bytes).toString();
    } else {
      calculated = sha256.convert(bytes).toString();
    }

    final matches = cleanExpected == calculated;
    return FileIntegrityResult(
      matches: matches,
      algorithm: algorithm,
      expectedHash: cleanExpected,
      calculatedHash: calculated,
      anomalyDescription: matches
          ? null
          : 'Adulteração detectada! Hash calculado ($calculated) diverge do valor custodiado ($cleanExpected).',
    );
  }

  /// Identifies file format from file header magic bytes.
  static FileSignatureMatch? examineMagicBytes(List<int> bytes) {
    for (final sig in knownSignatures) {
      if (bytes.length >= sig.magicBytes.length) {
        var match = true;
        for (var i = 0; i < sig.magicBytes.length; i++) {
          if (bytes[i] != sig.magicBytes[i]) {
            match = false;
            break;
          }
        }
        if (match) return sig;
      }
    }
    return null;
  }

  /// Parses log lines into a chronologically sorted timeline.
  static List<LogTimelineEntry> parseLogTimeline(String logContent) {
    final lines = const LineSplitter().convert(logContent)
        .where((l) => l.trim().isNotEmpty)
        .toList();
    final entries = <LogTimelineEntry>[];

    // Common ISO timestamp regex: 2026-11-16T10:00:00Z or 2026-11-16 10:00:00
    final isoRegex = RegExp(r'^(\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(?:\.\d+)?Z?)\s*(?:\[([^\]]+)\])?\s*(?:([A-Z]+):)?\s*(.*)$');

    for (final line in lines) {
      final match = isoRegex.firstMatch(line.trim());
      if (match != null) {
        final timeStr = match.group(1)!;
        final source = match.group(2) ?? 'SYSTEM';
        final level = match.group(3) ?? 'INFO';
        final message = match.group(4) ?? '';
        final parsedTime = DateTime.tryParse(timeStr) ?? DateTime.now();

        entries.add(
          LogTimelineEntry(
            timestamp: parsedTime,
            source: source,
            level: level,
            message: message,
          ),
        );
      } else {
        // Fallback simple line
        entries.add(
          LogTimelineEntry(
            timestamp: DateTime.now(),
            source: 'UNKNOWN',
            level: 'INFO',
            message: line,
          ),
        );
      }
    }

    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }
}
