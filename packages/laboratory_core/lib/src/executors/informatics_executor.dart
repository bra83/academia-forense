import 'dart:io';

/// Model representing a file or directory node in a simulated or real file tree.
class FileTreeNode {
  final String path;
  final String name;
  final bool isDirectory;
  final int sizeBytes;
  final int permissionsOctal;
  final List<FileTreeNode> children;

  const FileTreeNode({
    required this.path,
    required this.name,
    required this.isDirectory,
    this.sizeBytes = 0,
    this.permissionsOctal = 420, // 0644 default
    this.children = const [],
  });
}

/// Parsed CLI command structure.
class ParsedCommand {
  final String executable;
  final List<String> arguments;
  final Map<String, String> flags;
  final List<String> subcommands;
  final bool hasPipe;
  final List<String> pipeStages;

  const ParsedCommand({
    required this.executable,
    required this.arguments,
    required this.flags,
    required this.subcommands,
    this.hasPipe = false,
    this.pipeStages = const [],
  });
}

/// File permissions detail.
class FilePermissions {
  final int octal;
  final String rwxString;
  final bool userRead;
  final bool userWrite;
  final bool userExecute;
  final bool groupRead;
  final bool groupWrite;
  final bool groupExecute;
  final bool otherRead;
  final bool otherWrite;
  final bool otherExecute;

  const FilePermissions({
    required this.octal,
    required this.rwxString,
    required this.userRead,
    required this.userWrite,
    required this.userExecute,
    required this.groupRead,
    required this.groupWrite,
    required this.groupExecute,
    required this.otherRead,
    required this.otherWrite,
    required this.otherExecute,
  });
}

/// Executor for Informática Forense practical tasks (§14.1).
class InformaticsExecutor {
  /// Parses POSIX octal permissions (e.g. 0755, "755", "644") into structured flags and -rwxr-xr-x string.
  static FilePermissions parsePermissions(dynamic octalInput) {
    int octalValue;
    if (octalInput is int) {
      // If entered as 755 (decimal 755 is 0x2f3) or octal literal
      if (octalInput > 511) {
        // e.g. 755 passed as decimal 755, parse as string octal
        octalValue = int.parse(octalInput.toString(), radix: 8);
      } else {
        octalValue = octalInput;
      }
    } else if (octalInput is String) {
      octalValue = int.parse(octalInput.replaceAll(RegExp(r'[^0-7]'), ''), radix: 8);
    } else {
      throw ArgumentError('Permissão inválida: $octalInput');
    }

    final u = (octalValue >> 6) & 7;
    final g = (octalValue >> 3) & 7;
    final o = octalValue & 7;

    String modeToString(int mode) {
      final r = (mode & 4) != 0 ? 'r' : '-';
      final w = (mode & 2) != 0 ? 'w' : '-';
      final x = (mode & 1) != 0 ? 'x' : '-';
      return '$r$w$x';
    }

    final rwx = '-${modeToString(u)}${modeToString(g)}${modeToString(o)}';

    return FilePermissions(
      octal: octalValue,
      rwxString: rwx,
      userRead: (u & 4) != 0,
      userWrite: (u & 2) != 0,
      userExecute: (u & 1) != 0,
      groupRead: (g & 4) != 0,
      groupWrite: (g & 2) != 0,
      groupExecute: (g & 1) != 0,
      otherRead: (o & 4) != 0,
      otherWrite: (o & 2) != 0,
      otherExecute: (o & 1) != 0,
    );
  }

  /// Traverses a FileTreeNode recursively, collecting all paths in DFS order.
  static List<String> traverseTree(FileTreeNode root) {
    final paths = <String>[root.path];
    for (final child in root.children) {
      paths.addAll(traverseTree(child));
    }
    return paths;
  }

  /// Traverses a local filesystem directory up to maxDepth.
  static List<String> traverseFileSystem(Directory dir, {int maxDepth = 3}) {
    if (!dir.existsSync()) return [];
    final results = <String>[];

    void recurse(Directory current, int currentDepth) {
      if (currentDepth > maxDepth) return;
      try {
        final entities = current.listSync(followLinks: false);
        for (final entity in entities) {
          results.add(entity.path);
          if (entity is Directory && currentDepth < maxDepth) {
            recurse(entity, currentDepth + 1);
          }
        }
      } catch (_) {
        // Permission or access error
      }
    }

    recurse(dir, 1);
    results.sort();
    return results;
  }

  /// Formats tree nodes as an indented directory hierarchy string.
  static String formatTree(FileTreeNode root, [String indent = '']) {
    final buffer = StringBuffer();
    buffer.writeln('$indent${root.isDirectory ? '📁 ' : '📄 '}${root.name}');
    for (final child in root.children) {
      buffer.write(formatTree(child, '$indent  '));
    }
    return buffer.toString();
  }

  /// Parses a shell command line string into structured components.
  static ParsedCommand parseCommand(String commandLine) {
    final trimmed = commandLine.trim();
    if (trimmed.isEmpty) {
      return const ParsedCommand(
        executable: '',
        arguments: [],
        flags: {},
        subcommands: [],
      );
    }

    // Check for pipeline
    final pipeStages = trimmed.split('|').map((s) => s.trim()).toList();
    final hasPipe = pipeStages.length > 1;

    final primary = pipeStages.first;
    // Regex tokenizer that respects quotes
    final tokenRegex = RegExp(r'[^\s"\x27]+|"[^"]*"|\x27[^\x27]*\x27');
    final tokens = tokenRegex
        .allMatches(primary)
        .map((m) => m.group(0)!)
        .map((s) {
          if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith("'") && s.endsWith("'"))) {
            return s.substring(1, s.length - 1);
          }
          return s;
        })
        .toList();

    if (tokens.isEmpty) {
      return const ParsedCommand(
        executable: '',
        arguments: [],
        flags: {},
        subcommands: [],
      );
    }

    final executable = tokens.first;
    final args = <String>[];
    final flags = <String, String>{};
    final subcommands = <String>[];

    for (var i = 1; i < tokens.length; i++) {
      final token = tokens[i];
      if (token.startsWith('--')) {
        final equalIndex = token.indexOf('=');
        if (equalIndex != -1) {
          final k = token.substring(2, equalIndex);
          final v = token.substring(equalIndex + 1);
          flags[k] = v;
        } else {
          final k = token.substring(2);
          if (i + 1 < tokens.length && !tokens[i + 1].startsWith('-')) {
            flags[k] = tokens[i + 1];
            i++;
          } else {
            flags[k] = 'true';
          }
        }
      } else if (token.startsWith('-') && token.length > 1) {
        final k = token.substring(1);
        if (i + 1 < tokens.length && !tokens[i + 1].startsWith('-')) {
          flags[k] = tokens[i + 1];
          i++;
        } else {
          flags[k] = 'true';
        }
      } else {
        if (args.isEmpty && !token.contains('.')) {
          subcommands.add(token);
        }
        args.add(token);
      }
    }

    return ParsedCommand(
      executable: executable,
      arguments: args,
      flags: flags,
      subcommands: subcommands,
      hasPipe: hasPipe,
      pipeStages: pipeStages,
    );
  }
}
