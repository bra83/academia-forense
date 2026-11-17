import 'dart:async';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:pdfx/pdfx.dart';
import 'package:persistence_core/persistence_core.dart';
import '../services/offline_library.dart';

class StudyReaderV2 extends StatefulWidget {
  const StudyReaderV2({super.key,required this.chapter,required this.library,
    required this.database,this.onDone});
  final OfflineChapter chapter;
  final OfflineLibrary library;
  final AppDatabase database;
  final VoidCallback? onDone;
  @override
  State<StudyReaderV2> createState() => _StudyReaderV2State();
}

class _StudyReaderV2State extends State<StudyReaderV2> {
  PdfController? _pdf;
  PdfControllerPinch? _pinch;
  List<OriginalPage> _pages = [];
  final _note = TextEditingController();
  final _timer = Stopwatch();
  String? _sessionId;
  bool _studyMode = false;
  bool _busy = false;
  String _message = '';
  int _page = 1;
  int get _pageCount => widget.chapter.pageCount > 0 ?
    widget.chapter.pageCount : (_pdf?.pagesCount ?? 1);

  @override
  void initState() {
    super.initState();
    _pdf = PdfController(document: PdfDocument.openFile(widget.chapter.pdfPath));
    _pinch = PdfControllerPinch(document: PdfDocument.openFile(widget.chapter.pdfPath));
    _timer.start();
    _load();
  }

  Future<void> _load() async {
    try {
      _pages = await widget.library.pages(widget.chapter.number);
      final position = await widget.database.userProgressDao
        .getReadingPosition('forense.vol' +
          (widget.chapter.number<=10?'01':widget.chapter.number<=23?'02':'03') +
          '.ch' + widget.chapter.number.toString().padLeft(2,'0'));
      final id = 'study_' + DateTime.now().microsecondsSinceEpoch.toString();
      await widget.database.userProgressDao.startStudySession(
        StudySessionsCompanion.insert(id:id,chapterId:_chapterId));
      _sessionId = id;
      if (!mounted) return;
      setState(() => _page = position?.pageNumber ?? 1);
      if (_page > 1) {
        _pdf?.jumpToPage(_page);
        _pinch?.jumpToPage(_page);
      }
    } catch (e) {
      if (mounted) setState(() => _message =
        'Erro na preparação da leitura: ' + e.runtimeType.toString());
    }
  }

  String get _chapterId => 'forense.vol' +
      (widget.chapter.number<=10?'01':widget.chapter.number<=23?'02':'03') +
      '.ch' + widget.chapter.number.toString().padLeft(2,'0');

  Future<void> _recordPage(int page) async {
    if (page < 1) return;
    if (mounted) setState(() => _page = page);
    try {
      await widget.database.userProgressDao.saveReadingPosition(
        chapterId:_chapterId,pageNumber:page,scrollRatio:0);
    } catch (_) {
      if (mounted) setState(() => _message =
        'Não foi possível salvar a página atual.');
    }
  }

  Future<void> _bookmark() async {
    try {
      await widget.database.userProgressDao.addBookmark(
        BookmarksCompanion.insert(
          id:'mark_' + DateTime.now().microsecondsSinceEpoch.toString(),
          chapterId:_chapterId,
          pageNumber:_page,
          sectionTitle:'Capítulo ' + widget.chapter.number.toString() + ', página ' + _page.toString(),
        ));
      if (mounted) setState(() => _message = 'Página adicionada aos favoritos.');
    } catch (_) {
      if (mounted) setState(() => _message = 'Não foi possível salvar o marcador.');
    }
  }

  Future<void> _saveNote() async {
    final text = _note.text.trim();
    if (text.isEmpty) return;
    try {
      await widget.database.userProgressDao.saveAnnotation(
        AnnotationsCompanion.insert(
          id:'note_' + DateTime.now().microsecondsSinceEpoch.toString(),
          chapterId:_chapterId,
          pageNumber:_page,
          selectedText:'Página ' + _page.toString(),
          note:text,
        ));
      _note.clear();
      if (mounted) setState(() => _message = 'Anotação salva neste capítulo.');
    } catch (_) {
      if (mounted) setState(() => _message = 'Não foi possível salvar a anotação.');
    }
  }

  Future<void> _finish({bool pop = false}) async {
    if (_busy) return;
    setState(() => _busy=true);
    try {
      _timer.stop();
      final id = _sessionId;
      if (id != null) {
        await widget.database.userProgressDao.endStudySession(
          id,durationSeconds:_timer.elapsed.inSeconds,
          pagesRead:1);
        _sessionId=null;
      }
      widget.onDone?.call();
      if (!mounted) return;
      if (pop) Navigator.of(context).pop();
      else setState(() => _message = 'Tempo real de estudo salvo.');
    } catch (_) {
      if (mounted) setState(() => _message =
        'Não consegui registrar a sessão; tente novamente.');
    } finally {
      if (mounted) setState(() => _busy=false);
    }
  }

  @override
  void dispose() {
    if (_sessionId != null) {
      final id = _sessionId!;
      _sessionId=null;
      unawaited(widget.database.userProgressDao.endStudySession(
        id,durationSeconds:_timer.elapsed.inSeconds,pagesRead:1));
    }
    _timer.stop();
    _pdf?.dispose();
    _pinch?.dispose();
    _note.dispose();
    super.dispose();
  }

  Widget _pageText() {
    final page = _pages.where((p) => p.number == _page).toList();
    if (page.isEmpty) {
      return const Center(child: Text('Texto responsivo não disponível. '
          'Use a visualização PDF original.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SelectableText(
        page.first.text, style: const TextStyle(fontSize:17,height:1.65)));
  }

  @override
  Widget build(BuildContext context) {
    final windows = Theme.of(context).platform == TargetPlatform.windows;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cap. ' + widget.chapter.number.toString() +
          ' — ' + widget.chapter.title,overflow:TextOverflow.ellipsis),
        actions: [
          IconButton(onPressed:_bookmark,tooltip:'Marcar página',
            icon:const Icon(Icons.bookmark_add_outlined)),
          IconButton(onPressed: () => _finish(pop:true),
            tooltip:'Encerrar e salvar estudo',
            icon:const Icon(Icons.check_circle_outline)),
        ],
      ),
      body: Column(children:[
        Material(
          color:Theme.of(context).colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children:[
              Row(children:[
                Text('Página $_page / $_pageCount'),
                const Spacer(),
                TextButton.icon(
                  onPressed:()=>setState(()=>_studyMode=!_studyMode),
                  icon:Icon(_studyMode?Icons.picture_as_pdf:Icons.article_outlined),
                  label:Text(_studyMode?'PDF original':'Texto responsivo'),
                ),
              ]),
              if (_message.isNotEmpty)
                Text(_message,style:const TextStyle(fontSize:12)),
            ]),
          ),
        ),
        Expanded(child:_studyMode ? _pageText()
          : windows ? PdfView(controller:_pdf!,
              onPageChanged:_recordPage,
              onDocumentError:(e) => setState(()=>_message='Erro PDF: $e'))
          : PdfViewPinch(controller:_pinch!,
              onPageChanged:_recordPage,
              onDocumentError:(e)=>setState(()=>_message='Erro PDF: $e'))),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children:[
            IconButton(onPressed: _page<=1 ? null : () async {
              final n=_page-1;
              await _recordPage(n);
              if (windows) _pdf?.jumpToPage(n);
              else _pinch?.jumpToPage(n);
            }, icon:const Icon(Icons.chevron_left)),
            Expanded(child:TextField(
              controller:_note,minLines:1,maxLines:3,
              decoration:const InputDecoration(
                hintText:'Anotação desta página',
                border:OutlineInputBorder(),isDense:true))),
            IconButton(onPressed:_saveNote,icon:const Icon(Icons.save),
              tooltip:'Salvar anotação'),
            IconButton(onPressed: _page>=_pageCount ? null : () async {
              final n=_page+1;
              await _recordPage(n);
              if (windows) _pdf?.jumpToPage(n);
              else _pinch?.jumpToPage(n);
            }, icon:const Icon(Icons.chevron_right)),
          ]),
        ),
      ]),
    );
  }
}
