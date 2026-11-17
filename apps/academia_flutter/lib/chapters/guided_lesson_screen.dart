import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/offline_library.dart';
import 'lesson_blueprints.dart';

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
  final _data=TextEditingController(text:'REGISTRO 001 | evento 14:32');
  int _stage=0;
  int? _selected;
  bool _checked=false;
  bool _experimented=false;
  bool _completed=false;
  bool _hasOriginal=false;
  int _clockDrift=60;
  int _clockUncertainty=10;
  double _prior=0.01;
  double _sensitivity=0.95;
  double _specificity=0.99;
  final _conditions=<bool>[false,false,false];

  @override
  void initState(){
    super.initState();
    _lesson=blueprintForChapter(widget.chapterNumber);
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
  @override
  void dispose(){
    _data.dispose();
    super.dispose();
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
  Widget _card(String label,Widget child,{IconData icon=Icons.lightbulb_outline}){
    return Card(margin:const EdgeInsets.symmetric(vertical:8),
      child:Padding(padding:const EdgeInsets.all(16),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[
            Icon(icon,color:_forest),const SizedBox(width:8),
            Expanded(child:Text(label,style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w700))),
          ]),
          const SizedBox(height:12),child,
        ])));
  }
  Widget _flow(){
    return SingleChildScrollView(
      scrollDirection:Axis.horizontal,
      child:Row(children:[
        for(var i=0;i<_lesson.flow.length;i++) ...[
          Container(
            width:118,
            padding:const EdgeInsets.all(12),
            decoration:BoxDecoration(
              color:i%2==0?const Color(0xFFDEF0E7):const Color(0xFFE7EEFA),
              border:Border.all(color:_forest.withValues(alpha:0.25)),
              borderRadius:BorderRadius.circular(14)),
            child:Column(children:[
              CircleAvatar(radius:16,backgroundColor:_forest,
                child:Text('${i+1}',style:const TextStyle(color:Colors.white))),
              const SizedBox(height:10),
              Text(_lesson.flow[i],textAlign:TextAlign.center,
                style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700)),
            ]),
          ),
          if(i!=_lesson.flow.length-1)
            const Padding(padding:EdgeInsets.symmetric(horizontal:5),
              child:Icon(Icons.arrow_forward_ios,size:13,color:_forest)),
        ],
      ]),
    );
  }
  Widget _learn(){
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _headline('01 · Compreender',_lesson.focus,_lesson.explanation),
      const SizedBox(height:14),
      _card('Por que isso importa?',Text(_lesson.example,
        style:const TextStyle(fontSize:16,height:1.5)),icon:Icons.search),
      _card('Armadilha comum',Text(_lesson.warning,
        style:const TextStyle(fontSize:15,height:1.45)),
        icon:Icons.report_problem_outlined),
      const SizedBox(height:14),
      FilledButton.icon(onPressed:()=>_changeStage(1),
        icon:const Icon(Icons.arrow_forward),
        label:const Text('Ver exemplo visual')),
    ]);
  }
  Widget _visual(){
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _headline('02 · Visualizar','O percurso de uma análise',
        'Cada cartão representa uma etapa que precisa ser explicada, documentada ou conferida. O resultado não aparece por mágica.'),
      const SizedBox(height:20),
      _flow(),
      const SizedBox(height:14),
      _card('Aplicação ao caso',Text(_lesson.example,
        style:const TextStyle(fontSize:16,height:1.48)),
        icon:Icons.account_tree_outlined),
      _card('Limite da inferência',Text(_lesson.warning,
        style:const TextStyle(fontSize:15,height:1.5)),
        icon:Icons.gpp_maybe_outlined),
      const SizedBox(height:14),
      FilledButton.icon(onPressed:()=>_changeStage(2),
        icon:const Icon(Icons.science_outlined),
        label:const Text('Experimentar na prática')),
    ]);
  }
  Widget _hashExperiment(){
    const seed='REGISTRO 001 | evento 14:32';
    final current=sha256.convert(utf8.encode(_data.text)).toString();
    final original=sha256.convert(utf8.encode(seed)).toString();
    final same=current==original;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _card('Arquivo de treino: calcule o SHA-256',Column(
        crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Este texto representa bytes de um artefato fictício. '
            'Edite ao menos um caractere e observe o resumo criptográfico.'),
          const SizedBox(height:12),
          TextField(controller:_data,maxLines:2,
            onChanged:(_)=>setState(()=>_experimented=true),
            decoration:const InputDecoration(border:OutlineInputBorder(),
              labelText:'Conteúdo do arquivo simulado')),
          const SizedBox(height:14),
          const Text('SHA-256 do original:',
            style:TextStyle(fontWeight:FontWeight.bold)),
          SelectableText(original,style:const TextStyle(fontFamily:'monospace',
            fontSize:11)),
          const SizedBox(height:10),
          const Text('SHA-256 do conteúdo atual:',
            style:TextStyle(fontWeight:FontWeight.bold)),
          SelectableText(current,style:const TextStyle(fontFamily:'monospace',
            fontSize:11)),
          const SizedBox(height:14),
          Row(children:[
            Icon(same?Icons.check_circle_outline:Icons.difference_outlined,
              color:same?Colors.green:Colors.orange),
            const SizedBox(width:8),
            Expanded(child:Text(same?'Bytes correspondentes ao texto original':
              'Conteúdo modificado: hashes diferentes')),
          ]),
        ]),icon:Icons.fingerprint),
      const Text('O resultado demonstra diferenças de conteúdo, não autoria, '
        'origem legítima ou significado de uma mensagem.'),
    ]);
  }
  Widget _clockExperiment(){
    final observed=DateTime(2026,1,1,14,32,18);
    final real=observed.subtract(Duration(seconds:_clockDrift));
    final first=real.subtract(Duration(seconds:_clockUncertainty));
    final last=real.add(Duration(seconds:_clockUncertainty));
    String clock(DateTime t)=>t.toIso8601String().substring(11,19);
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _card('Laboratório de relógios',Column(
        crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Câmera: 14:32:18. Ajuste o desvio do relógio e a '
            'incerteza da aferição. Desvio positivo significa adiantamento.'),
          const SizedBox(height:10),
          Text('Desvio observado: ${_clockDrift>0?'+':''}$_clockDrift segundos'),
          Slider(value:_clockDrift.toDouble(),min:-180,max:180,divisions:36,
            label:'$_clockDrift s',onChanged:(v)=>setState(() {
              _clockDrift=v.toInt();_experimented=true;
            })),
          Text('Incerteza estimada (para treino): ± $_clockUncertainty s'),
          Slider(value:_clockUncertainty.toDouble(),min:0,max:120,divisions:24,
            onChanged:(v)=>setState(() {
              _clockUncertainty=v.toInt();_experimented=true;
            })),
          const Divider(),
          Text('Horário corrigido: ${clock(real)}',
            style:Theme.of(context).textTheme.titleLarge),
          Text('Intervalo de possibilidade: ${clock(first)} a ${clock(last)}'),
          const SizedBox(height:8),
          const Text('Hora real estimada = hora mostrada − desvio. '
            'A largura do intervalo é hipótese didática e deve vir de medição.'),
        ]),icon:Icons.schedule),
    ]);
  }
  Widget _bayesExperiment(){
    final truePositive=_prior*_sensitivity;
    final falsePositive=(1-_prior)*(1-_specificity);
    final denominator=truePositive+falsePositive;
    final posterior=denominator==0?0.0:truePositive/denominator;
    String pct(double d)=>(d*100).toStringAsFixed(1)+'%';
    return _card('Simulador de probabilidade condicional',Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Ajuste a frequência da hipótese e o desempenho do teste. '
          'Os valores são sintéticos, não de um método pericial validado.'),
        const SizedBox(height:12),
        Text('Taxa de base: ${pct(_prior)}'),
        Slider(min:0.001,max:0.20,value:_prior,
          onChanged:(v)=>setState(() {_prior=v;_experimented=true;})),
        Text('Sensibilidade: ${pct(_sensitivity)}'),
        Slider(min:0.70,max:1.0,value:_sensitivity,
          onChanged:(v)=>setState(() {_sensitivity=v;_experimented=true;})),
        Text('Especificidade: ${pct(_specificity)}'),
        Slider(min:0.90,max:1.0,value:_specificity,
          onChanged:(v)=>setState(() {_specificity=v;_experimented=true;})),
        const Divider(),
        Text('Probabilidade da hipótese após teste positivo: ${pct(posterior)}',
          style:Theme.of(context).textTheme.titleMedium),
        const SizedBox(height:10),
        const Text('Antes do teste'),
        LinearProgressIndicator(minHeight:14,value:_prior,
          borderRadius:BorderRadius.circular(8)),
        const SizedBox(height:10),
        const Text('Depois de um resultado positivo'),
        LinearProgressIndicator(minHeight:14,value:posterior,
          borderRadius:BorderRadius.circular(8)),
        const SizedBox(height:8),
        const Text('P(H|+) = sensibilidade × prevalência ÷ '
          '[sensibilidade × prevalência + (1 − especificidade) × (1 − prevalência)].'),
      ]),icon:Icons.stacked_line_chart_outlined);
  }
  Widget _generalExperiment(){
    const labels=<String>[
      'Identifiquei a fonte e seu histórico de obtenção',
      'Conferi se o método realmente responde à pergunta',
      'Considerei uma hipótese alternativa e as limitações',
    ];
    return _card('Monte um raciocínio auditável',Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Cenário: ${_lesson.example}'),
        const SizedBox(height:10),
        const Text('Marque as verificações que seriam necessárias '
          'ANTES de sustentar uma conclusão.'),
        for(var i=0;i<labels.length;i++) CheckboxListTile(
          contentPadding:EdgeInsets.zero,
          title:Text(labels[i]),value:_conditions[i],
          onChanged:(v)=>setState((){
            _conditions[i]=v??false;
            _experimented=_conditions.every((b)=>b);
          })),
        const SizedBox(height:8),
        Text(_conditions.every((b)=>b)?
          'Você identificou três verificações metodológicas essenciais. '
          'Ainda é preciso examinar os dados concretos.':
          'Faltam verificações. Identificar lacunas é parte da análise.',
          style:TextStyle(color:_conditions.every((b)=>b)?_forest:Colors.orange.shade800)),
        const SizedBox(height:12),
        Text(_lesson.warning),
      ]),icon:Icons.fact_check_outlined);
  }
  Widget _experiment(){
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _headline('03 · Experimentar','Laboratório com resultado observável',
        'Altere os dados e examine o resultado; a prática só é marcada '
        'quando você interage de verdade.'),
      const SizedBox(height:16),
      if(widget.chapterNumber==1) _hashExperiment()
      else if(widget.chapterNumber==4) _clockExperiment()
      else if(widget.chapterNumber==17 || widget.chapterNumber==25)
        _bayesExperiment()
      else _generalExperiment(),
      const SizedBox(height:18),
      FilledButton.icon(
        onPressed:_experimented?()=>_changeStage(3):null,
        icon:const Icon(Icons.quiz_outlined),
        label:Text(_experimented?'Aplicar o que aprendi':
          'Interaja com a prática para continuar')),
    ]);
  }
  Widget _apply(){
    final correct=_selected==_lesson.correct;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _headline('04 · Verificar','Você consegue justificar a conclusão?',
        'Responda à situação sem adivinhar. A correção será explicada e '
        'poderá ser revista, sem atribuir certificação profissional.'),
      _card('Questão aplicada',Column(
        crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(_lesson.question,style:const TextStyle(
            fontSize:17,fontWeight:FontWeight.w600)),
          const SizedBox(height:10),
          for(var i=0;i<_lesson.choices.length;i++)
            RadioListTile<int>(
              value:i,groupValue:_selected,
              title:Text(_lesson.choices[i]),
              onChanged:(v)=>setState(() {_selected=v;_checked=false;})),
          const SizedBox(height:12),
          FilledButton(
            onPressed:_selected==null?null:_checkAnswer,
            child:const Text('Conferir minha resposta')),
          if(_checked) ...[
            const SizedBox(height:12),
            Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Icon(correct?Icons.check_circle_outline:Icons.info_outline,
                color:correct?Colors.green:Colors.orange),
              const SizedBox(width:8),
              Expanded(child:Text(!correct?
                'Essa alternativa não sustenta a conclusão. Revise e tente outra vez.':
                !_experimented?
                  'Resposta correta, mas realize antes a prática interativa.':
                  _completed?
                    'Resposta correta e prática realizada. Progresso salvo no aparelho.':
                    'Resposta correta, mas não foi possível confirmar a gravação.',
                style:const TextStyle(fontWeight:FontWeight.w700))),
            ]),
            const SizedBox(height:8),
            Text(_lesson.feedback),
          ],
        ]),icon:Icons.rule_outlined),
      const SizedBox(height:12),
      if(_completed) _card('Etapa didática registrada',
        const Text('Esta lição foi respondida corretamente após uma prática. '
          'Isso registra aprendizagem nesta atividade, não proficiência pericial.'),
        icon:Icons.task_alt_outlined),
      if(!_experimented) OutlinedButton(
        onPressed:()=>_changeStage(2),
        child:const Text('Voltar à prática')),
      const SizedBox(height:12),
      OutlinedButton.icon(
        onPressed:widget.onOpenPdf,
        icon:const Icon(Icons.menu_book_outlined),
        label:Text(_hasOriginal?'Conferir explicação no PDF original':
          'Abrir documento original para aprofundar')),
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
