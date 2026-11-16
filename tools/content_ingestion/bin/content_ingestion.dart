import 'dart:io';
import 'package:args/args.dart';
import 'package:drive_sync/drive_sync.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('input', abbr: 'i', help: 'Path to package JSON file or directory')
    ..addOption('provider', abbr: 'p', defaultsTo: 'local_directory', help: 'Provider: local_directory, fixture, google_drive')
    ..addFlag('all-vol1', help: 'Ingest all Volume 1 seed fixtures')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage help');

  final results = parser.parse(arguments);
  if (results['help'] as bool) {
    print('Academia Forense Content Ingestion CLI');
    print(parser.usage);
    exit(0);
  }

  final engine = ContentIngestionEngine();

  if (results['all-vol1'] as bool) {
    print('Ingesting all Volume 1 seed fixtures...');
    final fixtureProvider = FixtureContentProvider(
      baseFixturesPath: 'content/fixtures/volume_01',
    );
    final batch = await fixtureProvider.loadAllVolume1Fixtures();
    var successCount = 0;
    for (final res in batch) {
      if (res.isSuccess) {
        successCount++;
        print('  ✓ Chapter ${res.package?.chapter}: ${res.package?.title} (SHA-256: ${res.sha256?.substring(0, 16)}...)');
      } else {
        print('  ✗ Ingestion failed: ${res.errors}');
      }
    }
    print('Done: $successCount/10 fixtures ingested successfully.');
    exit(successCount == 10 ? 0 : 1);
  }

  final inputPath = results['input'] as String?;
  if (inputPath == null) {
    print('Error: --input or --all-vol1 is required.');
    print(parser.usage);
    exit(1);
  }

  final file = File(inputPath);
  final dir = Directory(inputPath);

  if (await file.exists()) {
    print('Ingesting file: $inputPath');
    final bytes = await file.readAsBytes();
    final res = await engine.ingestPackageBytes(
      bytes,
      sourceFileName: file.uri.pathSegments.last,
      provider: results['provider'] as String,
    );
    if (res.isSuccess) {
      print('✓ Successfully ingested package: ${res.package?.contentId} - ${res.package?.title}');
      print('  SHA-256: ${res.sha256}');
      print('  Edition: ${res.package?.edition} | Status: ${res.package?.editorialStatus}');
      exit(0);
    } else {
      print('✗ Ingestion failed:');
      for (final err in res.errors) {
        print('  - $err');
      }
      exit(1);
    }
  } else if (await dir.exists()) {
    print('Ingesting directory: $inputPath');
    final provider = LocalDirectoryContentProvider();
    final batch = await provider.ingestDirectory(inputPath);
    var ok = 0;
    for (final res in batch) {
      if (res.isSuccess) {
        ok++;
        print('  ✓ ${res.package?.contentId}: ${res.package?.title}');
      } else {
        print('  ✗ Failed: ${res.errors}');
      }
    }
    print('Ingested $ok/${batch.length} packages.');
    exit(ok == batch.length ? 0 : 1);
  } else {
    print('Error: Input path does not exist: $inputPath');
    exit(1);
  }
}
