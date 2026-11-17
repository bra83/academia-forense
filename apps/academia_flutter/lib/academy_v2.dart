import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ai_gateway/ai_gateway.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:laboratory_core/laboratory_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chapters/study_catalog.dart';
import 'chapters/guided_lesson_screen.dart';
import 'chapters/study_reader_v2.dart';
import 'chapters/quiz_v2.dart';
import 'services/offline_library.dart';
import 'services/voice_reader_v2.dart';
import 'services/report_v2.dart';

class AcademiaV2Screen extends StatefulWidget {
  const AcademiaV2Screen({super.key, required this.database,this.privateLibrary, this.fixtureMode = false});
  final AppDatabase database;
  final OfflineLibrary? privateLibrary;
  /// Bypasses persistence and platform credentials only in deterministic widget tests.
  final bool fixtureMode;
  @override
  State<AcademiaV2Screen> createState() => _AcademiaV2ScreenState();
}

class _AcademiaV2ScreenState extends State<AcademiaV2Screen> {
  late final OfflineLibrary _library;
  final FlutterSecureStorage _vault=const FlutterSecureStorage();
  final _keyInput=TextEditingController();
  final _question=TextEditingController();
  final _labInput=TextEditingController();
  int _tab=0;
  int _selectedChapter=1;
  int _assessments=0, _labs=0, _cases=0;
  int _guidedLessonsComplete=0;
  double _hoursWeek=0;
  bool _loading=true, _importing=false, _testing=false, _asking=false, _labBusy=false, _reportBusy=false;
  bool _keyPresent=false;
  String _status='',_keyStatus='Sem chave configurada',
    _importStatus='',_tutorStatus='',_tutorAnswer='',_labOutput='',_reportStatus='';
  String _filter='',_corpusSearch='';
  List<StudyChapter> _catalog=[];
  List<GeminiModelInfo> _textModels=[], _speechModels=[];
  String? _textModel, _speechModel;
  PedagogicalMode _mode=PedagogicalMode.explicar;
  LabDomain _domain=LabDomain.telephony;
  List<({int chapter,int page,String excerpt})> _matches=[];
  bool _showCaseAnswer=false;
  final Map<int,int> _caseSelections={};
  static const _sampleCdr='call_id,timestamp,caller_msisdn,callee_msisdn,duration_sec,cell_tower_id,latitude,longitude\n'
      'C1,2026-11-16T10:00:00Z,+5531988880001,+5531977770002,120,ERB_BH_01,-19.92,-43.94\n'
      'C2,2026-11-16T10:30:00Z,+5531988880001,+5531966660003,45,ERB_BH_02,-19.93,-43.93';

  AppDatabase get db=>widget.database;
  @override
  void initState(){
    super.initState();
    _library=widget.privateLibrary??OfflineLibrary();
    _labInput.text=_sampleCdr;
    if (widget.fixtureMode) {
      _loading=false;
    } else {
      _initialize();
    }
  }

  @override
  void dispose(){
    _keyInput.dispose();_question.dispose();_labInput.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await _library.initialize();
      final catalog=await StudyCatalog.loadBundledPreviews();
      await _seedCatalog(catalog);
      String? key, model, speech;
      try {
        key=await _vault.read(key:'gemini_api_key');
        model=await _vault.read(key:'gemini_tutor_model');
        speech=await _vault.read(key:'gemini_speech_model');
      } catch (_) {
        _keyStatus='Cofre de credenciais não disponível neste ambiente.';
      }
      if(!mounted)return;
      setState(() {
        _catalog=catalog;_textModel=model;_speechModel=speech;
        _keyPresent=key!=null && key.isNotEmpty;
        _keyStatus=_keyPresent?'Chave recuperada do armazenamento seguro.':'Sem chave configurada.';
        _loading=false;
      });
      await _refreshMetrics();
      await _refreshGuidedLessons();
    }catch(e){
      if(mounted)setState(() {
        _loading=false;_status='Erro ao inicializar a Academia: '+e.toString();
      });
    }
  }

  Future<void> _seedCatalog(List<StudyChapter> catalog) async {
    await db.transaction(() async {
      await db.curriculumDao.insertCurriculum(CurriculumsCompanion.insert(
        id:'academia_enciclopedia',name:'Enciclopédia de Ciências Forenses',
        version:'2026',description:'Índice do acervo pessoal de PDF'));
      for(final vol in [1,2,3]){
        await db.curriculumDao.insertVolume(VolumesCompanion.insert(
          id:'academia_v'+vol.toString(),
          curriculumId:'academia_enciclopedia',
          volumeNumber:vol,
          title:vol==1?'Fundamentos':vol==2?'Computação, Python e SQL':
            'Estatística e Ciência de Dados',
          discipline:'Ciências Forenses',
          description:'Capítulos originais mantidos no Google Drive',
          totalChapters:catalog.where((c)=>c.volume==vol).length));
      }
      for(final c in catalog){
        await db.curriculumDao.insertChapter(ChaptersCompanion.insert(
          id:c.id,volumeId:'academia_v'+c.volume.toString(),
          chapterNumber:c.number,title:c.title,
          editorialStatus:drift.Value(c.editorialStatus),
          orderIndex:c.number));
      }
    });
  }

  Future<void> _refreshMetrics() async {
    try{
      final sessions=await db.userProgressDao.getRecentStudySessions(limit:10000);
      final week=DateTime.now();
      final start=DateTime(week.year,week.month,week.day)
        .subtract(Duration(days:week.weekday-1));
      final hours=sessions.where((s)=>!s.startTime.isBefore(start))
        .fold<int>(0,(v,s)=>v+s.durationSeconds)/3600.0;
      final countA=(await db.customSelect(
        'SELECT COUNT(*) AS n FROM assessment_attempts WHERE passed=1').getSingle())
        .read<int>('n');
      final countL=(await db.customSelect(
        'SELECT COUNT(*) AS n FROM laboratory_runs').getSingle()).read<int>('n');
      final countC=(await db.customSelect(
        'SELECT COUNT(*) AS n FROM case_submissions').getSingle()).read<int>('n');
      if(!mounted)return;
      setState(() {
        _hoursWeek=hours;_assessments=countA;_labs=countL;_cases=countC;
      });
    }catch(e){if(mounted)setState(()=>_status='Métricas indisponíveis: '+e.runtimeType.toString());}
  }

  Future<void> _refreshGuidedLessons() async {
    try {
      final prefs=await SharedPreferences.getInstance();
      var done=0;
      for(var i=1;i<=26;i++){
        if(prefs.getBool('academia_lesson_correct_${i}')??false)done++;
      }
      if(mounted)setState(()=>_guidedLessonsComplete=done);
    } catch (_) {
      // Never manufacture completion data when persistent storage fails.
    }
  }

  Future<void> _openGuidedLesson(int number) async {
    final matches=_catalog.where((entry)=>entry.number==number);
    if(matches.isEmpty)return;
    final chapter=matches.first;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder:(_)=>GuidedLessonScreen(
        chapterNumber:number,
        chapterTitle:chapter.title,
        library:_library,
        onProgress:_refreshGuidedLessons,
        onOpenPdf:()=>_readChapter(number),
      ),
    ));
    await _refreshGuidedLessons();
  }

  Future<void> _import() async {
    if(_importing)return;
    setState(() {_importing=true;_importStatus='Selecionando arquivo do aparelho ou Google Drive...';});
    try{
      final count=await _library.pickAndImport();
      if(!mounted)return;
      setState(()=>_importStatus=count==0
        ?'Nenhum arquivo importado.'
        :'Importados '+count.toString()+' PDFs originais com verificação de integridade.');
    }catch(e){
      if(mounted)setState(()=>_importStatus='Falha na importação: '+e.toString());
    }finally{if(mounted)setState(()=>_importing=false);}
  }

  Future<void> _readChapter(int number) async {
    final saved=_library.chapter(number);
    if(saved==null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:Text('Primeiro importe o pacote original na Biblioteca.')));
      setState(()=>_tab=2);
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder:(_)=>StudyReaderV2(
        chapter:saved,library:_library,database:db,onDone:_refreshMetrics,
        getApiKey:_getKey,speechModel:_speechModel)));
    await _refreshMetrics();
  }

  Future<void> _openSource(StudyChapter chapter) async {
    try {
      final uri=Uri.parse(chapter.originalPdfUrl);
      if (!await launchUrl(uri,mode:LaunchMode.externalApplication)) {
        throw StateError('Nenhum visualizador de Drive disponível.');
      }
    }catch(e){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text('Drive indisponível: '+e.runtimeType.toString())));
    }
  }

  Future<String?> _getKey()=>_vault.read(key:'gemini_api_key');

  Future<void> _saveKey() async {
    final key=_keyInput.text.trim();
    if(key.length<25){
      setState(()=>_keyStatus='Informe uma chave Gemini válida (mínimo 25 caracteres).');return;
    }
    try{
      await _vault.write(key:'gemini_api_key',value:key);
      final saved=await _vault.read(key:'gemini_api_key');
      if(saved!=key)throw StateError('A chave não foi recuperada após salvar.');
      _keyInput.clear();
      if(mounted)setState(() {
        _keyPresent=true;_keyStatus='Chave salva e relida com sucesso.';
      });
    }catch(e){
      if(mounted)setState(()=>_keyStatus='Falha ao salvar com segurança: '+e.runtimeType.toString());
    }
  }

  Future<void> _verifyKey() async {
    try{
      final key=await _getKey();
      if(mounted)setState(() {
        _keyPresent=key!=null && key.isNotEmpty;
        _keyStatus=_keyPresent?'Chave persistente encontrada no aparelho.':
          'Nenhuma chave foi recuperada.';
      });
    }catch(e){
      if(mounted)setState(()=>_keyStatus='Falha ao ler armazenamento seguro: '+e.runtimeType.toString());
    }
  }

  Future<void> _removeKey() async {
    try {
      await _vault.delete(key:'gemini_api_key');
      await _vault.delete(key:'gemini_tutor_model');
      await _vault.delete(key:'gemini_speech_model');
      if(mounted)setState(() {
        _keyPresent=false;_textModel=null;_speechModel=null;
        _textModels=[];_speechModels=[];
        _keyStatus='Chave removida do armazenamento seguro.';
      });
    }catch(e){if(mounted)setState(()=>_keyStatus='Falha ao excluir: '+e.runtimeType.toString());}
  }

  Future<void> _testGemini() async {
    if(_testing)return;
    setState(() {_testing=true;_keyStatus='Consultando lista oficial de modelos...';});
    try{
      final key=await _getKey();
      if(key==null || key.isEmpty)throw StateError('Salve sua chave antes.');
      final models=await GeminiModelDiscoveryService().discoverModels(apiKey:key);
      final text=models.textTutorModels.where((m)=>!m.isAudioModel).toList();
      final voice=models.audioSpeechModels.toList();
      final selectedText=text.any((m)=>m.name==_textModel)?_textModel:
        text.isEmpty?null:text.first.name;
      final selectedSpeech=voice.any((m)=>m.name==_speechModel)?_speechModel:
        voice.isEmpty?null:voice.first.name;
      if(!mounted)return;
      setState(() {
        _textModels=text;_speechModels=voice;
        _textModel=selectedText;_speechModel=selectedSpeech;
        _keyStatus='API respondeu: '+text.length.toString()+
          ' modelos de texto, '+voice.length.toString()+' modelos de voz.';
      });
      if(selectedText!=null)await _vault.write(key:'gemini_tutor_model',value:selectedText);
      if(selectedSpeech!=null)await _vault.write(key:'gemini_speech_model',value:selectedSpeech);
    }catch(e){
      if(mounted)setState(()=>_keyStatus='Conexão Gemini falhou: '+
        e.runtimeType.toString()+'. Verifique chave, quota e internet.');
    }finally{if(mounted)setState(()=>_testing=false);}
  }

  Future<void> _askTutor() async {
    if(_asking)return;
    final text=_question.text.trim();
    if(text.isEmpty)return;
    setState(() {_asking=true;_tutorStatus='Consultando as páginas do capítulo...';});
    try {
      final key=await _getKey();
      if(key==null || key.isEmpty || _textModel==null) {
        throw StateError('Configure a chave Gemini e selecione um modelo.');
      }
      final pages=await _library.relevantPages(_selectedChapter,text);
      if(pages.isEmpty) {
        throw StateError('Importe as páginas integrais antes de consultar o professor.');
      }
      final chapter=_catalog.firstWhere((c)=>c.number==_selectedChapter);
      final chunks=pages.map((p)=>RagDocumentChunkRef(
        chunkId:'cap'+_selectedChapter.toString()+'_p'+p.number.toString(),
        text:p.text.length>5000?p.text.substring(0,5000):p.text,
        editorialStatus:'Publicado',
        volume:chapter.volume,chapter:chapter.number,page:p.number)).toList();
      final reply=await GeminiGatewayClient(
        secureVault:InMemorySecureVault()).queryTutor(
          apiKey:key,modelId:_textModel!,mode:_mode,userQuery:text,
          contextChunks:chunks,chapterTitle:chapter.title);
      if(!mounted)return;
      setState(() {
        _tutorAnswer=reply;
        _tutorStatus='Consulta fundamentada nas páginas: '+
          pages.map((p)=>p.number.toString()).join(', ')+
          '. Confirme as afirmações no documento original.';
      });
    }catch(e){
      if(mounted)setState(()=>_tutorStatus=
        'Consulta não concluída: '+e.runtimeType.toString()+
        '. Nenhuma resposta simulada foi gerada.');
    }finally{if(mounted)setState(()=>_asking=false);}
  }

  Future<void> _openQuiz() async {
    final chapter=_library.chapter(_selectedChapter);
    if(chapter==null){
      setState(()=>_tab=2);return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder:(_)=>AiStudyQuiz(chapter:chapter,library:_library,database:db,
        apiKey:_getKey,model:_textModel,onSaved:_refreshMetrics)));
    await _refreshMetrics();
  }

  Future<void> _searchFullText() async {
    final q=_corpusSearch.trim().toLowerCase();
    if(q.length<3){setState(()=>_matches=[]);return;}
    final found=<({int chapter,int page,String excerpt})>[];
    for(final chapter in _library.chapters){
      final pages=await _library.pages(chapter.number);
      for(final page in pages){
        final i=page.text.toLowerCase().indexOf(q);
        if(i<0)continue;
        final from=i>45?i-45:0;
        final to=(i+145).clamp(0,page.text.length);
        found.add((chapter:chapter.number,page:page.number,
          excerpt:page.text.substring(from,to).replaceAll('\n',' ')));
        if(found.length>=30)break;
      }
      if(found.length>=30)break;
    }
    if(mounted)setState(()=>_matches=found);
  }

  void _setLabDomain(LabDomain d) {
    setState(() {
      _domain=d;_labOutput='';
      _labInput.text=d==LabDomain.telephony?_sampleCdr:
        d==LabDomain.linguistics?'Com certeza eu acho que estive no local.':
        d==LabDomain.digitalForensics?'AMOSTRA DIDATICA PARA HASH':
        d==LabDomain.mathematics?'0.01,0.99,0.95':
        d==LabDomain.programming?'SELECT * FROM lab_data;':
        d==LabDomain.informatics?'755':'44100,16,2,352800';
    });
  }

  Future<void> _runLab() async {
    if(_labBusy)return;
    setState(() {_labBusy=true;_labOutput='Processando entradas informadas...';});
    try{
      final input=_labInput.text.trim();
      if(input.isEmpty)throw const FormatException('Entrada vazia.');
      final output=StringBuffer();
      switch(_domain){
        case LabDomain.telephony:
          final rows=TelephonyExecutor.parseCdrCsv(input);
          final groups=TelephonyExecutor.aggregateErbTowers(rows);
          output.writeln('CDRs analisados: '+rows.length.toString());
          groups.forEach((tower,stats)=>output.writeln(
            'ERB '+tower+': '+stats.totalHits.toString()+' registros, '+
            stats.totalDurationSec.toString()+' segundos.'));
          output.writeln('A ERB não determina a localização precisa do aparelho.');
          break;
        case LabDomain.digitalForensics:
          final hashes=DigitalForensicsExecutor.calculateHashes(utf8.encode(input));
          output.writeln('SHA-256 da entrada: '+hashes.sha256);
          output.writeln('MD5 (legado, não recomendado como prova única): '+hashes.md5);
          break;
        case LabDomain.linguistics:
          final markers=LinguisticsExecutor.analyzeLexicalMarkers(input);
          output.writeln('Marcadores discursivos: '+markers.length.toString());
          for(final m in markers) {output.writeln(m.category+': '+m.token);}
          output.writeln('Marcadores não são detectores de mentira.');
          break;
        case LabDomain.mathematics:
          final values=input.split(',').map((x)=>double.parse(x.trim())).toList();
          if(values.length!=3)throw const FormatException(
            'Informe: priori,sensibilidade,especificidade');
          final r=MathematicsExecutor.computeBayesianProbability(
            prior:values[0],sensitivity:values[1],specificity:values[2]);
          output.writeln('P(H|E): '+r.posterior.toStringAsFixed(6));
          output.writeln('P(E): '+r.probabilityEvidence.toStringAsFixed(6));
          break;
        case LabDomain.programming:
          final result=ProgrammingExecutor.executeSql(
            setupStatements:[
              'CREATE TABLE lab_data (id INT, val TEXT);',
              "INSERT INTO lab_data VALUES (1,'Evidencia A'),(2,'Evidencia B');",
            ],query:input);
          output.writeln('Colunas: '+result.columnNames.join(', '));
          for(final row in result.rows) {output.writeln(row.toString());}
          break;
        case LabDomain.informatics:
          final perm=InformaticsExecutor.parsePermissions(input);
          output.writeln('Permissões POSIX: '+perm.rwxString);
          break;
        case LabDomain.multimedia:
          final parts=input.split(',').map((x)=>int.parse(x.trim())).toList();
          if(parts.length!=4)throw const FormatException(
            'Informe sampleRate,bitDepth,channels,bytes.');
          final r=MultimediaExecutor.inspectAudioProperties(
            sampleRateHz:parts[0],bitDepth:parts[1],channels:parts[2],
            totalAudioBytes:parts[3]);
          output.writeln('Duração calculada: '+r.durationSeconds.toString()+'s');
          break;
      }
      final labId='academia_lab_'+_domain.value;
      await db.transaction(() async {
        await db.curriculumDao.insertCurriculum(CurriculumsCompanion.insert(
          id:'academia_pratica',name:'Práticas locais',version:'1',
          description:'Exercícios com dados informados pelo aluno'));
        await db.curriculumDao.insertVolume(VolumesCompanion.insert(
          id:'academia_pratica_v0',curriculumId:'academia_pratica',
          volumeNumber:0,title:'Práticas',discipline:'Laboratórios didáticos',
          description:'Treino, sem certificação de competência',totalChapters:1));
        await db.curriculumDao.insertChapter(ChaptersCompanion.insert(
          id:'academia_pratica_ch0',volumeId:'academia_pratica_v0',
          chapterNumber:0,title:'Práticas avulsas',orderIndex:0));
        await db.laboratoryDao.insertLaboratory(LaboratoriesCompanion.insert(
          id:labId,chapterId:'academia_pratica_ch0',domain:_domain.value,
          title:'Prática '+_domain.displayName,environmentType:'Cálculo local',
          instructionsMarkdown:'Exercício executado com entrada fornecida',
          verificationRubricJson:'{}'));
        await db.laboratoryDao.recordLaboratoryRun(
          LaboratoryRunsCompanion.insert(
            id:'labrun_'+DateTime.now().microsecondsSinceEpoch.toString(),
            laboratoryId:labId,isPassed:false,
            commandsExecutedJson:jsonEncode({'input':input}),
            metricsJson:drift.Value(jsonEncode({'result':output.toString(),
              'evaluated':false,'didactic':true}))));
      });
      if(mounted)setState(()=>_labOutput=output.toString()+
        '\nRegistrado com sucesso. Esta execução não é uma avaliação de proficiência.');
      await _refreshMetrics();
    }catch(e){
      if(mounted)setState(()=>_labOutput='Falha real: '+e.toString()+
        '\nNenhum sucesso foi contabilizado.');
    }finally{if(mounted)setState(()=>_labBusy=false);}
  }

  Future<void> _exportReport() async {
    if(_reportBusy)return;
    setState(() {_reportBusy=true;_reportStatus='Gerando PDF a partir do banco de dados...';});
    try{
      final digest=await ForensicReportV2.export(db);
      if(mounted)setState(()=>_reportStatus='PDF real enviado ao compartilhamento. SHA-256: '+digest+
        '. O hash não é uma assinatura digital.');
    }catch(e){
      if(mounted)setState(()=>_reportStatus='Exportação falhou: '+e.toString());
    }finally{if(mounted)setState(()=>_reportBusy=false);}
  }

  Widget _infoCard(String title,Widget child,{IconData icon=Icons.school}) =>
    Card(child:Padding(padding:const EdgeInsets.all(18),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          Icon(icon,color:const Color(0xFF20533F)),
          const SizedBox(width:8),
          Expanded(child:Text(title,style:Theme.of(context).textTheme.titleLarge)),
        ]),
        const SizedBox(height:12),child,
      ])));
  Widget _topTitle(String title,String subtitle)=>Padding(
    padding:const EdgeInsets.only(bottom:18),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(title,style:Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight:FontWeight.bold,color:const Color(0xFF20533F))),
      const SizedBox(height:8),
      Text(subtitle,style:Theme.of(context).textTheme.bodyLarge),
    ]));

  Widget _home() => ListView(padding:const EdgeInsets.all(16),children:[
    _topTitle('Academia Forense','Aulas explicadas, simulações, decisões e avaliação — sem depender de um leitor de PDF.'),
    _infoCard('Sua academia interativa',Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('26 aulas temáticas com explicação, diagrama visual, '
          'atividade prática e questão comentada.',
          style:Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height:12),
        Text('Lições aplicadas e registradas: $_guidedLessonsComplete de 26'),
        const SizedBox(height:8),
        LinearProgressIndicator(value:_guidedLessonsComplete/26,
          minHeight:10,borderRadius:BorderRadius.circular(8)),
        const SizedBox(height:10),
        Wrap(spacing:8,runSpacing:8,children:[
          FilledButton.icon(
            onPressed:_catalog.isEmpty?null:()=>_openGuidedLesson(1),
            icon:const Icon(Icons.play_arrow),
            label:const Text('Começar aula 01')),
          OutlinedButton.icon(
            onPressed:()=>setState(()=>_tab=1),
            icon:const Icon(Icons.view_module_outlined),
            label:const Text('Escolher aula')),
        ]),
        const SizedBox(height:12),
        const Text('A primeira aula inclui laboratório real de SHA-256. '
          'O capítulo 4 simula desvio de relógios; os capítulos 17 e 25 '
          'incluem gráficos de probabilidade. Outras aulas têm '
          'investigações guiadas com decisões justificadas.'),
      ]),icon:Icons.auto_stories_outlined),
    if(_status.isNotEmpty) Text(_status),
    _infoCard('Seu estudo nesta semana',Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(_hoursWeek.toStringAsFixed(2)+' de 13 horas (tempo registrado)'),
        const SizedBox(height:10),
        LinearProgressIndicator(value:(_hoursWeek/13).clamp(0.0,1.0)),
        const SizedBox(height:8),
        const Text('As horas só são somadas após sessões de leitura reais.'),
      ]),icon:Icons.timer_outlined),
    _infoCard('Biblioteca original',Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(_library.chapters.length.toString()+
          ' documentos originais importados no dispositivo.'),
        Text((_catalog.length-_library.chapters.where((c)=>c.number<=26).length)
          .toString()+' capítulos do acervo ainda sem arquivo offline.'),
        const SizedBox(height:12),
        FilledButton.icon(onPressed:()=>setState(()=>_tab=2),
          icon:const Icon(Icons.menu_book),label:const Text('Abrir Biblioteca')),
      ]),icon:Icons.menu_book_outlined),
    _infoCard('Resultados registrados',Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Avaliações formativas acima do corte: '+_assessments.toString()),
        Text('Execuções laboratoriais salvas: '+_labs.toString()),
        Text('Estudos de caso entregues: '+_cases.toString()),
        const Text('Nenhuma proficiência ou diploma é atribuído sem avaliação real.'),
      ]),icon:Icons.analytics_outlined),
  ]);

  Widget _study(){
    final selected=_catalog.where((c)=>c.number==_selectedChapter).toList();
    final title=selected.isEmpty?'Capítulo':selected.first.title;
    final chapter=_library.chapter(_selectedChapter);
    return ListView(padding:const EdgeInsets.all(16),children:[
      _topTitle('Aulas e práticas','Aprenda interativamente. O PDF é somente material de apoio e referência.'),
      if(_catalog.isNotEmpty) _infoCard('Selecione o capítulo',Column(children:[
        DropdownButtonFormField<int>(
          value:_selectedChapter,
          decoration:const InputDecoration(border:OutlineInputBorder(),
            labelText:'Capítulo'),
          isExpanded:true,
          items:_catalog.map((c)=>DropdownMenuItem(
            value:c.number,child:Text(c.number.toString().padLeft(2,'0')+
              ' · '+c.title,overflow:TextOverflow.ellipsis))).toList(),
          onChanged:(n){if(n!=null)setState(() {
            _selectedChapter=n;_tutorAnswer='';_tutorStatus='';
          });}),
        const SizedBox(height:10),
        Text(title),
        const SizedBox(height:10),
        Wrap(spacing:8,runSpacing:8,children:[
          FilledButton.icon(onPressed:()=>_openGuidedLesson(_selectedChapter),
            icon:const Icon(Icons.school_outlined),label:const Text('Iniciar aula interativa')),
          OutlinedButton.icon(onPressed:()=>_readChapter(_selectedChapter),
            icon:const Icon(Icons.picture_as_pdf_outlined),label:const Text('Conferir fonte original')),
          OutlinedButton.icon(onPressed:_openQuiz,icon:const Icon(Icons.quiz_outlined),
            label:const Text('Avaliação formativa com Gemini')),
        ]),
        if(chapter==null)const Text('A aula interativa funciona sem PDF importado. '
          'Importe os originais pela Biblioteca para estudar e confirmar fontes.'),
      ])),
      _infoCard('Professor particular Gemini',Column(
        crossAxisAlignment:CrossAxisAlignment.start,children:[
          DropdownButton<PedagogicalMode>(
            value:_mode,isExpanded:true,
            items:PedagogicalMode.values.map((m)=>DropdownMenuItem(
              value:m,child:Text('Modo: '+m.value))).toList(),
            onChanged:(m){if(m!=null)setState(()=>_mode=m);}),
          TextField(controller:_question,minLines:2,maxLines:5,
            decoration:const InputDecoration(
              labelText:'Pergunte algo sobre o capítulo',
              hintText:'Ex.: explique a cadeia de custódia com um exemplo.',
              border:OutlineInputBorder())),
          const SizedBox(height:8),
          FilledButton.icon(onPressed:_asking?null:_askTutor,
            icon:const Icon(Icons.send),label:Text(_asking?'Consultando...':'Perguntar com fontes')),
          if(_tutorStatus.isNotEmpty)Text(_tutorStatus),
          if(_tutorAnswer.isNotEmpty) Card(
            color:const Color(0xFFF4F8F4),
            child:Padding(padding:const EdgeInsets.all(12),
              child:SelectableText(_tutorAnswer))),
        ]),icon:Icons.psychology_outlined),
      _infoCard('Depois da aula',const Text(
        'Use o laboratório para analisar dados editáveis e o professor Gemini '
        'para tirar dúvidas referenciadas. A leitura por voz fica disponível '
        'na página que você abrir no PDF original.'),
        icon:Icons.tips_and_updates_outlined),
    ]);
  }

  Widget _libraryTab(){
    final found=_catalog.where((c)=>c.title.toLowerCase().contains(_filter.toLowerCase()) ||
      c.number.toString().contains(_filter)).toList();
    return ListView(padding:const EdgeInsets.all(16),children:[
      _topTitle('Biblioteca de referência','26 capítulos existentes em 292 páginas. '
        'Conteúdo integral mediante importação; capítulos 27–113 não publicados.'),
      _infoCard('Importar PDFs do Drive ou do dispositivo',Column(
        crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Baixe o pacote integral fornecido neste chat. '
            'Toque no botão e selecione o ZIP no armazenamento ou no aplicativo Google Drive. '
            'Os PDFs e o texto das páginas serão guardados no aparelho.'),
          const SizedBox(height:12),
          FilledButton.icon(onPressed:_importing?null:_import,
            icon:const Icon(Icons.file_upload_outlined),
            label:Text(_importing?'Importando...':'Importar pacote ZIP / PDFs')),
          if(_importStatus.isNotEmpty)Text(_importStatus),
          const SizedBox(height:8),
          Text('Documentos originais disponíveis: '+_library.chapters.length.toString()),
        ]),icon:Icons.folder_open),
      TextField(onChanged:(v)=>setState(()=>_filter=v),
        decoration:const InputDecoration(prefixIcon:Icon(Icons.search),
          labelText:'Pesquisar título ou número do capítulo',
          border:OutlineInputBorder())),
      const SizedBox(height:12),
      for(final c in found) Card(child:ListTile(
        title:Text('Cap. '+c.number.toString().padLeft(2,'0')+' — '+c.title),
        subtitle:Text('Toque para estudar interativamente · Vol. '+c.volume.toString()+' • '+c.edition+
          ' • '+(_library.chapter(c.number)==null?'PDF de apoio não importado':'PDF original disponível offline')),
        isThreeLine:true,
        trailing:Icon(_library.chapter(c.number)==null
          ?Icons.cloud_outlined:Icons.check_circle,color:const Color(0xFF20533F)),
        onTap:()=>_openGuidedLesson(c.number),
      )),
      const SizedBox(height:16),
      _infoCard('Buscar no conteúdo das 292 páginas',Column(children:[
        TextField(onChanged:(value)=>_corpusSearch=value,
          decoration:const InputDecoration(
            labelText:'Termo ou expressão nos PDFs importados',
            border:OutlineInputBorder())),
        const SizedBox(height:8),
        FilledButton(onPressed:_searchFullText,
          child:const Text('Pesquisar texto integral')),
        for(final m in _matches) ListTile(
          title:Text('Cap. '+m.chapter.toString()+' · página '+m.page.toString()),
          subtitle:Text(m.excerpt,maxLines:3,overflow:TextOverflow.ellipsis),
          onTap:()=>_readChapter(m.chapter)),
        if(_matches.isEmpty)const Text('Nenhum resultado carregado.'),
      ]),icon:Icons.manage_search),
      const Text('Para arquivos novos, use novamente Importar. '
        'O acesso pelo seletor de arquivos do Android pode ler arquivos do Google Drive; '
        'sincronização automática sem autenticação OAuth não é afirmada.'),
    ]);
  }

  Widget _caseExercise() {
    const facts=[
      'Um registro documentado mostra uma conexão às 20:15.',
      'O titular certamente estava segurando o aparelho.',
      'Uma terceira pessoa pode ter usado o dispositivo.',
    ];
    const correct=[0,1,2];
    const types=['Fato documentado','Inferência','Hipótese alternativa'];
    final score=_caseSelections.entries.where((e)=>correct[e.key]==e.value).length;
    return _infoCard('Caso didático: fato, inferência ou hipótese',Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Cenário totalmente sintético. Classifique as afirmações.'),
        for(var i=0;i<facts.length;i++) Padding(
          padding:const EdgeInsets.symmetric(vertical:8),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(facts[i]),
            DropdownButtonFormField<int>(
              value:_caseSelections[i],
              hint:const Text('Escolha a categoria'),
              items:List.generate(types.length,(j)=>DropdownMenuItem(
                value:j,child:Text(types[j]))),
              onChanged:(v){if(v!=null)setState(() {
                _caseSelections[i]=v;_showCaseAnswer=false;
              });}),
          ])),
        FilledButton(
          onPressed:_caseSelections.length!=facts.length?null:()=>setState(()=>_showCaseAnswer=true),
          child:const Text('Corrigir classificação')),
        if(_showCaseAnswer)Text('Acertos: '+score.toString()+'/3. '
          'A inferência não prova quem operava o aparelho. '
          'Esta atividade não é um exame de proficiência.'),
      ]),icon:Icons.account_tree_outlined);
  }

  Widget _labTab()=>ListView(padding:const EdgeInsets.all(16),children:[
    _topTitle('Laboratórios Periciais','Exercícios com entradas reais editáveis e resultados calculados.'),
    _infoCard('Executar prática',Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        DropdownButtonFormField<LabDomain>(
          value:_domain,isExpanded:true,
          decoration:const InputDecoration(labelText:'Área',border:OutlineInputBorder()),
          items:LabDomain.values.map((d)=>DropdownMenuItem(
            value:d,child:Text(d.displayName))).toList(),
          onChanged:(d){if(d!=null)_setLabDomain(d);}),
        const SizedBox(height:10),
        TextField(controller:_labInput,minLines:2,maxLines:9,
          decoration:const InputDecoration(
            labelText:'Dados para processar (exemplo editável)',
            border:OutlineInputBorder())),
        const SizedBox(height:10),
        FilledButton.icon(onPressed:_labBusy?null:_runLab,
          icon:const Icon(Icons.play_arrow),
          label:Text(_labBusy?'Executando...':'Executar e registrar')),
        if(_labOutput.isNotEmpty) Container(
          width:double.infinity,margin:const EdgeInsets.only(top:12),
          padding:const EdgeInsets.all(12),
          decoration:BoxDecoration(color:const Color(0xFFEAF0EB),
            borderRadius:BorderRadius.circular(8)),
          child:SelectableText(_labOutput,style:const TextStyle(
            fontFamily:'monospace',fontSize:13))),
      ]),icon:Icons.biotech_outlined),
    _caseExercise(),
  ]);

  Widget _profile()=>ListView(padding:const EdgeInsets.all(16),children:[
    _topTitle('Meu Espaço','Somente resultados persistidos e configurações verificáveis.'),
    _infoCard('Matriz de competências',Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Proficiência profissional: ainda não aferida.'),
        Text('Lições interativas respondidas corretamente: $_guidedLessonsComplete de 26'),
        Text('Avaliações formativas acima do corte: '+_assessments.toString()),
        Text('Exercícios executados: '+_labs.toString()),
        Text('Casos registrados: '+_cases.toString()),
        Text('Estudo nesta semana: '+_hoursWeek.toStringAsFixed(2)+' h'),
        const Text('Não há percentuais fictícios nem certificados automáticos.'),
      ]),icon:Icons.analytics_outlined),
    _infoCard('Chave Gemini e modelos',Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(_keyStatus),
        const SizedBox(height:8),
        TextField(controller:_keyInput,obscureText:true,
          enableSuggestions:false,autocorrect:false,
          decoration:const InputDecoration(
            labelText:'Cole sua chave pessoal da API Gemini',
            border:OutlineInputBorder())),
        const SizedBox(height:8),
        Wrap(spacing:8,runSpacing:8,children:[
          FilledButton(onPressed:_saveKey,child:const Text('Salvar chave')),
          OutlinedButton(onPressed:_verifyKey,child:const Text('Conferir chave salva')),
          OutlinedButton(onPressed:_testing?null:_testGemini,
            child:Text(_testing?'Consultando...':'Testar API / modelos')),
          TextButton(onPressed:_removeKey,child:const Text('Excluir chave')),
        ]),
        if(_keyPresent)const Text('Chave cadastrada no aparelho. O valor não é mostrado nem enviado ao GitHub.'),
        if(_textModel!=null && _textModels.isEmpty)
          Text('Modelo de professor salvo: '+_textModel!),
        if(_speechModel!=null && _speechModels.isEmpty)
          Text('Modelo de voz salvo: '+_speechModel!),
        if(_textModels.isNotEmpty) DropdownButtonFormField<String>(
          value:_textModels.any((m)=>m.name==_textModel)?_textModel:null,
          isExpanded:true,
          decoration:const InputDecoration(labelText:'Professor Gemini'),
          items:_textModels.map((m)=>DropdownMenuItem(
            value:m.name,child:Text(m.displayName??m.shortId))).toList(),
          onChanged:(v) async {
            if(v==null)return;
            setState(()=>_textModel=v);
            await _vault.write(key:'gemini_tutor_model',value:v);
          }),
        if(_speechModels.isNotEmpty) DropdownButtonFormField<String>(
          value:_speechModels.any((m)=>m.name==_speechModel)?_speechModel:null,
          isExpanded:true,
          decoration:const InputDecoration(labelText:'Modelo Gemini TTS — Charon'),
          items:_speechModels.map((m)=>DropdownMenuItem(
            value:m.name,child:Text(m.displayName??m.shortId))).toList(),
          onChanged:(v) async {
            if(v==null)return;
            setState(()=>_speechModel=v);
            await _vault.write(key:'gemini_speech_model',value:v);
          }),
      ]),icon:Icons.key_outlined),
    _infoCard('Relatório PDF de atividades',Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Exporta um PDF real com as suas sessões e execuções '
          'gravadas. Um hash de integridade não é assinatura digital.'),
        const SizedBox(height:8),
        FilledButton.icon(onPressed:_reportBusy?null:_exportReport,
          icon:const Icon(Icons.picture_as_pdf),
          label:Text(_reportBusy?'Exportando...':'Compartilhar relatório PDF')),
        if(_reportStatus.isNotEmpty)Text(_reportStatus),
      ]),icon:Icons.picture_as_pdf_outlined),
  ]);

  static const titles=['Início','Estudar','Biblioteca','Laboratório','Meu Espaço'];
  static const icons=[Icons.home_outlined,Icons.school_outlined,
    Icons.menu_book_outlined,Icons.biotech_outlined,Icons.person_outline];
  Widget _tabBody()=>switch(_tab){
    0=>_home(),1=>_study(),2=>_libraryTab(),3=>_labTab(),_=>_profile()
  };

  @override
  Widget build(BuildContext context){
    final screen=MediaQuery.sizeOf(context);
    final desktop=screen.width>=840;
    if(_loading)return const Scaffold(body:Center(
      child:Column(mainAxisSize:MainAxisSize.min,children:[
        CircularProgressIndicator(),SizedBox(height:12),
        Text('Preparando sua biblioteca e o banco local...')
      ])));
    return Scaffold(
      resizeToAvoidBottomInset:true,
      appBar:AppBar(
        title:const Text('Academia Forense'),
        backgroundColor:Colors.white,
        foregroundColor:const Color(0xFF20533F)),
      body:desktop?Row(children:[
        NavigationRail(
          selectedIndex:_tab,onDestinationSelected:(n)=>setState(()=>_tab=n),
          extended:screen.width>=1150,
          destinations:List.generate(5,(i)=>NavigationRailDestination(
            icon:Icon(icons[i]),label:Text(titles[i])))),
        const VerticalDivider(width:1),
        Expanded(child:Center(child:ConstrainedBox(
          constraints:const BoxConstraints(maxWidth:1000),child:_tabBody()))),
      ]):_tabBody(),
      bottomNavigationBar:desktop?null:NavigationBar(
        selectedIndex:_tab,onDestinationSelected:(n)=>setState(()=>_tab=n),
        destinations:List.generate(5,(i)=>NavigationDestination(
          icon:Icon(icons[i]),label:titles[i]))),
    );
  }
}
