import 'package:flutter_test/flutter_test.dart';
import 'package:laboratory_core/laboratory_core.dart';

void main() {
  group('Adversarial Challenge: Android 32MB Memory Limit & Platform Isolation', () {
    const int exact32MB = 32 * 1024 * 1024; // 33,554,432 bytes
    const int byteOver32MB = exact32MB + 1;  // 33,554,433 bytes
    const int byteUnder32MB = exact32MB - 1; // 33,554,431 bytes

    test('Exact boundary verification: 33,554,432 bytes is accepted on Android', () {
      final decision = PlatformLabRunner.canRunOnPlatform(
        platform: 'android',
        payloadSizeBytes: exact32MB,
        requiresPandas: false,
      );

      expect(decision.canRun, isTrue,
          reason: 'Exact 32MB (33,554,432 bytes) must be permitted on Android');
      expect(decision.reason, contains('Execução autorizada no Android'));
    });

    test('Exact boundary verification: 32MB + 1 byte (33,554,433 bytes) is rejected on Android', () {
      final decision = PlatformLabRunner.canRunOnPlatform(
        platform: 'android',
        payloadSizeBytes: byteOver32MB,
        requiresPandas: false,
      );

      expect(decision.canRun, isFalse,
          reason: '32MB + 1 byte (33,554,433 bytes) must be rejected on Android');
      expect(decision.reason, contains('33554433 B'));
      expect(decision.reason, contains('excede o orçamento de 32MB do Android'));
    });

    test('Boundary verification: 32MB - 1 byte (33,554,431 bytes) is accepted on Android', () {
      final decision = PlatformLabRunner.canRunOnPlatform(
        platform: 'android',
        payloadSizeBytes: byteUnder32MB,
        requiresPandas: false,
      );

      expect(decision.canRun, isTrue);
      expect(decision.reason, contains('Execução autorizada no Android'));
    });

    test('Extreme workload: 1GB and 100GB are rejected on Android', () {
      final decision1GB = PlatformLabRunner.canRunOnPlatform(
        platform: 'android',
        payloadSizeBytes: 1024 * 1024 * 1024,
      );
      expect(decision1GB.canRun, isFalse);
      expect(decision1GB.reason, contains('excede o orçamento de 32MB'));

      final decision100GB = PlatformLabRunner.canRunOnPlatform(
        platform: 'android',
        payloadSizeBytes: 100 * 1024 * 1024 * 1024,
      );
      expect(decision100GB.canRun, isFalse);
      expect(decision100GB.reason, contains('excede o orçamento de 32MB'));
    });

    test('Python/Pandas execution is strictly blocked on Android with specific message', () {
      final decision = PlatformLabRunner.canRunOnPlatform(
        platform: 'android',
        payloadSizeBytes: 1024, // Well below 32MB
        requiresPandas: true,
      );

      expect(decision.canRun, isFalse,
          reason: 'Python/Pandas must be blocked on Android regardless of payload size');
      expect(
        decision.reason,
        equals('Laboratório requer ambiente Python/Pandas completo disponível no Windows'),
      );
    });

    test('Python/Pandas is authorized on Windows even with payloads exceeding Android 32MB budget', () {
      final decision = PlatformLabRunner.canRunOnPlatform(
        platform: 'windows',
        payloadSizeBytes: 64 * 1024 * 1024, // 64MB > 32MB Android limit
        requiresPandas: true,
      );

      expect(decision.canRun, isTrue);
      expect(decision.reason, equals('Execução autorizada no Windows'));
    });

    test('Platform string normalization handles mixed casing and whitespace', () {
      final casings = ['Android', 'ANDROID', ' android ', '  Android\t'];
      for (final platformName in casings) {
        final decision = PlatformLabRunner.canRunOnPlatform(
          platform: platformName,
          payloadSizeBytes: exact32MB,
        );
        expect(decision.canRun, isTrue, reason: 'Failed for platform string "$platformName"');

        final overDecision = PlatformLabRunner.canRunOnPlatform(
          platform: platformName,
          payloadSizeBytes: byteOver32MB,
        );
        expect(overDecision.canRun, isFalse, reason: 'Failed for platform string "$platformName"');
      }
    });

    test('Corrupt and empty inputs to executors are handled gracefully without uncaught exceptions', () {
      // Empty input to digital forensics
      final emptyHashes = DigitalForensicsExecutor.calculateHashes([]);
      expect(emptyHashes.sha256, equals('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'));
      expect(emptyHashes.md5, equals('d41d8cd98f00b204e9800998ecf8427e'));

      // Empty logs to timeline parser
      final emptyTimeline = DigitalForensicsExecutor.parseLogTimeline('');
      expect(emptyTimeline, isEmpty);

      // Corrupt magic bytes
      final unknownMagic = DigitalForensicsExecutor.examineMagicBytes([0x00, 0x11, 0x22, 0x33]);
      expect(unknownMagic, isNull);

      // Empty CDR CSV
      final emptyCdr = TelephonyExecutor.parseCdrCsv('');
      expect(emptyCdr, isEmpty);

      // Empty linguistics transcript
      final emptyTranscript = LinguisticsExecutor.parseTranscript('');
      expect(emptyTranscript, isEmpty);
    });
  });
}
