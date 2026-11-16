import 'dart:io';
import 'package:args/args.dart';
import 'package:content_core/content_core.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('input', abbr: 'i', help: 'Path to package JSON file')
    ..addOption('dir', abbr: 'd', help: 'Path to directory containing package JSON files')
    ..addOption('manifest', abbr: 'm', help: 'Path to curriculum.manifest.json')
    ..addFlag('all-vol1', help: 'Validate all Volume 1 seed packages')
    ..addFlag('all', abbr: 'a', help: 'Validate manifest and all Volume 1 seed packages')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage help');

  final results = parser.parse(arguments);
  if (results['help'] as bool) {
    print('Academia Forense Section 19 & Manifest Validator');
    print(parser.usage);
    exit(0);
  }

  var hasFailure = false;

  // 1. Validate manifest
  if (results['manifest'] != null || (results['all'] as bool)) {
    final manifestPath = (results['manifest'] as String?) ?? 'content/manifests/curriculum.manifest.json';
    final manifestFile = File(manifestPath);
    if (!await manifestFile.exists()) {
      print('  ✗ Manifest file not found: $manifestPath');
      hasFailure = true;
    } else {
      print('Validating curriculum manifest: $manifestPath...');
      final mContent = await manifestFile.readAsString();
      final mValidator = CurriculumManifestValidator();
      final mReport = mValidator.validateJsonString(mContent);
      if (mReport.isValid) {
        print('  ✓ VALID MANIFEST: $manifestPath');
      } else {
        print('  ✗ INVALID MANIFEST: $manifestPath');
        for (final err in mReport.errors) {
          print('      - $err');
        }
        hasFailure = true;
      }
    }
  }

  // 2. Validate packages
  final filesToValidate = <File>[];

  if ((results['all-vol1'] as bool) || (results['all'] as bool)) {
    final dir = Directory('content/fixtures/volume_01');
    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.json') && !entity.path.endsWith('errata.json')) {
          filesToValidate.add(entity);
        }
      }
    }
  } else if (results['input'] != null) {
    filesToValidate.add(File(results['input'] as String));
  } else if (results['dir'] != null) {
    final dir = Directory(results['dir'] as String);
    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          filesToValidate.add(entity);
        }
      }
    }
  }

  if (filesToValidate.isNotEmpty) {
    final validator = Section19Validator();
    filesToValidate.sort((a, b) => a.path.compareTo(b.path));
    print('\nValidating ${filesToValidate.length} package file(s) against Section 19 schema...');

    for (final file in filesToValidate) {
      if (!await file.exists()) {
        print('  ✗ File not found: ${file.path}');
        hasFailure = true;
        continue;
      }
      final content = await file.readAsString();
      final report = validator.validateJsonString(content);
      if (report.isValid) {
        print('  ✓ VALID: ${file.path}');
      } else {
        print('  ✗ INVALID: ${file.path}');
        for (final err in report.errors) {
          print('      - $err');
        }
        hasFailure = true;
      }
    }
  }

  if (hasFailure) {
    print('\nValidation completed with errors.');
    exit(1);
  } else {
    print('\nAll items validated successfully.');
    exit(0);
  }
}
