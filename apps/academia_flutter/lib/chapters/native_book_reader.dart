import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/offline_library.dart';
import '../services/voice_reader_v2.dart';
import 'native_book_models.dart';
import 'book_html.dart';
import 'native_book_tools.dart';
import 'reader_typography.dart';
import 'study_catalog.dart';

/// Full-text, adjustable, paginated reading of the actual 26 source chapters.
/// The imported PDF archive, when available, supplies exact source page breaks.
/// Built-in text is reflowed and clearly labeled as reader screens instead.
class NativeBookReader extends StatefulWidget {
  const NativeBookReader({
    super.key,required this.initialChapter,required this.catalog,
    required this.library,required this.getApiKey,required this.textModel,
    required this.speechModel,this.onOpenPdf,
  });
  final int initialChapter;
  final List<StudyChapter> catalog;
  final OfflineLibrary library;
  final Future<String?> Function() getApiKey;
  final String? textModel;
  final String? speechModel;
  final Future<void> Function(int chapter)? onOpenPdf;
  @override
  State<NativeBookReader> createState()=>_NativeBookReaderState();
}
class _NativeBookReaderState extends State<NativeBookReader> {
  static const forest=Color(0xFF174B3B);
  final _scroll=ScrollController();
  WebViewController? _htmlController;
  bool _htmlReading=Platform.isAndroid;
  String _htmlQuote='',_htmlBlock='';
  int _htmlStart=-1,_htmlEnd=-1;
  BookChapter? _book;
  bool _loading=true;
  int _chapter=1,_page=0;
  double _font=17.0;
  String _error='';
  List<Map<String,dynamic>> _highlights=[];
  Set<int> _bookmarks={};
  int? _selectionStart,_selectionEnd;
  bool get _hasSelection=>(_selectionStart!=null && _selectionEnd!=null &&
    _selectionEnd!>_selectionStart!) || (_htmlReading && _htmlQuote.isNotEmpty);
  String get _pageText{
    final book=_book;
    if(book==null || _page>=book.screens.length)return '';
    return book.screens[_page].text;
  }
  String get _label{
    final book=_book;
    if(book==null)return '';
    return book.exactPdfPages?
      'Página original ${book.screens[_page].number} de ${book.originalPages}':
      'Tela ${_page+1} de ${book.screens.length}';
  }
  String get _title{
    for(final chapter in widget.catalog){
      if(chapter.number==_chapter)return chapter.title;
    }
    return 'Capítulo $_chapter';
  }
  @override
  void initState(){
    super.initState();
    _chapter=widget.initialChapter;
    if(Platform.isAndroid){
      _prepareHtml();
    } else {
      _load(_chapter);
    }
  }
  @override
  void dispose(){
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _prepareHtml() async {
    try {
      final controller=WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.addJavaScriptChannel('BookBridge',
        onMessageReceived:(event){
          if(!mounted)return;
          try {
            final data=jsonDecode(event.message) as Map<String,dynamic>;
            if(data['type']!='selection')return;
            final quote=(data['quote']??'').toString().trim();
            if(quote.isEmpty)return;
            setState((){
              _htmlQuote=quote;
              _htmlBlock=(data['block']??'').toString();
              _htmlStart=(data['start'] as num?)?.toInt()??-1;
              _htmlEnd=(data['end'] as num?)?.toInt()??-1;
            });
          } catch (_) {
            // Malformed JavaScript messages must not alter saved selections.
          }
        });
      await controller.setNavigationDelegate(NavigationDelegate(
        onNavigationRequest:(_)=>NavigationDecision.prevent));
      _htmlController=controller;
    } catch (e) {
      _htmlReading=false;
      _htmlController=null;
    }
    if(mounted)await _load(_chapter);
  }

  Future<void> _renderHtml() async {
    final controller=_htmlController;
    if(!_htmlReading || controller==null || _book==null)return;
    try {
      await controller.loadHtmlString(SourceHtmlConverter.pageHtml(
        _pageText,fontSize:_font,chapter:_chapter,screen:_page,
        highlights:_highlights));
    } catch (e) {
      if(mounted){
        setState(()=>_htmlReading=false);
        _notify('HTML indisponível. Leitor de texto mantido.');
      }
    }
  }

  Future<void> _load(int chapter) async {
    setState((){
      _chapter=chapter;_loading=true;_error='';
      _book=null;_selectionStart=null;_selectionEnd=null;
      _highlights=[];_bookmarks={};
      _htmlQuote='';_htmlBlock='';_htmlStart=-1;_htmlEnd=-1;
    });
    try {
      final book=await const SourceBookLibrary().load(chapter,widget.library);
      final prefs=await SharedPreferences.getInstance();
      final savedPage=prefs.getInt('source_reader_page_$chapter')??0;
      final font=prefs.getDouble('source_reader_font')??17;
      final marks=prefs.getStringList('source_reader_marks_$chapter')??[];
      final annotations=prefs.getString('source_reader_highlights_$chapter');
      final loaded=<Map<String,dynamic>>[];
      if(annotations!=null){
        try {
          final raw=jsonDecode(annotations) as List<dynamic>;
          for(final item in raw){
            if(item is Map<String,dynamic> &&
              item['page'] is int && item['start'] is int &&
              item['end'] is int && item['text'] is String) {
              loaded.add(item);
            }
          }
        } catch (_) {
          // Report invalid stored records without replacing content.
        }
      }
      if(!mounted)return;
      setState((){
        _book=book;_loading=false;
        _page=savedPage.clamp(0,book.screens.length-1);
        _font=font.clamp(14.0,26.0);
        _bookmarks=marks.map(int.tryParse)
          .whereType<int>().toSet();
        _highlights=loaded;
      });
      await _renderHtml();
    } catch(e) {
      if(mounted)setState((){
        _loading=false;_error='Não foi possível carregar o livro: $e';
      });
    }
  }

  Future<void> _moveTo(int index) async {
    final book=_book;
    if(book==null || index<0 || index>=book.screens.length)return;
    setState((){
      _page=index;_selectionStart=null;_selectionEnd=null;
      _htmlQuote='';_htmlBlock='';_htmlStart=-1;_htmlEnd=-1;
    });
    if(_scroll.hasClients)_scroll.jumpTo(0);
    await _renderHtml();
    try {
      final prefs=await SharedPreferences.getInstance();
      final ok=await prefs.setInt('source_reader_page_$_chapter',index);
      if(!ok)throw StateError('Posição de leitura não gravada.');
    } catch (_) {
      _notify('Não foi possível guardar a posição de leitura.');
    }
  }
  void _notify(String message){
    if(!mounted)return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content:Text(message)));
  }

  Future<void> _changeFont(double value) async {
    setState(()=>_font=value.clamp(14.0,26.0));
    await _renderHtml();
    try {
      final prefs=await SharedPreferences.getInstance();
      await prefs.setDouble('source_reader_font',_font);
    } catch (_) {
      _notify('A preferência de tamanho não foi gravada.');
    }
  }

  Future<void> _bookmark() async {
    final modified=Set<int>.from(_bookmarks);
    if(!modified.add(_page))modified.remove(_page);
    try {
      final prefs=await SharedPreferences.getInstance();
      final values=modified.toList()..sort();
      final items=values.map((v)=>v.toString()).toList();
      final ok=await prefs.setStringList(
        'source_reader_marks_$_chapter',items);
      if(!ok)throw StateError('Falha no armazenamento');
      if(!mounted)return;
      setState(()=>_bookmarks=modified);
      _notify(modified.contains(_page)?
        'Tela adicionada aos marcadores.':'Marcador removido.');
    } catch(e){
      _notify('Não foi possível salvar o marcador: $e');
    }
  }

  Future<void> _saveHighlights(List<Map<String,dynamic>> next) async {
    final prefs=await SharedPreferences.getInstance();
    final encoded=jsonEncode(next);
    final ok=await prefs.setString(
      'source_reader_highlights_$_chapter',encoded);
    if(!ok || prefs.getString(
      'source_reader_highlights_$_chapter')!=encoded) {
      throw StateError('A gravação do trecho não foi confirmada.');
    }
    if(mounted)setState(()=>_highlights=next);
    await _renderHtml();
  }

  Future<void> _markSelection() async {
    if(!_hasSelection)return;
    final html=_htmlReading && _htmlQuote.trim().isNotEmpty;
    final body=_pageText;
    final quote=html ? _htmlQuote.trim() :
      body.substring(_selectionStart!,_selectionEnd!).trim();
    if(quote.isEmpty)return;
    final start=html?body.indexOf(quote):_selectionStart!;
    final end=start<0?-1:(html?start+quote.length:_selectionEnd!);
    if(!html && (start<0 || end>body.length || end<=start))return;
    final noteInput=TextEditingController();
    final message=await showDialog<String>(
      context:context,builder:(ctx)=>AlertDialog(
        title:const Text('Salvar trecho marcado'),
        content:SingleChildScrollView(child:Column(
          mainAxisSize:MainAxisSize.min,
          crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(quote.length>460?
            '${quote.substring(0,460)}…':quote,
            style:const TextStyle(fontSize:14,height:1.45)),
          const SizedBox(height:14),
          TextField(controller:noteInput,
            maxLines:3,
            decoration:const InputDecoration(
              labelText:'Sua anotação (opcional)',
              border:OutlineInputBorder())),
        ])),
        actions:[
          TextButton(onPressed:()=>Navigator.pop(ctx),
            child:const Text('Cancelar')),
          FilledButton(onPressed:()=>Navigator.pop(ctx,noteInput.text),
            child:const Text('Salvar trecho')),
        ]));
    noteInput.dispose();
    if(message==null)return;
    final next=List<Map<String,dynamic>>.from(_highlights)
      ..add(<String,dynamic>{
        'page':_page,'start':start,'end':end,'text':quote,
        if(html)...{
          'htmlBlock':_htmlBlock,'htmlStart':_htmlStart,
          'htmlEnd':_htmlEnd,
        },
        'note':message.trim(),
        'savedAt':DateTime.now().toIso8601String(),
      });
    try {
      await _saveHighlights(next);
      _notify('Trecho marcado e anotação gravados.');
      if(mounted)setState((){
        _selectionStart=null;_selectionEnd=null;
        _htmlQuote='';_htmlBlock='';
      });
    } catch(e) {
      _notify('Trecho não salvo: $e');
    }
  }

  List<TextSpan> _spans(String text) {
    final marks=_highlights.where((m)=>m['page']==_page)
      .map((m)=>ReaderMark(m['start'] as int,m['end'] as int))
      .toList(growable:false);
    return SourceTypography.spans(
      text,fontSize:_font,
      color:Theme.of(context).colorScheme.onSurface,
      highlights:marks);
  }

  void _selectionChanged(TextSelection selection,SelectionChangedCause? cause) {
    if(!selection.isValid || selection.isCollapsed)return;
    final start=selection.start;
    final end=selection.end;
    if(start<0 || end>_pageText.length || end<=start)return;
    if(start==_selectionStart && end==_selectionEnd)return;
    setState((){
      _selectionStart=start;_selectionEnd=end;
    });
  }

  Future<void> _openMarks() async {
    await showModalBottomSheet<void>(
      context:context,isScrollControlled:true,
      builder:(ctx)=>SafeArea(child:ConstrainedBox(
        constraints:BoxConstraints(
          maxHeight:MediaQuery.of(ctx).size.height*0.8),
        child:ListView(shrinkWrap:true,padding:const EdgeInsets.all(15),
          children:[
            Text('Trechos e marcadores',
              style:Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height:12),
            if(_highlights.isEmpty && _bookmarks.isEmpty)
              const Text('Ainda não há trechos ou páginas marcados.'),
            for(final page in _bookmarks.toList()..sort())
              ListTile(leading:const Icon(Icons.bookmark),
                title:Text('Página de leitura ${page+1}'),
                onTap:(){
                  Navigator.pop(ctx);_moveTo(page);
                }),
            for(final annotation in _highlights)
              ListTile(
                isThreeLine:true,
                leading:const Icon(Icons.highlight),
                title:Text(annotation['text'].toString(),maxLines:2,
                  overflow:TextOverflow.ellipsis),
                subtitle:Text('Tela ${(annotation['page'] as int)+1}'
                  '${annotation['note'].toString().isEmpty?'':': '+annotation['note'].toString()}',
                  maxLines:2,overflow:TextOverflow.ellipsis),
                onTap:(){
                  Navigator.pop(ctx);
                  _moveTo(annotation['page'] as int);
                },
                trailing:IconButton(
                  tooltip:'Excluir trecho salvo',
                  icon:const Icon(Icons.delete_outline),
                  onPressed:() async {
                    final next=List<Map<String,dynamic>>.from(_highlights)
                      ..remove(annotation);
                    try {
                      await _saveHighlights(next);
                      if(ctx.mounted)Navigator.pop(ctx);
                      _notify('Trecho removido.');
                    } catch(e){
                      _notify('Não foi possível remover: $e');
                    }
                  })),
            const SizedBox(height:10),
          ]))),
    );
  }

  Future<void> _choosePage() async {
    final book=_book;
    if(book==null)return;
    var index=_page;
    final target=await showDialog<int>(
      context:context,
      builder:(ctx)=>StatefulBuilder(builder:(ctx,update)=>
        AlertDialog(
          title:const Text('Ir para uma tela'),
          content:Column(mainAxisSize:MainAxisSize.min,children:[
            Text('${index+1} de ${book.screens.length}'),
            Slider(
              min:0,max:(book.screens.length-1).toDouble(),
              divisions:book.screens.length>1?book.screens.length-1:null,
              value:index.toDouble(),
              onChanged:(v)=>update(()=>index=v.round())),
            if(!book.exactPdfPages)
              const Text('A numeração refere-se à leitura ajustável, '
                'não à página física do PDF.',
                style:TextStyle(fontSize:12)),
          ]),
          actions:[
            TextButton(onPressed:()=>Navigator.pop(ctx),
              child:const Text('Cancelar')),
            FilledButton(onPressed:()=>Navigator.pop(ctx,index),
              child:const Text('Ir')),
          ],
        )));
    if(target!=null)await _moveTo(target);
  }

  void _openTutor({String? question}) {
    final body=_pageText;
    if(body.isEmpty)return;
    final selected=_htmlReading && _htmlQuote.isNotEmpty?_htmlQuote:
      (_selectionStart!=null && _selectionEnd!=null?
        body.substring(_selectionStart!,_selectionEnd!):null);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder:(_)=>BookTutorScreen(
        chapter:_chapter,title:_title,pageLabel:_label,
        sourceText:body,selectedQuote:selected,
        getApiKey:widget.getApiKey,model:widget.textModel)));
  }
  void _openExercises() {
    final book=_book;
    if(book==null)return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder:(_)=>BookExercisesScreen(book:book,title:_title,
        openTutor:_openTutor)));
  }
  void _openVoice(){
    final body=_pageText;
    if(body.isEmpty)return;
    final selected=_htmlReading && _htmlQuote.isNotEmpty?_htmlQuote:
      (_selectionStart!=null && _selectionEnd!=null?
        body.substring(_selectionStart!,_selectionEnd!):'');
    final reading=selected.isNotEmpty?selected:body;
    showModalBottomSheet<void>(
      context:context,isScrollControlled:true,
      builder:(ctx)=>SafeArea(child:Padding(
        padding:const EdgeInsets.all(12),
        child:SingleChildScrollView(child:Column(
          mainAxisSize:MainAxisSize.min,children:[
            Text(selected.isNotEmpty?'Ouvir trecho destacado':'Ouvir $_label',
              style:Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height:8),
            VoiceReaderV2(
              key:ValueKey('bookvoice_${_chapter}_${_page}'),
              readText:reading,
              getApiKey:widget.getApiKey,
              speechModel:widget.speechModel),
          ])))),
    );
  }

  @override
  Widget build(BuildContext context){
    final book=_book;
    return Scaffold(
      appBar:AppBar(
        title:Text('Cap. ${_chapter.toString().padLeft(2,'0')} · $_title',
          maxLines:1,overflow:TextOverflow.ellipsis),
        actions:[
          IconButton(tooltip:'Exercícios do PDF',
            onPressed:book==null?null:_openExercises,
            icon:const Icon(Icons.assignment_outlined)),
          IconButton(tooltip:'Trechos salvos',
            onPressed:book==null?null:_openMarks,
            icon:const Icon(Icons.collections_bookmark_outlined)),
          IconButton(tooltip:'PDF original (figuras e tabelas)',
            onPressed:widget.onOpenPdf==null?null:
              ()=>widget.onOpenPdf!(_chapter),
            icon:const Icon(Icons.picture_as_pdf_outlined)),
        ]),
      body:SafeArea(child:_loading?
        const Center(child:CircularProgressIndicator()):
        book==null?
          Center(child:Padding(
            padding:const EdgeInsets.all(24),child:Text(_error))):
        Column(children:[
          Padding(padding:const EdgeInsets.fromLTRB(14,8,14,8),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Row(children:[
                const Icon(Icons.menu_book_outlined,color:forest),
                const SizedBox(width:8),
                Expanded(child:Text('Enciclopédia — leitura integral',
                  style:Theme.of(context).textTheme.titleMedium)),
                PopupMenuButton<int>(
                  tooltip:'Escolher outro capítulo',
                  initialValue:_chapter,
                  onSelected:_load,
                  itemBuilder:(_)=>widget.catalog.map((entry)=>
                    PopupMenuItem<int>(value:entry.number,
                      child:Text('${entry.number.toString().padLeft(2,'0')} — ${entry.title}',
                        maxLines:2))).toList(),
                  child:const Padding(
                    padding:EdgeInsets.all(9),child:Icon(Icons.list_alt)),
                ),
              ]),
              Text(_label,style:const TextStyle(
                fontSize:12,color:forest,fontWeight:FontWeight.w600)),
              const SizedBox(height:7),
              LinearProgressIndicator(
                value:(_page+1)/book.screens.length,minHeight:5),
              const SizedBox(height:6),
              Row(children:[
                IconButton(tooltip:'Alternar HTML e texto',
                  onPressed:()=>setState((){
                    _htmlReading=!_htmlReading;
                    if(_htmlReading)_renderHtml();
                  }),
                  icon:Icon(_htmlReading?Icons.article_outlined:
                    Icons.html)),
                IconButton(tooltip:'Diminuir fonte',
                  onPressed:_font<=14?null:()=>_changeFont(_font-1),
                  icon:const Icon(Icons.text_decrease)),
                Text('${_font.toStringAsFixed(0)} pt'),
                IconButton(tooltip:'Aumentar fonte',
                  onPressed:_font>=26?null:()=>_changeFont(_font+1),
                  icon:const Icon(Icons.text_increase)),
                const Spacer(),
                IconButton(
                  tooltip:'Marcar/desmarcar tela',
                  onPressed:_bookmark,
                  icon:Icon(_bookmarks.contains(_page)?
                    Icons.bookmark:Icons.bookmark_outline)),
              ]),
              if(_hasSelection)
                Align(alignment:Alignment.centerRight,
                  child:TextButton.icon(onPressed:_markSelection,
                    icon:const Icon(Icons.border_color_outlined,size:17),
                    label:const Text('Salvar trecho selecionado'))),
            ])),
          Expanded(child:_htmlReading && _htmlController!=null?
            WebViewWidget(controller:_htmlController!):
            Scrollbar(
              controller:_scroll,
              child:SingleChildScrollView(
                key:ValueKey('reading_$_chapter'+'_$_page'),
                controller:_scroll,
                padding:const EdgeInsets.fromLTRB(18,16,18,34),
                child:Column(
                  crossAxisAlignment:CrossAxisAlignment.start,children:[
                    SelectableText.rich(TextSpan(children:_spans(_pageText)),
                      onSelectionChanged:_selectionChanged,
                      textAlign:TextAlign.justify,
                      style:TextStyle(
                        fontSize:_font,height:1.68,
                        color:Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height:14),
                    if(!book.exactPdfPages)const Text(
                      'Texto extraído do PDF e ajustado à tela. As telas '
                      'não correspondem às páginas impressas; confira '
                      'figuras, fórmulas e tabelas no PDF original.',
                      style:TextStyle(fontSize:12,height:1.45)),
                  ])))),
          Padding(padding:const EdgeInsets.symmetric(
            horizontal:10,vertical:5),
            child:Wrap(
              alignment:WrapAlignment.center,
              spacing:8,runSpacing:4,
              children:[
                OutlinedButton.icon(
                  onPressed:_openVoice,
                  icon:const Icon(Icons.record_voice_over),
                  label:const Text('Ouvir')),
                FilledButton.icon(
                  onPressed:_openTutor,
                  icon:const Icon(Icons.psychology),
                  label:const Text('Gemini')),
                OutlinedButton.icon(
                  onPressed:_openExercises,
                  icon:const Icon(Icons.edit_note),
                  label:const Text('Exercícios')),
              ])),
          Padding(padding:const EdgeInsets.symmetric(horizontal:8),
            child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,
              children:[
                IconButton(
                  tooltip:'Tela anterior',
                  onPressed:_page==0?null:()=>_moveTo(_page-1),
                  icon:const Icon(Icons.chevron_left,size:29)),
                TextButton(onPressed:_choosePage,
                  child:Text(_label)),
                IconButton(
                  tooltip:'Próxima tela',
                  onPressed:_page>=book.screens.length-1?null:
                    ()=>_moveTo(_page+1),
                  icon:const Icon(Icons.chevron_right,size:29)),
              ])),
        ]),
    ));
  }
}
