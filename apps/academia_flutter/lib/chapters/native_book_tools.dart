import 'package:ai_gateway/ai_gateway.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistence_core/persistence_core.dart';

import 'native_book_models.dart';
import 'study_catalog.dart';

class BookTutorScreen extends StatefulWidget {
  const BookTutorScreen({
    super.key,required this.chapter,required this.title,
    required this.pageLabel,required this.sourceText,
    required this.getApiKey,required this.model,this.selectedQuote,
  });
  final int chapter;
  final String title;
  final String pageLabel;
  final String sourceText;
  final String? selectedQuote;
  final Future<String?> Function() getApiKey;
  final String? model;
  @override
  State<BookTutorScreen> createState()=>_BookTutorScreenState();
}
class _BookTutorScreenState extends State<BookTutorScreen> {
  final _question=TextEditingController();
  PedagogicalMode _mode=PedagogicalMode.explicar;
  bool _busy=false;
  String _answer='',_error='';
  @override
  void dispose(){_question.dispose();super.dispose();}
  Future<void> _ask({String? prompt,PedagogicalMode? mode}) async {
    if(_busy)return;
    final question=(prompt??_question.text).trim();
    if(question.isEmpty){
      setState(()=>_error='Digite uma dúvida ou escolha um exemplo.');
      return;
    }
    if(mode!=null)_mode=mode;
    setState(() {_busy=true;_error='';_answer='';});
    try {
      final key=await widget.getApiKey();
      final model=widget.model;
      if(key==null || key.isEmpty || model==null || model.isEmpty) {
        throw StateError('Configure a chave Gemini e escolha o modelo em Meu Espaço.');
      }
      final excerpt=(widget.selectedQuote??'').trim();
      final source=widget.sourceText;
      final context=source.length>5500?source.substring(0,5500):source;
      final task=excerpt.isEmpty?question:
        'Trecho destacado pelo estudante: "${excerpt.length>1500?excerpt.substring(0,1500):excerpt}".\n'
        'Pergunta sobre este trecho: $question';
      final response=await GeminiGatewayClient(
        secureVault:InMemorySecureVault()).queryTutor(
        apiKey:key,modelId:model,mode:_mode,userQuery:task,
        contextChunks:[RagDocumentChunkRef(
          chunkId:'book_${widget.chapter}_${widget.pageLabel}',
          text:context,editorialStatus:'Em revisão',
          volume:StudyCatalog.volumeFor(widget.chapter),
          chapter:widget.chapter,page:1,
        )],chapterTitle:widget.title);
      if(!mounted)return;
      if(response.trim().isEmpty) {
        throw StateError('A API não retornou explicação.');
      }
      setState(()=>_answer=response.trim());
    } catch(e) {
      if(mounted)setState(()=>_error='Consulta não concluída: $e');
    } finally {
      if(mounted)setState(()=>_busy=false);
    }
  }
  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Professor Gemini')),
    body:SafeArea(child:ListView(padding:const EdgeInsets.all(18),children:[
      Text(widget.title,style:Theme.of(context).textTheme.titleLarge),
      const SizedBox(height:4),
      Text('Referência: ${widget.pageLabel}. O professor consulta o texto '
        'do capítulo aberto, não inventa fontes.'),
      if((widget.selectedQuote??'').trim().isNotEmpty)
        Padding(padding:const EdgeInsets.symmetric(vertical:12),
          child:Container(
            padding:const EdgeInsets.all(14),
            decoration:BoxDecoration(
              color:const Color(0xFFFFF2C7),
              borderRadius:BorderRadius.circular(12)),
            child:Text('Trecho selecionado:\n${widget.selectedQuote}',
              maxLines:12,overflow:TextOverflow.ellipsis))),
      const SizedBox(height:14),
      Wrap(spacing:8,runSpacing:8,children:[
        ActionChip(label:const Text('Explique melhor'),
          onPressed:_busy?null:()=>_ask(
            prompt:'Explique com mais detalhes e de forma progressiva o '
              'conceito central deste trecho. Defina todos os termos técnicos.',
            mode:PedagogicalMode.explicar)),
        ActionChip(label:const Text('Dê um exemplo'),
          onPressed:_busy?null:()=>_ask(
            prompt:'Crie um exemplo didático ORIGINAL e claramente '
              'fictício que demonstre este conceito passo a passo. '
              'Separe os fatos extraídos da fonte dos detalhes inventados no exemplo.',
            mode:PedagogicalMode.exemplificar)),
        ActionChip(label:const Text('Aprofundar'),
          onPressed:_busy?null:()=>_ask(
            prompt:'Aprofunde a explicação metodológica e mostre '
              'pressupostos, limitações, cálculos e como testar o resultado. '
              'Não afirme que o PDF diz algo sem apoio no trecho fornecido.',
            mode:PedagogicalMode.aprofundar)),
        ActionChip(label:const Text('Me testar'),
          onPressed:_busy?null:()=>_ask(
            prompt:'Elabore uma questão aberta e contextualizada '
              'sobre o texto, sem dar a resposta ainda.',
            mode:PedagogicalMode.meTestar)),
      ]),
      const SizedBox(height:20),
      DropdownButtonFormField<PedagogicalMode>(
        value:_mode,isExpanded:true,
        decoration:const InputDecoration(
          labelText:'Modo de atendimento',border:OutlineInputBorder()),
        items:PedagogicalMode.values.map((m)=>DropdownMenuItem(
          value:m,child:Text(m.value))).toList(),
        onChanged:_busy?null:(value){if(value!=null)setState(()=>_mode=value);}),
      const SizedBox(height:12),
      TextField(controller:_question,minLines:2,maxLines:6,
        textCapitalization:TextCapitalization.sentences,
        decoration:const InputDecoration(
          labelText:'Sua dúvida',
          hintText:'Por que isso acontece? Como eu aplico este procedimento?',
          border:OutlineInputBorder())),
      const SizedBox(height:12),
      FilledButton.icon(onPressed:_busy?null:()=>_ask(),
        icon:const Icon(Icons.send),
        label:Text(_busy?'Consultando o Gemini...':'Perguntar sobre este trecho')),
      if(_busy)const Padding(padding:EdgeInsets.all(18),
        child:LinearProgressIndicator()),
      if(_error.isNotEmpty)Padding(padding:const EdgeInsets.only(top:14),
        child:Text(_error,style:TextStyle(
          color:Theme.of(context).colorScheme.error))),
      if(_answer.isNotEmpty) Padding(
        padding:const EdgeInsets.only(top:20),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Explicação',style:Theme.of(context).textTheme.titleLarge),
          const SizedBox(height:10),
          SelectableText(_answer,style:const TextStyle(
            fontSize:16.5,height:1.65)),
          const SizedBox(height:15),
          const Text('Resposta gerada por IA. Compare referências, '
            'cálculos e afirmações com o texto original antes de adotar '
            'conclusões técnicas.',
            style:TextStyle(fontSize:12,height:1.5)),
        ])),
    ])),
  );
}

/// The question sheet uses the actual exercise section in the supplied PDF.
/// Writing a response does NOT imply passing or any automated score.
class BookExercisesScreen extends StatefulWidget {
  const BookExercisesScreen({super.key,required this.book,required this.title,
    required this.openTutor});
  final BookChapter book;
  final String title;
  final VoidCallback openTutor;
  @override
  State<BookExercisesScreen> createState()=>_BookExercisesScreenState();
}
class _BookExercisesScreenState extends State<BookExercisesScreen> {
  final _answer=TextEditingController();
  bool _showKey=false,_saving=false;
  String _status='';
  late final SourceExerciseSections _source;
  String get _key=>'academy_source_exercise_notes_${widget.book.chapter}';

  @override
  void initState(){
    super.initState();
    final structured=widget.book.screens.expand((s)=>s.layout).toList();
    final exercises=structured.where((b)=>b['kind']=='exercise'||b['kind']=='lab').map((b)=>b['text'].toString()).join('\n\n');
    final answers=structured.where((b)=>b['kind']=='answer').map((b)=>b['text'].toString()).join('\n\n');
    _source=exercises.isEmpty?SourceExerciseSections.fromOriginal(widget.book.completeText):SourceExerciseSections(exercises:exercises,answerKey:answers);
    _loadAnswer();
  }
  Future<void> _loadAnswer() async {
    try {
      final prefs=await SharedPreferences.getInstance();
      if(mounted)_answer.text=prefs.getString(_key)??'';
    } catch (_) {
      if(mounted)setState(()=>_status='Respostas anteriores não puderam ser carregadas.');
    }
  }
  Future<void> _save() async {
    if(_saving)return;
    setState(()=>_saving=true);
    try {
      final prefs=await SharedPreferences.getInstance();
      final written=await prefs.setString(_key,_answer.text);
      if(!written || prefs.getString(_key)!=_answer.text) {
        throw StateError('Não foi possível confirmar a gravação.');
      }
      if(mounted)setState(()=>_status='Seu rascunho foi salvo neste aparelho.');
    } catch(e) {
      if(mounted)setState(()=>_status='Falha ao salvar: $e');
    } finally {
      if(mounted)setState(()=>_saving=false);
    }
  }
  @override
  void dispose(){_answer.dispose();super.dispose();}
  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Exercícios do capítulo')),
    body:SafeArea(child:ListView(padding:const EdgeInsets.all(18),children:[
      Text(widget.title,style:Theme.of(context).textTheme.titleLarge),
      const SizedBox(height:10),
      const Text('Estes enunciados foram extraídos da seção de exercícios '
        'do PDF fornecido, sem criar perguntas genéricas. Confira fórmulas, '
        'figuras e tabelas no arquivo original.'),
      const SizedBox(height:16),
      if(!_source.hasExercises)
        const Text('Não encontrei uma seção de exercícios reconhecível '
          'na transcrição. Consulte a parte correspondente do capítulo '
          'original — nenhuma questão foi inventada.')
      else Container(
        padding:const EdgeInsets.all(16),
        decoration:BoxDecoration(
          borderRadius:BorderRadius.circular(13),
          border:Border.all(color:const Color(0xFFB8C8BE))),
        child:SelectableText(_source.exercises,
          style:const TextStyle(fontSize:16.5,height:1.65))),
      const SizedBox(height:24),
      Text('Seu caderno de respostas',
        style:Theme.of(context).textTheme.titleMedium),
      const SizedBox(height:10),
      TextField(controller:_answer,minLines:6,maxLines:15,
        textCapitalization:TextCapitalization.sentences,
        decoration:const InputDecoration(
          labelText:'Responda e mostre seus cálculos',
          hintText:'Exercício 1:\nMeu raciocínio:\nResultado:\nLimitações:',
          border:OutlineInputBorder())),
      const SizedBox(height:10),
      FilledButton.icon(onPressed:_saving?null:_save,
        icon:const Icon(Icons.save_outlined),
        label:Text(_saving?'Salvando...':'Salvar respostas')),
      if(_status.isNotEmpty)Padding(
        padding:const EdgeInsets.symmetric(vertical:8),child:Text(_status)),
      const SizedBox(height:18),
      if(_source.hasAnswerKey)...[
        OutlinedButton.icon(
          onPressed:()=>setState(()=>_showKey=!_showKey),
          icon:Icon(_showKey?Icons.visibility_off:Icons.fact_check),
          label:Text(_showKey?'Ocultar gabarito do PDF':
            'Conferir gabarito original')),
        if(_showKey)Padding(
          padding:const EdgeInsets.symmetric(vertical:15),
          child:SelectableText(_source.answerKey,
            style:const TextStyle(fontSize:15.5,height:1.62))),
      ]else const Text('Este capítulo não possui gabarito identificado '
        'automaticamente na transcrição. Nenhuma aprovação será simulada.'),
      const SizedBox(height:14),
      OutlinedButton.icon(onPressed:widget.openTutor,
        icon:const Icon(Icons.psychology_alt_outlined),
        label:const Text('Pedir orientação ao Gemini')),
      const SizedBox(height:20),
    ])),
  );
}
