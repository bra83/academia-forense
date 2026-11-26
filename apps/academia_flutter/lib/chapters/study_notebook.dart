import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'study_catalog.dart';

String studyFold(String input) {
  var text=input.toLowerCase();
  const from='áàâãäéèêëíìîïóòôõöúùûüç';
  const to='aaaaaeeeeiiiiooooouuuuc';
  for(var i=0;i<from.length;i++){text=text.replaceAll(from[i],to[i]);}
  return text.replaceAll('\u00ad','').replaceAll(RegExp(r'\s+'),' ').trim();
}
class StudyNotebook extends StatefulWidget {
  const StudyNotebook({super.key,required this.catalog,required this.openChapter});
  final List<StudyChapter> catalog;
  final Future<void> Function(int,int,String?) openChapter;
  @override
  State<StudyNotebook> createState()=>_StudyNotebookState();
}
class _StudyNotebookState extends State<StudyNotebook>{
  List<({int chapter,Map<String,dynamic> data})> _entries=[];
  String _query='',_error='';
  bool _loading=true;
  int? _chapterFilter;
  String _key(int n)=>'source_reader_highlights_$n';
  List<Map<String,dynamic>> _read(SharedPreferences p,int n){
    final raw=p.getString(_key(n));
    if(raw==null)return [];
    return (jsonDecode(raw) as List).map((x)=>Map<String,dynamic>.from(x as Map)).toList();
  }
  String _title(int number){
    for(final c in widget.catalog){if(c.number==number)return c.title;}
    return 'Capítulo $number (não importado)';
  }
  @override
  void initState(){super.initState();_load();}
  Future<void> _load() async {
    try{
      final p=await SharedPreferences.getInstance();
      final entries=<({int chapter,Map<String,dynamic> data})>[];
      final issues=<int>[];
      for(final key in p.getKeys().where((s)=>s.startsWith('source_reader_highlights_'))){
        final n=int.tryParse(key.substring('source_reader_highlights_'.length));
        if(n==null)continue;
        try{for(final d in _read(p,n)){entries.add((chapter:n,data:d));}}
        catch(_){issues.add(n);}
      }
      entries.sort((a,b)=>(b.data['savedAt']??'').toString().compareTo((a.data['savedAt']??'').toString()));
      if(mounted)setState((){_entries=entries;_loading=false;_error=issues.isEmpty?'':'Notas não legíveis; dados preservados: '+issues.join(', ');});
    }catch(e){if(mounted)setState((){_loading=false;_error='Caderno indisponível: $e';});}
  }
  Future<void> _modify(int n,Map<String,dynamic> original,{String? note,bool delete=false}) async {
    try{
      final p=await SharedPreferences.getInstance();
      final records=_read(p,n);
      final idx=records.indexWhere((r)=>jsonEncode(r)==jsonEncode(original));
      if(idx<0)throw StateError('Registro alterado; atualize a lista.');
      if(delete){records.removeAt(idx);}else{records[idx]['note']=note??'';}
      final encoded=jsonEncode(records);
      if(!await p.setString(_key(n),encoded)||p.getString(_key(n))!=encoded)throw StateError('Gravação não confirmada.');
      await _load();
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Não foi possível salvar: $e')));}
  }
  Future<void> _edit(int n,Map<String,dynamic> d) async {
    final ctrl=TextEditingController(text:(d['note']??'').toString());
    final value=await showDialog<String>(context:context,builder:(ctx)=>AlertDialog(
      title:const Text('Editar anotação'),content:TextField(controller:ctrl,minLines:3,maxLines:8,autofocus:true),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Cancelar')),
      FilledButton(onPressed:()=>Navigator.pop(ctx,ctrl.text.trim()),child:const Text('Salvar'))]));
    ctrl.dispose();
    if(value!=null)await _modify(n,d,note:value);
  }
  Future<void> _delete(int n,Map<String,dynamic> d) async {
    final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Excluir este registro?'),
      content:const Text('O texto do capítulo não será alterado.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancelar')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Excluir'))]));
    if(yes==true)await _modify(n,d,delete:true);
  }
  Future<void> _open(int n,Map<String,dynamic> d) async {
    if(!widget.catalog.any((c)=>c.number==n)){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Importe o capítulo para abrir a origem.')));return;
    }
    await widget.openChapter(n,(d['page'] as num?)?.toInt()??0,(d['text']??'').toString());
    if(mounted)await _load();
  }
  @override
  Widget build(BuildContext context){
    final query=studyFold(_query);
    final filtered=_entries.where((e)=>(_chapterFilter==null||e.chapter==_chapterFilter)&&studyFold(e.chapter.toString()+' '+_title(e.chapter)+' '+(e.data['text']??'').toString()+' '+(e.data['note']??'').toString()).contains(query)).toList();
    final chapters=_entries.map((e)=>e.chapter).toSet().toList()..sort();
    return Scaffold(appBar:AppBar(title:const Text('Meu caderno'),actions:[IconButton(onPressed:_load,icon:const Icon(Icons.refresh),tooltip:'Atualizar')]),
      body:Column(children:[
        Padding(padding:const EdgeInsets.all(16),child:Column(children:[
          TextField(onChanged:(v)=>setState(()=>_query=v),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),labelText:'Buscar trechos e anotações',border:OutlineInputBorder())),
          const SizedBox(height:8),
          DropdownButtonFormField<int>(value:chapters.contains(_chapterFilter)?_chapterFilter:null,isExpanded:true,decoration:const InputDecoration(labelText:'Filtrar capítulo'),
            items:[const DropdownMenuItem<int>(value:0,child:Text('Todos os capítulos')),for(final n in chapters)DropdownMenuItem<int>(value:n,child:Text(n.toString()+' — '+_title(n),overflow:TextOverflow.ellipsis))],
            onChanged:(v)=>setState(()=>_chapterFilter=v==0?null:v)),
          Text(filtered.length.toString()+' registro(s)'),
          if(_error.isNotEmpty)Text(_error),
        ])),
        Expanded(child:_loading?const Center(child:CircularProgressIndicator()):filtered.isEmpty?const Center(child:Text('Selecione um trecho no leitor ou faça uma anotação.')):ListView.builder(
          padding:const EdgeInsets.fromLTRB(12,0,12,16),itemCount:filtered.length,itemBuilder:(ctx,i){
            final entry=filtered[i],d=entry.data,n=entry.chapter;
            final quote=(d['text']??'').toString(),note=(d['note']??'').toString();
            return Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('Cap. '+n.toString()+' — '+_title(n),style:Theme.of(ctx).textTheme.titleMedium),
              Text('Posição '+(((d['page'] as num?)??0).toInt()+1).toString()),
              if(quote.isNotEmpty)Padding(padding:const EdgeInsets.symmetric(vertical:8),child:SelectableText(quote)),
              if(note.isNotEmpty)Text('Minha anotação: $note'),
              Wrap(spacing:8,children:[
                FilledButton.tonalIcon(onPressed:()=>_open(n,d),icon:const Icon(Icons.menu_book),label:const Text('Abrir capítulo')),
                IconButton(onPressed:()=>_edit(n,d),icon:const Icon(Icons.edit_outlined),tooltip:'Editar anotação'),
                IconButton(onPressed:()=>_delete(n,d),icon:const Icon(Icons.delete_outline),tooltip:'Excluir registro'),
              ])
            ])));
          })),
      ]));
  }
}
