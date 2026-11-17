import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ai_gateway/ai_gateway.dart';
import 'package:persistence_core/persistence_core.dart';
import '../services/offline_library.dart';

class _Question {
  _Question({required this.prompt,required this.options,
    required this.answer,required this.page,required this.explanation});
  final String prompt;
  final List<String> options;
  final int answer;
  final int page;
  final String explanation;
  Map<String,dynamic> toJson()=>{'prompt':prompt,'options':options,
    'answer':answer,'page':page,'explanation':explanation};
}

class AiStudyQuiz extends StatefulWidget {
  const AiStudyQuiz({super.key,required this.chapter,required this.library,
    required this.database,required this.apiKey,required this.model,
    this.onSaved});
  final OfflineChapter chapter;
  final OfflineLibrary library;
  final AppDatabase database;
  final Future<String?> Function() apiKey;
  final String? model;
  final VoidCallback? onSaved;
  @override
  State<AiStudyQuiz> createState()=>_AiStudyQuizState();
}

class _AiStudyQuizState extends State<AiStudyQuiz> {
  List<_Question> _questions=[];
  final Map<int,int> _answers={};
  String _status='';
  bool _busy=false, _completed=false;
  double? _score;

  Future<void> _generate() async {
    setState(() { _busy=true; _status='Preparando questões a partir do texto original...'; });
    try {
      final key=await widget.apiKey();
      if (key==null || key.isEmpty || widget.model==null) {
        throw StateError('Configure a chave e o modelo Gemini primeiro.');
      }
      final pages=(await widget.library.pages(widget.chapter.number))
        .where((p)=>p.text.trim().length>80).toList();
      if (pages.isEmpty) {
        throw StateError('Texto integral não importado. Importe o pacote de conteúdo.');
      }
      // Fixed source pages are recorded for post-hoc verification by the student.
      final selected=pages.take(5).toList();
      final chunks=selected.map((p)=>RagDocumentChunkRef(
        chunkId:'cap' + widget.chapter.number.toString() + '_p' + p.number.toString(),
        text:p.text.length>3500?p.text.substring(0,3500):p.text,
        editorialStatus:'Publicado',
        volume:widget.chapter.number<=10?1:widget.chapter.number<=23?2:3,
        chapter:widget.chapter.number,page:p.number,
      )).toList();
      const instructions=
        'Crie EXATAMENTE 5 questoes de multipla escolha para um estudante '
        'iniciante usando SOMENTE os trechos numerados das paginas acima. '
        'Responda APENAS JSON valido, sem markdown: '
        '{"questions":[{"prompt":"pergunta","options":["a","b","c","d"],'
        '"correct":0,"sourcePage":1,"explanation":"explicacao"}]}. '
        'Todas as alternativas devem ser distintas. Correct vale 0,1,2 ou 3. '
        'sourcePage deve ser uma pagina realmente informada. '
        'Se a fonte nao for suficiente, responda {"questions":[]}.';
      final result=await GeminiGatewayClient(
        secureVault:InMemorySecureVault()).queryTutor(
        apiKey:key,modelId:widget.model!,mode:PedagogicalMode.meTestar,
        userQuery:instructions,
        contextChunks:chunks,
        chapterTitle:widget.chapter.title);
      final start=result.indexOf('{'),end=result.lastIndexOf('}');
      if (start<0 || end<=start) throw const FormatException('IA não retornou JSON.');
      final doc=jsonDecode(result.substring(start,end+1)) as Map<String,dynamic>;
      final items=(doc['questions'] as List<dynamic>? ?? []);
      if (items.length!=5) throw const FormatException('Questões insuficientes.');
      final list=<_Question>[];
      for (final raw in items) {
        final m=raw as Map<String,dynamic>;
        final opts=(m['options'] as List<dynamic>).map((v)=>v.toString()).toList();
        final answer=(m['correct'] as num).toInt();
        final page=(m['sourcePage'] as num).toInt();
        if (opts.length!=4 || answer<0 || answer>=4 ||
            !selected.any((p)=>p.number==page)) {
          throw const FormatException('Questão com fonte ou gabarito inválido.');
        }
        list.add(_Question(
          prompt:m['prompt'].toString(),options:opts,answer:answer,page:page,
          explanation:m['explanation'].toString()));
      }
      if (!mounted) return;
      setState(() {
        _questions=list;_answers.clear();_completed=false;_score=null;
        _status='Questionário gerado por IA. Confira as fontes; não é uma prova certificada.';
      });
    } catch(e) {
      if (mounted) setState(()=>_status=
        'Não foi possível criar a avaliação: '+e.runtimeType.toString()+
        '. Nenhuma nota foi registrada.');
    } finally { if (mounted) setState(()=>_busy=false); }
  }

  Future<void> _submit() async {
    if (_completed || _answers.length!=_questions.length) return;
    setState(()=>_busy=true);
    try {
      final correct=List<int>.generate(_questions.length,(i)=>i)
        .where((i)=>_answers[i]==_questions[i].answer).length;
      final score=correct/_questions.length;
      final passed=score>=0.80;
      final volume=widget.chapter.number<=10?1:widget.chapter.number<=23?2:3;
      final chapterId='forense.vol' + volume.toString().padLeft(2,'0') +
        '.ch' + widget.chapter.number.toString().padLeft(2,'0');
      final id='ai_quiz_' + DateTime.now().microsecondsSinceEpoch.toString();
      await widget.database.transaction(() async {
        await widget.database.assessmentDao.insertAssessment(
          AssessmentsCompanion.insert(
            id:id,chapterId:chapterId,
            title:'Revisão gerada por IA — Capítulo '+widget.chapter.number.toString(),
            questionDataJson:jsonEncode(_questions.map((q)=>q.toJson()).toList()),
            totalQuestions:_questions.length,
            passingBenchmark:const drift.Value(0.8),
          ));
        await widget.database.assessmentDao.recordAttempt(
          AssessmentAttemptsCompanion.insert(
            id:'attempt_'+id,assessmentId:id,
            score:score,passed:passed,
            responsesJson:jsonEncode(_answers),
            discursiveFeedback:const drift.Value(
              'Avaliação formativa por IA; confira sempre as páginas de origem.'),
          ));
      });
      if (!mounted) return;
      setState(() {
        _completed=true;_score=score;
        _status='Resultado gravado: '+(score*100).toStringAsFixed(0)+
          '% — '+(passed?'acima':'abaixo')+' do corte de 80%. '
          'Esse resultado é formativo, não uma certificação.';
      });
      widget.onSaved?.call();
    } catch(e) {
      if (mounted) setState(()=>_status=
        'A avaliação não foi gravada ('+e.runtimeType.toString()+').');
    } finally { if (mounted) setState(()=>_busy=false); }
  }

  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text('Avaliação — Cap. '+widget.chapter.number.toString())),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      Text('Avaliação formativa com fonte',style:Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height:8),
      const Text('As questões são criadas pela IA com referência ao texto dos PDFs '
        'originais importados. Confira as páginas. Aprovação em exercício '
        'não comprova competência profissional.'),
      const SizedBox(height:16),
      FilledButton.icon(
        onPressed:_busy?null:_generate,
        icon:const Icon(Icons.auto_awesome),
        label:Text(_questions.isEmpty?'Gerar 5 questões':'Gerar outro questionário')),
      for (var i=0;i<_questions.length;i++) Card(child:Padding(
        padding:const EdgeInsets.all(12),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text((i+1).toString()+'. '+_questions[i].prompt,
            style:Theme.of(context).textTheme.titleMedium),
          Text('Fonte: capítulo '+widget.chapter.number.toString()+
            ', página '+_questions[i].page.toString()),
          for (var j=0;j<4;j++) RadioListTile<int>(
            title:Text(_questions[i].options[j]),
            value:j,groupValue:_answers[i],
            onChanged:_completed?null:(v){
              if(v!=null)setState(()=>_answers[i]=v);
            }),
          if (_completed) Text(
            'Gabarito: '+_questions[i].options[_questions[i].answer]+
            '\nExplicação: '+_questions[i].explanation,
            style:const TextStyle(fontSize:13)),
        ]),
      )),
      if (_questions.isNotEmpty)
        FilledButton(
          onPressed:_busy || _completed || _answers.length!=_questions.length
            ?null:_submit,child:const Text('Corrigir e gravar minhas respostas')),
      if (_score!=null) Text('Nota: '+(_score!*100).toStringAsFixed(1)+'%'),
      if (_status.isNotEmpty) Padding(padding:const EdgeInsets.all(12),
        child:Text(_status)),
    ]),
  );
}
