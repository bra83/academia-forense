import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:laboratory_core/laboratory_core.dart';

void main() {
  group('LabDomain Enum (§14.1)', () {
    test('Contains exactly 7 multi-disciplinary domains with exact §14.1 values', () {
      expect(LabDomain.values.length, equals(7));
      final values = LabDomain.values.map((d) => d.value).toSet();
      final expected = {
        'Informatica',
        'Matematica',
        'Programacao',
        'PericiaDigital',
        'Telefonia',
        'LinguisticaForense',
        'Multimidia',
      };
      expect(values, equals(expected));
    });

    test('fromValue and tryFromValue resolve case-insensitively', () {
      expect(LabDomain.fromValue('periciadigital'), equals(LabDomain.digitalForensics));
      expect(LabDomain.fromValue('Telefonia'), equals(LabDomain.telephony));
      expect(LabDomain.tryFromValue('Invalido'), isNull);
    });
  });

  group('InformaticsExecutor (§14.1)', () {
    test('POSIX permissions octal parsing and rwx formatting', () {
      final p755 = InformaticsExecutor.parsePermissions('755');
      expect(p755.rwxString, equals('-rwxr-xr-x'));
      expect(p755.userRead && p755.userWrite && p755.userExecute, isTrue);
      expect(p755.groupRead && !p755.groupWrite && p755.groupExecute, isTrue);
      expect(p755.otherRead && !p755.otherWrite && p755.otherExecute, isTrue);

      final p644 = InformaticsExecutor.parsePermissions(420); // 0644 octal = 420 decimal
      expect(p644.rwxString, equals('-rw-r--r--'));
      expect(p644.userWrite, isTrue);
      expect(p644.groupWrite, isFalse);
    });

    test('Directory tree traversal DFS order and string formatting', () {
      final tree = FileTreeNode(
        path: '/var/log',
        name: 'log',
        isDirectory: true,
        children: [
          FileTreeNode(path: '/var/log/auth.log', name: 'auth.log', isDirectory: false, sizeBytes: 1024),
          FileTreeNode(
            path: '/var/log/nginx',
            name: 'nginx',
            isDirectory: true,
            children: [
              FileTreeNode(path: '/var/log/nginx/access.log', name: 'access.log', isDirectory: false, sizeBytes: 2048),
            ],
          ),
        ],
      );

      final paths = InformaticsExecutor.traverseTree(tree);
      expect(paths.length, equals(4));
      expect(paths.first, equals('/var/log'));
      expect(paths.contains('/var/log/nginx/access.log'), isTrue);

      final formatted = InformaticsExecutor.formatTree(tree);
      expect(formatted.contains('📁 log'), isTrue);
      expect(formatted.contains('📄 auth.log'), isTrue);
    });

    test('Shell CLI command line parser extracts executable, flags, args, pipes', () {
      const cmd = 'grep -rn --max-count=10 "ERROR" /var/log/syslog | sort | uniq -c';
      final parsed = InformaticsExecutor.parseCommand(cmd);
      expect(parsed.executable, equals('grep'));
      expect(parsed.flags['rn'], equals('true'));
      expect(parsed.flags['max-count'], equals('10'));
      expect(parsed.arguments.contains('/var/log/syslog'), isTrue);
      expect(parsed.hasPipe, isTrue);
      expect(parsed.pipeStages.length, equals(3));
    });
  });

  group('MathematicsExecutor (§14.1)', () {
    test('Arithmetic operations', () {
      expect(MathematicsExecutor.calculate(10, '+', 5), equals(15));
      expect(MathematicsExecutor.calculate(10, '-', 4), equals(6));
      expect(MathematicsExecutor.calculate(3, '*', 7), equals(21));
      expect(MathematicsExecutor.calculate(20, '/', 4), equals(5));
      expect(MathematicsExecutor.calculate(2, '^', 8), equals(256));
    });

    test('Descriptive statistics (mean, variance, std dev, median)', () {
      final data = [10.0, 12.0, 23.0, 23.0, 16.0, 23.0, 21.0, 16.0];
      final stats = MathematicsExecutor.calculateDescriptiveStatistics(data);
      expect(stats.count, equals(8));
      expect(stats.mean, equals(18.0));
      expect(stats.min, equals(10.0));
      expect(stats.max, equals(23.0));
      expect(stats.variance, closeTo(27.428, 0.01));
      expect(stats.standardDeviation, closeTo(5.237, 0.01));
    });

    test('Bayesian posterior probability calculation: P(H|E)', () {
      // Prior = 1% (0.01), Sensitivity = 99% (0.99), Specificity = 95% (0.95)
      // P(E) = (0.99 * 0.01) + (0.05 * 0.99) = 0.0099 + 0.0495 = 0.0594
      // P(H|E) = 0.0099 / 0.0594 ≈ 0.166666...
      final result = MathematicsExecutor.computeBayesianProbability(
        prior: 0.01,
        sensitivity: 0.99,
        specificity: 0.95,
      );
      expect(result.probabilityEvidence, closeTo(0.0594, 0.0001));
      expect(result.posterior, closeTo(0.1667, 0.001));
    });
  });

  group('ProgrammingExecutor (§14.1)', () {
    test('CSV and JSON parsing', () {
      const csvData = '''id,name,value
1,Evidencia A,45.5
2,Evidencia B,90.0''';
      final rows = ProgrammingExecutor.parseCsv(csvData);
      expect(rows.length, equals(2));
      expect(rows[0]['id'], equals(1));
      expect(rows[0]['name'], equals('Evidencia A'));
      expect(rows[0]['value'], equals(45.5));

      const jsonData = '{"case_id": "CASO-2026", "priority": 1}';
      final jsonMap = ProgrammingExecutor.parseJson(jsonData) as Map<String, dynamic>;
      expect(jsonMap['case_id'], equals('CASO-2026'));
      expect(jsonMap['priority'], equals(1));
    });

    test('EDA dataset summary generation', () {
      final dataset = [
        {'item': 'Disco1', 'capacity_gb': 500.0, 'status': 'OK'},
        {'item': 'Disco2', 'capacity_gb': 1000.0, 'status': 'CORRUPT'},
        {'item': 'Disco3', 'capacity_gb': 250.0, 'status': 'OK'},
      ];
      final eda = ProgrammingExecutor.summarizeDataset(dataset);
      expect(eda.rowCount, equals(3));
      expect(eda.columnCount, equals(3));

      final capCol = eda.columns.firstWhere((c) => c.columnName == 'capacity_gb');
      expect(capCol.inferredType, equals('NUMERIC'));
      expect(capCol.numericMean, closeTo(583.33, 0.1));
      expect(capCol.numericMin, equals(250.0));
      expect(capCol.numericMax, equals(1000.0));
    });

    test('Analytical SQL query execution on SQLite', () {
      final res = ProgrammingExecutor.executeSql(
        setupStatements: [
          'CREATE TABLE access_logs (ip TEXT, status INTEGER);',
          "INSERT INTO access_logs VALUES ('10.0.0.1', 200), ('10.0.0.1', 200), ('192.168.1.1', 200);",
        ],
        query: "SELECT ip, COUNT(*) AS cnt FROM access_logs WHERE status = 200 GROUP BY ip ORDER BY cnt DESC;",
      );

      expect(res.columnNames, equals(['ip', 'cnt']));
      expect(res.rows.length, equals(2));
      expect(res.rows[0][0], equals('10.0.0.1'));
      expect(res.rows[0][1], equals(2));
    });
  });

  group('DigitalForensicsExecutor (§14.1)', () {
    test('Authentic SHA-256 and MD5 hashing and integrity verification', () {
      final payload = utf8.encode('DISK_FORENSIC_IMAGE_SECTOR_2026');
      final hashes = DigitalForensicsExecutor.calculateHashes(payload);

      expect(hashes.sha256, equals(sha256.convert(payload).toString()));
      expect(hashes.md5, equals(md5.convert(payload).toString()));
      expect(hashes.sha256.length, equals(64));
      expect(hashes.md5.length, equals(32));

      final goodIntegrity = DigitalForensicsExecutor.verifyIntegrity(
        bytes: payload,
        expectedHash: hashes.sha256,
      );
      expect(goodIntegrity.matches, isTrue);
      expect(goodIntegrity.anomalyDescription, isNull);

      final badIntegrity = DigitalForensicsExecutor.verifyIntegrity(
        bytes: payload,
        expectedHash: '0000000000000000000000000000000000000000000000000000000000000000',
      );
      expect(badIntegrity.matches, isFalse);
      expect(badIntegrity.anomalyDescription, contains('Adulteração detectada'));
    });

    test('Magic bytes file signature identification', () {
      final pdfBytes = utf8.encode('%PDF-1.4\n1 0 obj\n<<>>\nendobj\n');
      final match = DigitalForensicsExecutor.examineMagicBytes(pdfBytes);
      expect(match, isNotNull);
      expect(match!.mimeType, equals('application/pdf'));

      final pngBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00]);
      final matchPng = DigitalForensicsExecutor.examineMagicBytes(pngBytes);
      expect(matchPng, isNotNull);
      expect(matchPng!.extension, equals('png'));
    });

    test('Log timeline chronological parsing', () {
      const logs = '''2026-11-16T12:00:00Z [SSHD] INFO: Login success from 192.168.1.50
2026-11-16T10:00:00Z [KERNEL] WARNING: Disk I/O degraded
2026-11-16T11:30:00Z [AUTH] ERROR: Password authentication failed for user admin''';

      final timeline = DigitalForensicsExecutor.parseLogTimeline(logs);
      expect(timeline.length, equals(3));
      expect(timeline[0].source, equals('KERNEL'));
      expect(timeline[1].source, equals('AUTH'));
      expect(timeline[2].source, equals('SSHD'));
    });
  });

  group('TelephonyExecutor (§14.1)', () {
    test('Synthetic CDR CSV parsing, ERB tower hit aggregation and duration', () {
      const cdrCsv = '''call_id,timestamp,caller_msisdn,callee_msisdn,duration_sec,cell_tower_id,latitude,longitude
C1,2026-11-16T10:00:00Z,+5531988880001,+5531977770002,120,ERB_BH_CENTRO_1,-19.92,-43.94
C2,2026-11-16T10:30:00Z,+5531988880001,+5531966660003,60,ERB_BH_SAVASSI_2,-19.93,-43.93
C3,2026-11-16T11:00:00Z,+5531988880001,+5531955550004,180,ERB_BH_CENTRO_1,-19.92,-43.94''';

      final records = TelephonyExecutor.parseCdrCsv(cdrCsv);
      expect(records.length, equals(3));

      final towers = TelephonyExecutor.aggregateErbTowers(records);
      expect(towers.containsKey('ERB_BH_CENTRO_1'), isTrue);
      expect(towers['ERB_BH_CENTRO_1']!.totalHits, equals(2));
      expect(towers['ERB_BH_CENTRO_1']!.totalDurationSec, equals(300));
      expect(towers['ERB_BH_SAVASSI_2']!.totalHits, equals(1));
    });

    test('Geographic bounding box validation identifies out-of-boundary hits', () {
      final records = [
        CdrRecord(
          callId: 'C1',
          timestamp: DateTime(2026, 11, 16, 10, 0),
          callerMsisdn: '1',
          calleeMsisdn: '2',
          durationSec: 10,
          cellTowerId: 'T1',
          latitude: -19.92,
          longitude: -43.94,
        ),
        CdrRecord(
          callId: 'C_OUT',
          timestamp: DateTime(2026, 11, 16, 10, 5),
          callerMsisdn: '1',
          calleeMsisdn: '2',
          durationSec: 10,
          cellTowerId: 'T2',
          latitude: -23.55, // São Paulo
          longitude: -46.63,
        ),
      ];

      const bhBox = GeoBoundingBox(
        minLat: -20.05,
        maxLat: -19.75,
        minLon: -44.10,
        maxLon: -43.80,
      );

      final val = TelephonyExecutor.validateGeographicBounds(
        records: records,
        boundingBox: bhBox,
      );
      expect(val.validRecords, equals(1));
      expect(val.outOfBoundsRecords, equals(1));
      expect(val.anomalyCallIds, equals(['C_OUT']));
    });
  });

  group('LinguisticsExecutor (§14.1)', () {
    test('Transcript turn parser and lexical marker analysis', () {
      const transcript = '''[10:00:00] DELEGADO: Onde o senhor estava na data dos fatos?
[10:00:05] INVESTIGADO: Olha, com certeza eu acho que estive no local, quer dizer, talvez não.''';

      final utterances = LinguisticsExecutor.parseTranscript(transcript);
      expect(utterances.length, equals(2));
      expect(utterances[0].speaker, equals('DELEGADO'));
      expect(utterances[1].speaker, equals('INVESTIGADO'));

      final markers = LinguisticsExecutor.analyzeLexicalMarkers(utterances[1].text);
      expect(markers.any((m) => m.category == 'certainty' && m.token == 'com certeza'), isTrue);
      expect(markers.any((m) => m.category == 'hedging' && m.token == 'acho que'), isTrue);
      expect(markers.any((m) => m.category == 'hesitation' && m.token == 'quer dizer'), isTrue);
    });

    test('Corpus frequencies and contradiction identification', () {
      const text = 'perícia digital computação forense evidência cadeia custódia perícia';
      final stats = LinguisticsExecutor.calculateCorpusFrequencies(text);
      expect(stats.totalTokens, equals(8));
      expect(stats.frequencies['perícia'], equals(2));

      final utterances = [
        const TranscriptUtterance(turnIndex: 0, speaker: 'TESTEMUNHA_A', text: 'Eu afirmo que estive no local às 22h.'),
        const TranscriptUtterance(turnIndex: 1, speaker: 'TESTEMUNHA_B', text: 'Eu garanto que nunca estive no local dos fatos.'),
      ];
      final contradictions = LinguisticsExecutor.findContradictions(utterances);
      expect(contradictions.length, equals(1));
      expect(contradictions.first.topic, equals('Presença no Local dos Fatos'));
    });
  });

  group('MultimediaExecutor (§14.1)', () {
    test('PNG image dimension extraction and audio properties inspection', () {
      // Mock genuine PNG header with IHDR: 800 x 600
      final pngHeader = Uint8List(24);
      pngHeader.setRange(0, 8, [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      final bdata = ByteData.sublistView(pngHeader);
      bdata.setUint32(16, 800, Endian.big);
      bdata.setUint32(20, 600, Endian.big);

      final imgMeta = MultimediaExecutor.extractImageMetadata(pngHeader);
      expect(imgMeta.format, equals('PNG'));
      expect(imgMeta.width, equals(800));
      expect(imgMeta.height, equals(600));

      // Audio: 44.1kHz, 16bit (2 bytes), 2 channels = 176,400 bytes/sec
      final audioProps = MultimediaExecutor.inspectAudioProperties(
        sampleRateHz: 44100,
        bitDepth: 16,
        channels: 2,
        totalAudioBytes: 352800,
      );
      expect(audioProps.durationSeconds, equals(2.0));
      expect(audioProps.bitRateBps, equals(1411200));
    });

    test('Video frame timeline generation with keyframes', () {
      final frames = MultimediaExecutor.generateVideoFrameTimeline(
        fps: 30.0,
        durationSeconds: 2.0,
        keyframeIntervalFrames: 30,
      );
      expect(frames.length, equals(60));
      expect(frames[0].isKeyframe, isTrue);
      expect(frames[30].isKeyframe, isTrue);
      expect(frames[1].isKeyframe, isFalse);
    });
  });

  group('PlatformBudgetGuard (§14.2)', () {
    test('32MB Android memory budget enforcement', () {
      // <= 32MB authorized
      final okDecision = PlatformLabRunner.canRunOnPlatform(
        platform: 'Android',
        payloadSizeBytes: 5 * 1024 * 1024,
      );
      expect(okDecision.canRun, isTrue);
      expect(okDecision.reason, contains('autorizada no Android'));

      // Exact 32MB
      final exactDecision = PlatformLabRunner.canRunOnPlatform(
        platform: 'android',
        payloadSizeBytes: 32 * 1024 * 1024,
      );
      expect(exactDecision.canRun, isTrue);

      // 32MB + 1 byte rejected
      final rejectDecision = PlatformLabRunner.canRunOnPlatform(
        platform: 'android',
        payloadSizeBytes: (32 * 1024 * 1024) + 1,
      );
      expect(rejectDecision.canRun, isFalse);
      expect(rejectDecision.reason, contains('excede o orçamento de 32MB'));
    });

    test('Python/Pandas routed to Windows from Android', () {
      final pandasOnAndroid = PlatformLabRunner.canRunOnPlatform(
        platform: 'android',
        payloadSizeBytes: 1024,
        requiresPandas: true,
      );
      expect(pandasOnAndroid.canRun, isFalse);
      expect(pandasOnAndroid.reason, equals('Laboratório requer ambiente Python/Pandas completo disponível no Windows'));

      final pandasOnWindows = PlatformLabRunner.canRunOnPlatform(
        platform: 'windows',
        payloadSizeBytes: 1024,
        requiresPandas: true,
      );
      expect(pandasOnWindows.canRun, isTrue);
      expect(pandasOnWindows.reason, equals('Execução autorizada no Windows'));
    });
  });

  group('LabStepValidator & LabExecutionEngine Integration', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(DatabaseConnectionFactory.inMemory());
      // Seed curriculum -> volume -> chapter -> laboratory
      await db.curriculumDao.insertCurriculum(
        CurriculumsCompanion.insert(
          id: 'curr_test',
          name: 'Currículo Teste',
          version: '1.0',
          description: 'Teste',
        ),
      );
      await db.curriculumDao.insertVolume(
        VolumesCompanion.insert(
          id: 'vol_test',
          curriculumId: 'curr_test',
          volumeNumber: 1,
          title: 'Volume I',
          discipline: 'Informática',
          description: 'Desc',
          totalChapters: 1,
        ),
      );
      await db.curriculumDao.insertChapter(
        ChaptersCompanion.insert(
          id: 'ch_test',
          volumeId: 'vol_test',
          chapterNumber: 1,
          title: 'Capítulo 1',
          orderIndex: 1,
        ),
      );
      await db.laboratoryDao.insertLaboratory(
        LaboratoriesCompanion.insert(
          id: 'lab_hash_01',
          chapterId: 'ch_test',
          domain: 'PericiaDigital',
          title: 'Lab Hashes Criptográficos',
          environmentType: 'MetadataExtractor',
          instructionsMarkdown: 'Calcule o hash do arquivo.',
          verificationRubricJson: '[]',
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Executes step validation and records execution run in LaboratoryDao', () async {
      final engine = LabExecutionEngine(laboratoryDao: db.laboratoryDao);

      final criteria = [
        const RubricCriterion(
          id: 'sha256',
          description: 'SHA-256 deve corresponder ao padrão esperado',
          type: RubricCriterionType.exactMatch,
          targetValue: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        ),
      ];

      final report = await engine.executeAndRecord(
        laboratoryId: 'lab_hash_01',
        commandsExecuted: ['sha256sum /tmp/empty.txt'],
        actualOutputs: {
          'sha256': 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        },
        criteria: criteria,
      );

      expect(report.isPassed, isTrue);
      expect(report.scorePercent, equals(100.0));

      final persistedRuns = await db.laboratoryDao.getRunsForLaboratory('lab_hash_01');
      expect(persistedRuns.length, equals(1));
      expect(persistedRuns.first.id, equals(report.runId));
      expect(persistedRuns.first.isPassed, isTrue);
    });
  });
}
