import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class OfflineChapter {
  const OfflineChapter({
    required this.number, required this.title, required this.pdfPath,
    required this.sha, this.pagesPath, this.pageCount = 0,
  });
  final int number;
  final String title;
  final String pdfPath;
  final String sha;
  final String? pagesPath;
  final int pageCount;
  Map<String, dynamic> toJson() => {
    'number': number, 'title': title, 'pdfPath': pdfPath,
    'sha': sha, 'pagesPath': pagesPath, 'pageCount': pageCount,
  };
  factory OfflineChapter.fromJson(Map<String, dynamic> j) => OfflineChapter(
    number: (j['number'] as num).toInt(), title: j['title'].toString(),
    pdfPath: j['pdfPath'].toString(), sha: j['sha'].toString(),
    pagesPath: j['pagesPath'] as String?,
    pageCount: (j['pageCount'] as num?)?.toInt() ?? 0,
  );
}

class OriginalPage {
  const OriginalPage(this.number, this.text);
  final int number;
  final String text;
}

class OfflineLibrary {
  OfflineLibrary({Directory? root}) : _requestedRoot = root;
  final Directory? _requestedRoot;
  late Directory _dir;
  bool _ready = false;
  final Map<int, OfflineChapter> _items = {};
  List<OfflineChapter> get chapters => _items.values.toList()
    ..sort((a,b) => a.number.compareTo(b.number));
  OfflineChapter? chapter(int number) => _items[number];

  Future<void> initialize() async {
    if (_ready) return;
    final root = _requestedRoot ?? await getApplicationSupportDirectory();
    _dir = Directory(p.join(root.path, 'academia_forense_private'));
    await _dir.create(recursive: true);
    final idx = File(p.join(_dir.path, 'index.json'));
    final backup=File(p.join(_dir.path,'index.bak'));
    if(!await idx.exists() && await backup.exists())await backup.copy(idx.path);
    if (await idx.exists()) {
      try {
        final j = jsonDecode(await idx.readAsString()) as Map<String,dynamic>;
        for (final item in j['chapters'] as List<dynamic>) {
          final chapter = OfflineChapter.fromJson(item as Map<String,dynamic>);
          final file = File(chapter.pdfPath);
          if (await file.exists() &&
            sha256.convert(await file.readAsBytes()).toString() == chapter.sha) {
            _items[chapter.number] = chapter;
          }
        }
      } catch (_) { _items.clear(); }
    }
    _ready = true;
  }

  Future<void> _saveIndex() async {
    final tmp = File(p.join(_dir.path,'index.tmp'));
    await tmp.writeAsString(jsonEncode({'chapters':
      chapters.map((c) => c.toJson()).toList()}), flush:true);
    final index = File(p.join(_dir.path,'index.json'));
    final backup=File(p.join(_dir.path,'index.bak'));
    if(await index.exists())await index.copy(backup.path);
    try{await tmp.rename(index.path);}catch(_){
      if(await backup.exists())await backup.copy(index.path);
      rethrow;
    }
  }

  static bool _pdf(List<int> b) => b.length > 100 &&
    b[0] == 37 && b[1] == 80 && b[2] == 68 && b[3] == 70 && b[4] == 45;

  Future<int> pickAndImport() async {
    await initialize();
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['zip','pdf'],
      allowMultiple: true, withData: true);
    if (picked == null) return 0;
    var imported = 0;
    for (final file in picked.files) {
      final b = file.bytes ?? (file.path == null ? null :
        await File(file.path!).readAsBytes());
      if (b == null) throw const FormatException('Provedor de arquivos indisponível.');
      if (file.name.toLowerCase().endsWith('.zip')) {
        imported += await importPack(b);
      } else if (file.name.toLowerCase().endsWith('.pdf')) {
        await importPdf(b, file.name);
        imported++;
      }
    }
    return imported;
  }

  Future<int> importPack(List<int> zipBytes) async {
    await initialize();
    if (zipBytes.length > 100 * 1024 * 1024) {
      throw const FormatException('ZIP maior que 100MB.');
    }
    final archive = ZipDecoder().decodeBytes(zipBytes, verify: true);
    if (archive.length > 250) throw const FormatException('ZIP com entradas demais.');
    final entries = <String, ArchiveFile>{};
    var total = 0;
    for (final entry in archive) {
      if (!entry.isFile) continue;
      if (entry.name.startsWith('/') || entry.name.contains('..') ||
          entry.name.contains('\\')) throw const FormatException('ZIP inseguro.');
      total += entry.size;
      if (total > 250 * 1024 * 1024) {
        throw const FormatException('Conteúdo ZIP excede 250MB.');
      }
      if(entries.containsKey(entry.name))throw const FormatException('Entrada ZIP duplicada.');
      entries[entry.name] = entry;
    }
    final head = entries['manifest.json'];
    if (head == null) throw const FormatException('Manifesto ausente.');
    final manifest = jsonDecode(utf8.decode(head.content as List<int>))
      as Map<String,dynamic>;
    if (manifest['schema'] != 'academia-forense-offline-pack-v2') {
      throw const FormatException('Importe o pacote integral v2 com PDFs e páginas.');
    }
    final rows = manifest['chapters'] as List<dynamic>;
    final staged = <OfflineChapter>[];
    final files = <String,List<int>>{};
    final seen = <int>{};
    // Verify everything before any files are written.
    for (final raw in rows) {
      final m = raw as Map<String,dynamic>;
      final n = (m['chapter'] as num).toInt();
      if (n < 1 || n > 999 || !seen.add(n)) {
        throw const FormatException('Numeração inválida ou duplicada.');
      }
      final suffix = n.toString().padLeft(2,'0');
      final pdfKey = 'pdfs/cap_$suffix.pdf';
      final pagesKey = 'pages/cap_$suffix.json';
      if (m['pdf'] != pdfKey || m['pages'] != pagesKey ||
          !entries.containsKey(pdfKey) || !entries.containsKey(pagesKey)) {
        throw FormatException('Capítulo $n incompleto.');
      }
      final pdf = entries[pdfKey]!.content as List<int>;
      final pageBytes = entries[pagesKey]!.content as List<int>;
      if (!_pdf(pdf) || sha256.convert(pdf).toString() != m['sha256']) {
        throw FormatException('PDF do capítulo $n não passou no SHA-256.');
      }
      final textDoc = jsonDecode(utf8.decode(pageBytes)) as Map<String,dynamic>;
      final pageRows = textDoc['pages'] as List<dynamic>? ?? [];
      if (textDoc['chapter'] != n ||
          pageRows.length != (m['pageCount'] as num).toInt()) {
        throw FormatException('Páginas incorretas no capítulo $n.');
      }
      if(pageRows.isEmpty || pageRows.asMap().entries.any((e){
        final v=e.value;
        return v is! Map || v['number']!=e.key+1 || v['text'] is! String;
      }) || pageRows.every((v)=>(v['text'] as String).trim().isEmpty)){
        throw FormatException('Texto ausente ou numeração irregular no capítulo $n.');
      }
      final pdfHash=sha256.convert(pdf).toString();
      final textHash=sha256.convert(pageBytes).toString();
      final pdfPath = p.join(_dir.path, 'cap_${suffix}_$pdfHash.pdf');
      final pagePath = p.join(_dir.path, 'cap_${suffix}_$textHash.json');
      files[pdfPath] = pdf;
      files[pagePath] = pageBytes;
      staged.add(OfflineChapter(
        number:n, title:m['title'].toString(), pdfPath:pdfPath,
        pagesPath:pagePath, sha:m['sha256'].toString(),
        pageCount:pageRows.length));
    }
    for (final entry in files.entries) {
      final old=File(entry.key);
      if(await old.exists() && sha256.convert(await old.readAsBytes()).toString()==sha256.convert(entry.value).toString())continue;
      final tmp = File(entry.key + '.tmp');
      await tmp.writeAsBytes(entry.value, flush:true);
      if (await old.exists()) await old.delete();
      await tmp.rename(entry.key);
    }
    final previous=Map<int,OfflineChapter>.from(_items);
    for (final c in staged) { _items[c.number] = c; }
    try{await _saveIndex();}catch(_){_items..clear()..addAll(previous);rethrow;}
    return staged.length;
  }

  Future<void> importPdf(List<int> bytes, String name) async {
    await initialize();
    final match = RegExp(r'Cap(?:itulo)?[_-]?(\d{1,3})',
      caseSensitive:false).firstMatch(name);
    if (match == null || !_pdf(bytes)) {
      throw const FormatException('PDF inválido ou número de capítulo ausente no nome.');
    }
    final n = int.parse(match.group(1)!);
    final current=_items[n];
    if(current!=null && current.pagesPath!=null){
      if(current.sha==sha256.convert(bytes).toString())return;
      throw const FormatException('Para atualizar um capítulo com texto nativo, importe o ZIP integral v2; o conteúdo anterior foi preservado.');
    }
    final dst = File(p.join(_dir.path, 'cap_' + n.toString().padLeft(2,'0') + '.pdf'));
    await dst.writeAsBytes(bytes, flush:true);
    _items[n] = OfflineChapter(
      number:n, title:_items[n]?.title ?? name, pdfPath:dst.path,
      sha:sha256.convert(bytes).toString());
    await _saveIndex();
  }

  Future<List<OriginalPage>> pages(int number) async {
    final chapter = _items[number];
    if (chapter?.pagesPath == null) return [];
    try {
      final j = jsonDecode(await File(chapter!.pagesPath!).readAsString())
        as Map<String,dynamic>;
      return (j['pages'] as List<dynamic>).map((e) {
        final row = e as Map<String,dynamic>;
        return OriginalPage((row['number'] as num).toInt(),row['text'].toString());
      }).toList();
    } catch (_) { return []; }
  }

  Future<List<OriginalPage>> relevantPages(int number,String question) async {
    final source = await pages(number);
    final tokens = question.toLowerCase()
      .split(RegExp(r'[^a-z0-9À-ÿ]+')).where((x) => x.length > 3).toSet();
    final scored = source.map((page) {
      final body = page.text.toLowerCase();
      final weight = tokens.fold<int>(0,(total,word) =>
        total + RegExp(RegExp.escape(word)).allMatches(body).length);
      return (page:page,weight:weight);
    }).toList()..sort((a,b) => b.weight.compareTo(a.weight));
    return scored.take(4).map((entry) => entry.page).toList();
  }
}
