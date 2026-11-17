import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/offline_library.dart';
import 'lesson_blueprints.dart';
import 'lesson_depth_view.dart';
import 'lesson_depth_model.dart';
import 'practice_stations.dart';

/// Android-first guided learning. This route is a native lesson with exercises,
/// not a PDF wrapper. The source PDF remains a separate optional reference.
/// Completing a check question never certifies forensic competence.
class GuidedLessonScreen extends StatefulWidget {
  const GuidedLessonScreen({
    super.key, required this.chapterNumber, required this.chapterTitle,
    required this.library, this.onOpenPdf, this.onProgress,
  });
  final int chapterNumber;
  final String chapterTitle;
  final OfflineLibrary library;
  final Future<void> Function()? onOpenPdf;
  final VoidCallback? onProgress;

  @override
  State<GuidedLessonScreen> createState()=>_GuidedLessonScreenState();
}

class _GuidedLessonScreenState extends State<GuidedLessonScreen> {
  static const _forest=Color(0xFF215642);
  late final LessonBlueprint _lesson;
  late final LessonDeepPlan _deep;
  int _stage=0;
  int? _selected;
  bool _checked=false;
  bool _experimented=false;
  bool _completed=false;
  bool _hasOriginal=false;

  @override
  void initState(){
    super.initState();
    _lesson=blueprintForChapter(widget.chapterNumber);
    _deep=extendedLessonForChapter(widget.chapterNumber);
    _hasOriginal=widget.library.chapter(widget.chapterNumber)!=null;
    _loadProgress();
  }
  Future<void> _loadProgress() async {
    try {
      final prefs=await SharedPreferences.getInstance();
      if(mounted) setState(()=>_completed=
        prefs.getBool('academia_lesson_correct_${widget.chapterNumber}')??false);
    } catch (_) {
      // A credential or preference store failure cannot produce a false pass.
    }
  }
  Future<void> _checkAnswer() async {
    if(_selected==null)return;
    if(_selected!=_lesson.correct) {
      setState(()=>_checked=true);
      return;
    }
    if(!_experimented) {
      setState(()=>_checked=true);
      return;
    }
    setState(() {
      _checked=true;
      _completed=true;
    });
    try {
      final prefs=await SharedPreferences.getInstance();
      final saved=await prefs.setBool(
        'academia_lesson_correct_${widget.chapterNumber}',true);
      if (!saved && mounted) {
        setState(()=>_completed=false);
      } else {
        widget.onProgress?.call();
      }
    } catch (_) {
      if(mounted) setState(()=>_completed=false);
    }
  }
  void _changeStage(int value){
    setState(() {
      _stage=value;
      if(value==2) _checked=false;
    });
  }
  Widget _headline(String label,String title,String description) {
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(label.toUpperCase(),style:const TextStyle(
        color:_forest,fontWeight:FontWeight.bold,letterSpacing:1.5,fontSize:11)),
      const SizedBox(height:7),
      Text(title,style:Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight:FontWeight.w800)),
      const SizedBox(height:10),
      Text(description,style:const TextStyle(fontSize:16,height:1.48)),
    ]);
  }

  Widget _learn(){
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _headline('01 · Compreender',_lesson.focus,
        'Estude os conceitos em sequência. Cada seção tem explicação, '
        'caso trabalhado e uma questão para analisar antes do próximo passo.'),
      const SizedBox(height:18),
      DeepLessonArticle(
        plan:_deep,chapterNumber:widget.chapterNumber),
      const SizedBox(height:16),
      FilledButton.icon(
        onPressed:()=>_changeStage(1),
        icon:const Icon(Icons.account_tree_outlined),
        label:const Text('Ver exemplo visual')),
    ]);
  }

  Widget _visual(){
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _headline('02 · Visualizar','O percurso de uma análise',
        'Explore os elementos desta disciplina. O formato do diagrama '
        'muda conforme a técnica: pode ser linha do tempo, matriz, '
        'quadro de fontes, código comentado ou gráfico de dados.'),
      const SizedBox(height:16),
      TopicDiagram(plan:_deep,chapter:widget.chapterNumber),
      const SizedBox(height:21),
      FilledButton.icon(
        onPressed:()=>_changeStage(2),
        icon:const Icon(Icons.science_outlined),
        label:const Text('Experimentar na prática')),
    ]);
  }

  Widget _experiment(){
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _headline('03 · Experimentar','Laboratório com resultado observável',
        'Execute a atividade própria deste assunto. O resultado é calculado '
        'a partir de suas entradas e registrado como exercício, '
        'não como prova de competência profissional.'),
      const SizedBox(height:18),
      PracticeStation(
        key:ValueKey('station-${widget.chapterNumber}'),
        chapter:widget.chapterNumber,
        plan:_deep,
        onPerformed:(){
          if(mounted)setState(()=>_experimented=true);
        }),
      const SizedBox(height:19),
      FilledButton.icon(
        onPressed:_experimented?()=>_changeStage(3):null,
        icon:const Icon(Icons.quiz_outlined),
        label:Text(_experimented?'Aplicar o que aprendi':
          'Conclua e interprete o experimento para avançar')),
    ]);
  }

  Widget _apply(){
    final correct=_selected==_lesson.correct;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _headline('04 · Verificar','Você consegue justificar a conclusão?',
        'Escolha uma interpretação para o problema. O resultado é '
        'formativo e só é salvo após uma atividade efetivamente realizada.'),
      const SizedBox(height:18),
      Container(
        width:double.infinity,padding:const EdgeInsets.all(20),
        decoration:BoxDecoration(
          color:const Color(0xFF173D32),
          borderRadius:BorderRadius.circular(15)),
        child:Text(_lesson.question,style:const TextStyle(
          color:Colors.white,fontSize:18.5,
          fontWeight:FontWeight.w600,height:1.4))),
      const SizedBox(height:18),
      for(var i=0;i<_lesson.choices.length;i++)
        Padding(padding:const EdgeInsets.only(bottom:10),
          child:Material(
            color:_selected==i?const Color(0xFFDFF1E7):
              const Color(0xFFF6F8F6),
            borderRadius:BorderRadius.circular(12),
            child:InkWell(
              borderRadius:BorderRadius.circular(12),
              onTap:()=>setState((){
                _selected=i;
                _checked=false;
              }),
              child:Padding(padding:const EdgeInsets.all(15),
                child:Row(children:[
                  Icon(_selected==i?Icons.radio_button_checked:
                    Icons.radio_button_off,
                    color:const Color(0xFF215642)),
                  const SizedBox(width:11),
                  Expanded(child:Text(_lesson.choices[i],
                    style:const TextStyle(fontSize:15.4,height:1.45))),
                ])))),
        ),
      const SizedBox(height:12),
      FilledButton.icon(
        onPressed:_selected==null?null:_checkAnswer,
        icon:const Icon(Icons.fact_check),
        label:const Text('Conferir minha resposta')),
      if(_checked)...[
        const SizedBox(height:18),
        Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Icon(correct?Icons.check_circle_outline:Icons.error_outline,
            color:correct?const Color(0xFF246E43):const Color(0xFFA26712)),
          const SizedBox(width:10),
          Expanded(child:Text(!correct?
              'A alternativa escolhida extrapola os dados. Revise o '
              'raciocínio e tente novamente.':
              !_experimented?
                'A resposta é correta, mas conclua o laboratório antes de '
                'registrar o progresso.':
              _completed?
                'Resposta correta, laboratório realizado e progresso '
                'registrado no dispositivo.':
                'Resposta correta, mas a persistência ainda não foi confirmada.',
            style:const TextStyle(fontSize:15.3,
              fontWeight:FontWeight.w700))),
        ]),
        const SizedBox(height:12),
        Container(width:double.infinity,padding:const EdgeInsets.all(16),
          decoration:BoxDecoration(
            border:const Border(left:BorderSide(
              color:Color(0xFF256449),width:4)),
            color:const Color(0xFFF3F6F1)),
          child:Text(_lesson.feedback,
            style:const TextStyle(fontSize:15,height:1.48))),
      ],
      if(_completed)...[
        const SizedBox(height:18),
        const Text('Lição didática concluída.',
          style:TextStyle(fontSize:17,fontWeight:FontWeight.bold)),
        const Text('A conclusão é somente desta atividade. '
          'Não representa certificação ou proficiência profissional.'),
      ],
      if(!_experimented)...[
        const SizedBox(height:14),
        OutlinedButton(
          onPressed:()=>_changeStage(2),
          child:const Text('Voltar à atividade prática')),
      ],
      const SizedBox(height:18),
      OutlinedButton.icon(
        onPressed:widget.onOpenPdf,
        icon:const Icon(Icons.menu_book_outlined),
        label:Text(_hasOriginal?
          'Conferir no PDF original':
          'Abrir material original para aprofundamento')),
    ]);
  }
  @override
  Widget build(BuildContext context){
    const stages=['Entender','Visualizar','Experimentar','Aplicar'];
    final index=_stage;
    return Scaffold(
      appBar:AppBar(
        title:Text('Aula ${widget.chapterNumber.toString().padLeft(2,'0')}',
          overflow:TextOverflow.ellipsis),
        actions:[
          if(_completed) const Tooltip(
            message:'Lição respondida corretamente e salva',
            child:Padding(padding:EdgeInsets.only(right:14),
              child:Icon(Icons.verified_outlined,color:_forest))),
        ],
      ),
      body:SafeArea(child:Center(child:ConstrainedBox(
        constraints:const BoxConstraints(maxWidth:880),
        child:ListView(
          padding:const EdgeInsets.all(16),
          children:[
            Text('FORMAÇÃO FORENSE · AULA INTERATIVA',
              style:Theme.of(context).textTheme.labelMedium?.copyWith(
                color:_forest,fontWeight:FontWeight.w800,letterSpacing:1.1)),
            const SizedBox(height:8),
            Text(widget.chapterTitle,
              style:Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight:FontWeight.bold)),
            const SizedBox(height:8),
            const Text('Uma aula elaborada para o aplicativo, com explicações '
              'e experimentos. O PDF original é fonte de aprofundamento, '
              'não a interface principal.'),
            const SizedBox(height:18),
            SingleChildScrollView(scrollDirection:Axis.horizontal,
              child:Row(children:[
                for(var i=0;i<4;i++) Padding(
                  padding:const EdgeInsets.only(right:8),
                  child:ChoiceChip(
                    label:Text('${i+1}. ${stages[i]}'),
                    selected:index==i,
                    onSelected:(_)=>_changeStage(i))),
              ])),
            const SizedBox(height:14),
            LinearProgressIndicator(
              minHeight:6,
              value:_completed?1.0:(index+1)/4,
              borderRadius:BorderRadius.circular(10)),
            const SizedBox(height:25),
            if(index==0) _learn()
            else if(index==1) _visual()
            else if(index==2) _experiment()
            else _apply(),
            const SizedBox(height:25),
            const Divider(),
            const Text('Referência técnica: use o capítulo original para '
              'confirmar detalhes, pressupostos e fontes bibliográficas. '
              'Exercícios simulados não substituem treinamento supervisionado.',
              style:TextStyle(fontSize:12,height:1.5)),
            const SizedBox(height:30),
          ],
        ),
      ))),
    );
  }
}
