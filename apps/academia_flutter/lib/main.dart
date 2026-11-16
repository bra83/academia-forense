import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/drift.dart' as drift;
import 'package:design_system/design_system.dart';
import 'package:persistence_core/persistence_core.dart';
import 'chapters/study_catalog.dart';
import 'chapters/chapter_reader_screen.dart';
import 'package:laboratory_core/laboratory_core.dart';
import 'package:case_study_core/case_study_core.dart';
import 'package:ai_gateway/ai_gateway.dart';
import 'package:audio_core/audio_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AcademiaForenseApp());
}

class AcademiaForenseApp extends StatefulWidget {
  const AcademiaForenseApp({super.key, this.database});

  final AppDatabase? database;

  @override
  State<AcademiaForenseApp> createState() => _AcademiaForenseAppState();
}

class _AcademiaForenseAppState extends State<AcademiaForenseApp> {
  late final AppDatabase _db;
  bool _isDbInternal = false;

  @override
  void initState() {
    super.initState();
    if (widget.database != null) {
      _db = widget.database!;
    } else {
      _db = AppDatabase(DatabaseConnectionFactory.onDisk());
      _isDbInternal = true;
    }
  }

  @override
  void dispose() {
    if (_isDbInternal) {
      _db.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academia Forense — Laboratório de Formação',
      theme: ForensicTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.6),
        ),
        child: child!,
      ),
      home: ForensicHomeScreen(db: _db),
    );
  }
}

class ForensicHomeScreen extends StatefulWidget {
  const ForensicHomeScreen({super.key, required this.db});

  final AppDatabase db;

  @override
  State<ForensicHomeScreen> createState() => _ForensicHomeScreenState();
}

class _ForensicHomeScreenState extends State<ForensicHomeScreen> {
  int _currentIndex = 0;

  // Lesson & Assessment state (Tab 1)
  PedagogicalMode _tutorMode = PedagogicalMode.explicar;
  String _tutorResponse = '';

  // Voice & TTS state (§11, §12, §13)
  AudioEngine _selectedAudioEngine = AudioEngine.kokoroLocal;
  String _selectedVoice = 'Voz não identificada';
  final MotorAKokoroController _kokoro = MotorAKokoroController();
  StreamSubscription<MotorProgressEvent>? _kokoroProgress;
  StreamSubscription<String>? _kokoroErrors;
  bool _kokoroReady = false;
  List<String> _installedKokoroVoices = <String>[];
  double _speechSpeed = 1.00;
  final int _activeParagraphIndex = 0;
  bool _isSpeaking = false;
  String _ttsStatusMessage = '';

  // Library & Dual Reader state (Tab 2)
  List<StudyChapter> _chapters = <StudyChapter>[];
  bool _catalogLoading = true;
  String _catalogError = '';
  String _chapterSearch = '';

  // Laboratory & Case Study state (Tab 3)
  LabDomain _selectedDomain = LabDomain.telephony;
  String _labOutput = '';
  final TextEditingController _telephonyCsvController = TextEditingController(text: '''call_id,timestamp,caller_msisdn,callee_msisdn,duration_sec,cell_tower_id,latitude,longitude
C1,2026-11-16T10:00:00Z,+5531988880001,+5531977770002,120,ERB_BH_CENTRO_1,-19.92,-43.94
C2,2026-11-16T10:30:00Z,+5531988880001,+5531966660003,45,ERB_BH_SAVASSI_2,-19.93,-43.93''');
  bool _isExecutingLab = false;
  String _caseValidationOutput = '';

  // Portfolio & Settings state (Tab 4)
  String _portfolioExportStatus = '';
  int _completedAssessments = 0;
  int _verifiedLabs = 0;
  double _studyHours = 0;
  bool? _labLastSuccess;
  String _assessmentStatus = '';
  String _maskedApiKey = 'Nenhuma chave configurada';
  String _aiConnectivityStatus = 'Aguardando verificação';
  final FlutterSecureStorage _geminiStorage = const FlutterSecureStorage();
  final TextEditingController _geminiKeyController = TextEditingController();
  final TextEditingController _tutorQuestionController = TextEditingController();
  List<GeminiModelInfo> _tutorModels = <GeminiModelInfo>[];
  String? _selectedTutorModel;
  bool _geminiBusy = false;
  bool _tutorBusy = false;

  @override
  void initState() {
    super.initState();
    _kokoroProgress = _kokoro.progressStream.listen((event) {
      if (mounted && (event.state == MotorPlaybackState.stopped || event.state == MotorPlaybackState.error)) {
        setState(() { _isSpeaking = false; _ttsStatusMessage = 'Leitura encerrada.'; });
      }
    });
    _kokoroErrors = _kokoro.errorStream.listen((error) {
      if (mounted) setState(() { _isSpeaking = false; _ttsStatusMessage = 'Motor de voz: ' + error; });
    });
    _loadGeminiSettings();
    _loadRealMetrics();
    _loadLocalCatalog();
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _tutorQuestionController.dispose();
    _telephonyCsvController.dispose();
    if (_kokoroProgress != null) unawaited(_kokoroProgress!.cancel());
    if (_kokoroErrors != null) unawaited(_kokoroErrors!.cancel());
    unawaited(_kokoro.dispose().catchError((Object _) {}));
    super.dispose();
  }

  Future<void> _loadGeminiSettings() async {
    try {
      final key = await _geminiStorage.read(key: 'gemini_api_key');
      final model = await _geminiStorage.read(key: 'gemini_tutor_model');
      if (!mounted) return;
      setState(() {
        _maskedApiKey = key == null || key.isEmpty
            ? 'Nenhuma chave configurada'
            : SecureVaultContract.maskKey(key);
        _selectedTutorModel = model;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _aiConnectivityStatus =
            'Armazenamento seguro indisponível neste ambiente.');
      }
    }
  }

  Future<void> _saveGeminiKey() async {
    final key = _geminiKeyController.text.trim();
    if (key.length < 20) {
      setState(() => _aiConnectivityStatus = 'Informe uma chave Gemini válida.');
      return;
    }
    try {
      await _geminiStorage.write(key: 'gemini_api_key', value: key);
      final verified = await _geminiStorage.read(key: 'gemini_api_key');
      if (verified != key) throw StateError('Chave não persistiu no cofre seguro.');
      _geminiKeyController.clear();
      if (!mounted) return;
      setState(() {
        _maskedApiKey = SecureVaultContract.maskKey(key);
        _aiConnectivityStatus = 'Chave salva e conferida por releitura. Teste a conexão.';
        _tutorModels = [];
        _selectedTutorModel = null;
      });
      await _geminiStorage.delete(key: 'gemini_tutor_model');
    } catch (_) {
      if (mounted) {
        setState(() => _aiConnectivityStatus =
            'Não foi possível salvar a chave no armazenamento seguro.');
      }
    }
  }

  Future<void> _testGeminiKey() async {
    if (_geminiBusy) return;
    setState(() {
      _geminiBusy = true;
      _aiConnectivityStatus = 'Consultando modelos disponíveis...';
    });
    try {
      final key = await _geminiStorage.read(key: 'gemini_api_key');
      if (key == null || key.isEmpty) {
        throw StateError('Salve uma chave Gemini primeiro.');
      }
      final discovery = GeminiModelDiscoveryService();
      final catalog = await discovery.discoverModels(apiKey: key);
      final textModels = catalog.textTutorModels
          .where((model) => !model.isAudioModel).toList();
      if (!mounted) return;
      final previous = _selectedTutorModel;
      final selected = textModels.any((m) => m.name == previous)
          ? previous
          : (textModels.isNotEmpty ? textModels.first.name : null);
      setState(() {
        _tutorModels = textModels;
        _selectedTutorModel = selected;
        _aiConnectivityStatus = textModels.isEmpty
            ? 'Conexão ativa; nenhum modelo de texto compatível retornado.'
            : 'Conexão confirmada: ${textModels.length} modelos de texto.';
      });
      if (selected != null) {
        await _geminiStorage.write(key: 'gemini_tutor_model', value: selected);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _aiConnectivityStatus =
            'Falha ao consultar Gemini: ${e.runtimeType}. Confira a chave, a cota e a conexão.');
      }
    } finally {
      if (mounted) setState(() => _geminiBusy = false);
    }
  }

  Future<void> _removeGeminiKey() async {
    try {
      await _geminiStorage.delete(key: 'gemini_api_key');
      await _geminiStorage.delete(key: 'gemini_tutor_model');
      if (!mounted) return;
      setState(() {
        _geminiKeyController.clear();
        _maskedApiKey = 'Nenhuma chave configurada';
        _selectedTutorModel = null;
        _tutorModels = [];
        _aiConnectivityStatus = 'Chave removida.';
      });
    } catch (_) {
      if (mounted) {
        setState(() => _aiConnectivityStatus =
            'Não foi possível remover a chave.');
      }
    }
  }

  Future<void> _loadRealMetrics() async {
    try {
      final assessments = await widget.db.customSelect(
        'SELECT COUNT(*) AS total FROM assessment_attempts WHERE passed = 1',
      ).getSingle();
      final labs = await widget.db.customSelect(
        "SELECT COUNT(*) AS total FROM laboratory_runs WHERE is_passed = 1 AND laboratory_id NOT LIKE 'lab_demo_%'",
      ).getSingle();
      final sessions = await widget.db.userProgressDao.getRecentStudySessions(limit: 10000);
      final now = DateTime.now();
      final weekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - DateTime.monday));
      final weekSessions = sessions.where((s) => !s.startTime.isBefore(weekStart));
      if (!mounted) return;
      setState(() {
        _completedAssessments = assessments.read<int>('total');
        _verifiedLabs = labs.read<int>('total');
        _studyHours = weekSessions.fold<int>(0, (v, e) => v + e.durationSeconds) / 3600.0;
      });
    } catch (_) {
      if (mounted) setState(() => _assessmentStatus = 'Não foi possível ler as métricas locais.');
    }
  }


  Future<void> _loadLocalCatalog() async {
    try {
      final chapters = await StudyCatalog.loadBundledPreviews();
      await widget.db.transaction(() async {
        await widget.db.curriculumDao.insertCurriculum(
          CurriculumsCompanion.insert(
            id: 'academia_enciclopedia',
            name: 'Enciclopédia de Ciências Forenses',
            version: '2026',
            description: 'Catálogo de referências dos PDFs originais',
          ),
        );
        for (final volumeNumber in <int>[1, 2, 3]) {
          await widget.db.curriculumDao.insertVolume(
            VolumesCompanion.insert(
              id: 'academia_volume_' + volumeNumber.toString(),
              curriculumId: 'academia_enciclopedia',
              volumeNumber: volumeNumber,
              title: volumeNumber == 1 ? 'Fundamentos'
                  : volumeNumber == 2 ? 'Computação, Python, SQL e Matemática'
                  : 'Estatística e Ciência de Dados Forense',
              discipline: 'Ciências Forenses',
              description: 'Documento original disponível no Google Drive',
              totalChapters: chapters.where((c) => c.volume == volumeNumber).length,
            ),
          );
        }
        for (final chapter in chapters) {
          await widget.db.curriculumDao.insertChapter(
            ChaptersCompanion.insert(
              id: chapter.id,
              volumeId: 'academia_volume_' + chapter.volume.toString(),
              chapterNumber: chapter.number,
              title: chapter.title,
              editorialStatus: drift.Value(chapter.editorialStatus),
              orderIndex: chapter.number,
            ),
          );
        }
      });
      if (!mounted) return;
      setState(() {
        _chapters = chapters;
        _catalogLoading = false;
        _catalogError = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _catalogLoading = false;
        _catalogError = 'Não foi possível preparar o catálogo ou o banco local: ' +
            e.runtimeType.toString();
      });
    }
  }

  Future<void> _openChapter(StudyChapter chapter) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChapterReaderScreen(
          chapter: chapter,
          database: widget.db,
          onSessionSaved: _loadRealMetrics,
        ),
      ),
    );
    _loadRealMetrics();
  }


  Future<void> _toggleSpeech(String text) async {
    if (_selectedAudioEngine != AudioEngine.kokoroLocal) {
      setState(() => _ttsStatusMessage =
          'Gemini Charon ainda não tem reprodução integrada. Nenhum áudio foi gerado.');
      return;
    }
    if (_isSpeaking) {
      await _kokoro.stop();
      if (mounted) setState(() { _isSpeaking = false; _ttsStatusMessage = 'Leitura interrompida.'; });
      return;
    }
    if (text.trim().isEmpty) {
      setState(() => _ttsStatusMessage = 'Não há trecho para ler.');
      return;
    }
    setState(() => _ttsStatusMessage = 'Inicializando motor Braseiro Kokoro...');
    try {
      if (!_kokoroReady) _kokoroReady = await _kokoro.initialize();
      if (!_kokoroReady) throw StateError('Motor Kokoro não está instalado ou inicializado.');
      final voices = await _kokoro.getAvailableVoices();
      final names = voices.map((v) => v.name).where((v) => v.isNotEmpty).toList();
      if (names.isEmpty) throw StateError('Nenhuma voz Kokoro instalada.');
      final voice = names.contains(_selectedVoice) ? _selectedVoice : names.first;
      if (!await _kokoro.setVoice(voice)) {
        throw StateError('Voz recusada pelo Kokoro.');
      }
      await _kokoro.setSpeed(_speechSpeed);
      final chunks = SentenceSegmenter.segment(text).chunks;
      await _kokoro.playChunks(chunks);
      if (_kokoro.state == MotorPlaybackState.error) {
        throw StateError('Motor falhou ao sintetizar.');
      }
      if (mounted) setState(() {
        _selectedVoice = voice;
        _installedKokoroVoices = names;
        _isSpeaking = true;
        _ttsStatusMessage = 'Solicitado Kokoro: ' + chunks.length.toString() +
            ' blocos, voz ' + voice;
      });
    } catch (e) {
      if (mounted) setState(() {
        _isSpeaking = false;
        _ttsStatusMessage = 'Leitura falhou (' + e.runtimeType.toString() +
            '). Verifique o aplicativo de voz Kokoro.';
      });
    }
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return _buildInicioTab();
      case 1:
        return _buildEstudarTab();
      case 2:
        return _buildBibliotecaTab();
      case 3:
        return _buildLaboratorioTab();
      case 4:
        return _buildMeuEspacoTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInicioTab() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const Text(
          'Academia Forense',
          style: ForensicTypography.screenTitle,
        ),
        const SizedBox(height: 6),
        const Text(
          'Laboratório de Formação — Continue sua formação.',
          style: ForensicTypography.body,
        ),
        const SizedBox(height: 20),
        ForensicCard(
          title: 'Meta Semanal de Estudos (§17.1)',
          subtitle: 'Progresso do Plano Adaptativo',
          leading: const Icon(
            Icons.timer_outlined,
            color: ForensicColors.forestGreenPrimary,
            size: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  Text('Dedicação:', style: ForensicTypography.bodyMedium),
                  Text('13h / semana', style: ForensicTypography.body),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_studyHours / 13).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: ForensicColors.borders,
                  valueColor: AlwaysStoppedAnimation<Color>(ForensicColors.forestGreenPrimary),
                ),
              ),
              const SizedBox(height: 8),
              Text('${_studyHours.toStringAsFixed(1)} horas registradas. Meta: 13h por semana.',
                style: ForensicTypography.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ForensicCard(
          title: 'Volume I — Preservação Editorial (§24.2)',
          subtitle: '133 páginas impressas validadas',
          leading: const Icon(
            Icons.menu_book_rounded,
            color: ForensicColors.forestGreenDark,
            size: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Capítulos 1 a 4 na revisão REV2 (68 pág.); Capítulos 5 a 10 na revisão REV1 (65 pág.). Errata digital vinculada sem necessidade de reimpressão.',
                style: ForensicTypography.body,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ForensicPrimaryButton(
                    onPressed: () {
                      setState(() => _currentIndex = 1);
                    },
                    label: 'Continuar Estudos',
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  ),
                  ForensicSecondaryButton(
                    onPressed: () {
                      setState(() => _currentIndex = 2);
                    },
                    label: 'Abrir Biblioteca',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstudarTab() {
    final sampleParagraphs = _chapters.isEmpty ? <String>[] :
        _chapters.first.sections.map((section) => section.text).toList();

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const Text('Plano de Estudos', style: ForensicTypography.screenTitle),
        const SizedBox(height: 8),
        const Text(
          'Metodologia didática em 10 passos com nota de corte de 80%.',
          style: ForensicTypography.body,
        ),
        const SizedBox(height: 16),

        ForensicCard(
          title: _chapters.isNotEmpty
              ? 'Capítulo 01: ' + _chapters.first.title
              : 'Catálogo dos capítulos',
          subtitle: 'Leia o PDF original; os JSONs locais contêm apenas prévias incompletas.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_catalogLoading)
                const LinearProgressIndicator()
              else if (_catalogError.isNotEmpty)
                Text(_catalogError, style: ForensicTypography.caption)
              else
                Text(_chapters.length.toString() +
                    ' referências de capítulos carregadas. Progresso e avaliação só serão '
                    'registrados quando houver ações reais de estudo.',
                    style: ForensicTypography.body),
              const SizedBox(height: 12),
              ForensicPrimaryButton(
                onPressed: _chapters.isEmpty ? null : () => _openChapter(_chapters.first),
                label: 'Abrir Capítulo 01',
              ),
              const SizedBox(height: 8),
              ForensicSecondaryButton(
                onPressed: _runObjectiveEvaluation,
                label: 'Situação da avaliação',
              ),
              if (_assessmentStatus.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_assessmentStatus, style: ForensicTypography.caption),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        ForensicCard(
          title: 'Leitura por Voz — Kokoro Braseiro & Gemini Charon (§11–§13)',
          subtitle: 'Motor ativo: ${_selectedAudioEngine == AudioEngine.kokoroLocal ? "Braseiro Kokoro — Local" : "Gemini TTS — Online"} • Voz: $_selectedVoice • Velocidade: ${_speechSpeed.toStringAsFixed(2)}×',
          leading: const Icon(Icons.record_voice_over_outlined, color: ForensicColors.forestGreenPrimary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Braseiro Kokoro — Local'),
                    selected: _selectedAudioEngine == AudioEngine.kokoroLocal,
                    onSelected: (_) {
                      setState(() {
                        _selectedAudioEngine = AudioEngine.kokoroLocal;
                        _selectedVoice = _installedKokoroVoices.isEmpty ? 'Voz não identificada' : _installedKokoroVoices.first;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Gemini TTS — Online (Charon)'),
                    selected: _selectedAudioEngine == AudioEngine.geminiOnline,
                    onSelected: (_) {
                      setState(() {
                        _selectedAudioEngine = AudioEngine.geminiOnline;
                        _selectedVoice = 'Charon';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_installedKokoroVoices.isNotEmpty && _selectedAudioEngine == AudioEngine.kokoroLocal)
                DropdownButtonFormField<String>(
                  value: _installedKokoroVoices.contains(_selectedVoice) ? _selectedVoice : _installedKokoroVoices.first,
                  decoration: const InputDecoration(labelText: 'Voz instalada'),
                  items: _installedKokoroVoices.map((voice) => DropdownMenuItem(value: voice, child: Text(voice))).toList(),
                  onChanged: (voice) { if (voice != null) setState(() => _selectedVoice = voice); },
                ),
              Slider(
                value: _speechSpeed, min: 0.65, max: 1.50, divisions: 17,
                label: _speechSpeed.toStringAsFixed(2) + '×',
                onChanged: (value) => setState(() => _speechSpeed = value),
              ),
              for (int i = 0; i < sampleParagraphs.length; i++)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (_isSpeaking && _activeParagraphIndex == i)
                        ? ForensicColors.greenLight
                        : ForensicColors.softField,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ForensicColors.borders),
                  ),
                  child: Text(sampleParagraphs[i], style: ForensicTypography.body),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ForensicPrimaryButton(
                    onPressed: sampleParagraphs.isEmpty ? null :
                        () => _toggleSpeech(sampleParagraphs[_activeParagraphIndex]),
                    label: _isSpeaking ? 'Parar voz' : 'Ler trecho',
                  ),
                  ForensicSecondaryButton(
                    onPressed: () => setState(() => _speechSpeed = 1.0),
                    label: 'Velocidade 1.00×',
                  ),
                ],
              ),
              if (_ttsStatusMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_ttsStatusMessage, style: ForensicTypography.caption),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        ForensicCard(
          title: 'Professor Particular Gemini — Tutor RAG (§9)',
          subtitle: 'Modo ativo: ${_tutorMode.value}',
          leading: const Icon(Icons.psychology_outlined, color: ForensicColors.forestGreenDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: PedagogicalMode.values.map((mode) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(mode.value),
                        selected: _tutorMode == mode,
                        onSelected: (_) => setState(() => _tutorMode = mode),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tutorQuestionController,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Sua pergunta ao professor',
                  hintText: 'Ex.: qual é a diferença entre um dado e uma evidência?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ForensicPrimaryButton(
                onPressed: _tutorBusy ? null : _consultTutorRag,
                isLoading: _tutorBusy,
                label: 'Consultar Tutor com Citação Verificável',
              ),
              if (_tutorResponse.isNotEmpty) ...[
                const SizedBox(height: 12),
                SelectableText(_tutorResponse, style: ForensicTypography.body),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _runObjectiveEvaluation() async {
    setState(() {
      _assessmentStatus = 'Avaliação indisponível: questões não auditadas contra os documentos originais. Não será atribuída nota automática.';
    });
  }

  Future<void> _consultTutorRag() async {
    if (_tutorBusy) return;
    final question = _tutorQuestionController.text.trim();
    if (question.isEmpty) {
      setState(() => _tutorResponse = 'Digite uma pergunta para consultar o professor.');
      return;
    }
    setState(() {
      _tutorBusy = true;
      _tutorResponse = 'Consultando Gemini...';
    });
    try {
      final key = await _geminiStorage.read(key: 'gemini_api_key');
      if (key == null || key.isEmpty) {
        if (mounted) {
          setState(() => _tutorResponse =
              'Configure sua chave Gemini em Meu Espaço antes de consultar o tutor.');
        }
        return;
      }
      final model = _selectedTutorModel;
      if (model == null || model.isEmpty) {
        if (mounted) {
          setState(() => _tutorResponse =
              'Em Meu Espaço, teste a chave Gemini e selecione um modelo.');
        }
        return;
      }
      final gateway = GeminiGatewayClient(secureVault: InMemorySecureVault());
      final response = await gateway.queryTutor(
        apiKey: key,
        modelId: model,
        mode: _tutorMode,
        userQuery: question,
        contextChunks: const <RagDocumentChunkRef>[],
        chapterTitle: 'Ciências Forenses',
      );
      if (mounted) {
        setState(() => _tutorResponse =
            'Resposta Gemini — ${_tutorMode.value}\n'
            'Atenção: consulta ainda sem fontes RAG verificadas.\n\n'
            '$response');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _tutorResponse =
            'A consulta falhou (${e.runtimeType}). Verifique rede, chave e modelo. Sua pergunta continua disponível.');
      }
    } finally {
      if (mounted) setState(() => _tutorBusy = false);
    }
  }


  Widget _buildBibliotecaTab() {
    final query = _chapterSearch.trim().toLowerCase();
    final filtered = _chapters.where((c) =>
        c.title.toLowerCase().contains(query) ||
        c.number.toString().contains(query) ||
        c.edition.toLowerCase().contains(query)).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Biblioteca Forense', style: ForensicTypography.screenTitle),
        const SizedBox(height: 8),
        const Text('26 PDFs foram referenciados no pacote. '
            'Os capítulos 27 a 113 não foram entregues. '
            'O texto offline é uma prévia curta NÃO validada e não substitui os PDFs.',
            style: ForensicTypography.body),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Pesquisar capítulo, número ou revisão',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _chapterSearch = value),
        ),
        const SizedBox(height: 16),
        if (_catalogLoading)
          const Center(child: CircularProgressIndicator())
        else if (_catalogError.isNotEmpty)
          Column(children: [
            Text(_catalogError, style: ForensicTypography.body),
            ForensicSecondaryButton(
              onPressed: () { setState(() => _catalogLoading = true); _loadLocalCatalog(); },
              label: 'Tentar carregar novamente',
            ),
          ])
        else ...[
          Text(filtered.length.toString() + ' capítulos encontrados',
              style: ForensicTypography.caption),
          const SizedBox(height: 12),
          for (final chapter in filtered) ...[
            ForensicCard(
              title: 'Cap. ' + chapter.number.toString().padLeft(2, '0') +
                  ' — ' + chapter.title,
              subtitle: 'Vol. ' + chapter.volume.toString() +
                  ' • ' + chapter.edition + ' • ' + chapter.editorialStatus,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prévia: ' + chapter.sections.length.toString() +
                      ' seções incompletas. PDF integral pelo Google Drive.',
                      style: ForensicTypography.caption),
                  const SizedBox(height: 12),
                  ForensicPrimaryButton(
                    onPressed: () => _openChapter(chapter),
                    label: 'Abrir capítulo',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
        const SizedBox(height: 12),
        const Text('Sincronização automática com Google Drive requer autenticação '
            'OAuth e importação real de PDFs. Essa função ainda não está implementada.',
            style: ForensicTypography.caption),
      ],
    );
  }

  Widget _buildLaboratorioTab() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const Text('Laboratórios Periciais', style: ForensicTypography.screenTitle),
        const SizedBox(height: 8),
        const Text(
          '7 disciplinas práticas com isolamento e verificação automatizada.',
          style: ForensicTypography.body,
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: LabDomain.values.map((d) {
              final isSel = _selectedDomain == d;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(d.displayName),
                  selected: isSel,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDomain = d;
                        _labOutput = '';
                        _labLastSuccess = null;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        ForensicCard(
          title: '${_selectedDomain.displayName} — prática didática',
          subtitle: 'Dados de treino; execução não certifica competência',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analise registros de chamadas telefônicas e verifique o alinhamento com azimute de antenas celulares.',
                style: ForensicTypography.body,
              ),
              if (_selectedDomain == LabDomain.telephony) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _telephonyCsvController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Cole ou edite registros CDR (CSV de treino)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ForensicPrimaryButton(
                onPressed: _isExecutingLab ? null : () => _executeLabForDomain(_selectedDomain),
                label: 'Executar Laboratório',
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
              ),
            ],
          ),
        ),
        if (_labOutput.isNotEmpty) ...[
          const SizedBox(height: 16),
          ForensicCard(
            title: 'Diagnóstico da Execução Forense',
            subtitle: _labLastSuccess == true
                ? 'Exemplo executado e salvo; nenhuma proficiência atribuída.'
                : 'Falha na execução ou na gravação',
            leading: Icon(_labLastSuccess == true ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: _labLastSuccess == true ? ForensicColors.forestGreenPrimary : Colors.red),
            child: SelectableText(
              _labOutput,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ],
        const SizedBox(height: 16),
        ForensicCard(
          title: 'Estudo de Caso Interativo — Fato vs. Inferência vs. Hipótese (§15)',
          subtitle: 'Validação Epistemológica sem Falsos Detectores de Mentira',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Separe fatos documentados, inferências investigativas e hipóteses alternativas na cronologia pericial.',
                style: ForensicTypography.body,
              ),
              const SizedBox(height: 12),
              ForensicSecondaryButton(
                onPressed: () {
                  const entries = [
                    CaseEntry(
                      id: 'f1',
                      category: CaseOntologyCategory.documentedFact,
                      description: 'O registro CDR aponta conexão na ERB_BH_01 às 20:15:58.',
                    ),
                    CaseEntry(
                      id: 'i1',
                      category: CaseOntologyCategory.investigativeInference,
                      description: 'Há compatibilidade temporal entre o evento de rede e o vídeo da câmera A.',
                      linkedFactIds: ['f1'],
                    ),
                    CaseEntry(
                      id: 'h1',
                      category: CaseOntologyCategory.alternativeHypothesis,
                      description: 'O aparelho pode ter sido operado por terceiro ou sofrido desvio de cobertura.',
                    ),
                    CaseEntry(
                      id: 'h2',
                      category: CaseOntologyCategory.alternativeHypothesis,
                      description: 'O titular encontrava-se no setor de cobertura da ERB_BH_01.',
                    ),
                  ];
                  final eval = CaseMethodologyValidator.validateEntries(entries);
                  setState(() {
                    _caseValidationOutput =
                        'Metodologia Pericial: ${eval.isValidMethodology ? "VÁLIDA" : "INVÁLIDA"} (Fatos: ${eval.factsCount}, Inferências fundamentadas: ${eval.inferencesCount}, Hipóteses concorrentes: ${eval.hypothesesCount})';
                  });
                },
                label: 'Validar Metodologia do Caso',
              ),
              if (_caseValidationOutput.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_caseValidationOutput, style: ForensicTypography.caption),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _executeLabForDomain(LabDomain domain) async {
    setState(() => _isExecutingLab = true);
    try {
      final buffer = StringBuffer();
      switch (domain) {
        case LabDomain.digitalForensics:
          final payload = utf8.encode('DISK_FORENSIC_SECTOR_EVIDENCE_2026');
          final hashes = DigitalForensicsExecutor.calculateHashes(payload);
          final integrity = DigitalForensicsExecutor.verifyIntegrity(
            bytes: payload,
            expectedHash: hashes.sha256,
          );
          buffer.writeln('[PERÍCIA DIGITAL]');
          buffer.writeln('SHA-256: ${hashes.sha256}');
          buffer.writeln('MD5: ${hashes.md5}');
          buffer.writeln('Integridade: ${integrity.matches ? "100% ÍNTEGRO (Sem Adulteração)" : "ADULTERADO"}');
          break;
        case LabDomain.telephony:
          final csv = _telephonyCsvController.text.trim();
          if (csv.isEmpty) throw const FormatException('CSV vazio');
          final cdrs = TelephonyExecutor.parseCdrCsv(csv);
          final erbSummary = TelephonyExecutor.aggregateErbTowers(cdrs);
          buffer.writeln('[TELEFONIA FORENSE — DADOS DE TREINO]');
          buffer.writeln('Total de registros analisados: ${cdrs.length}');
          erbSummary.forEach((tower, sum) {
            buffer.writeln('ERB $tower: ${sum.totalHits} chamadas, ${sum.totalDurationSec}s');
          });
          buffer.writeln('Uma ERB não determina a localização exata do aparelho.');
          break;
        case LabDomain.mathematics:
          final bayes = MathematicsExecutor.computeBayesianProbability(
            prior: 0.01,
            sensitivity: 0.99,
            specificity: 0.95,
          );
          buffer.writeln('[MATEMÁTICA E ESTATÍSTICA]');
          buffer.writeln('Teorema de Bayes: P(H|E) = ${bayes.posterior.toStringAsFixed(4)}');
          buffer.writeln('P(E) = ${bayes.probabilityEvidence.toStringAsFixed(4)}');
          break;
        case LabDomain.informatics:
          final perm = InformaticsExecutor.parsePermissions('755');
          final parsedCmd = InformaticsExecutor.parseCommand('grep -rn "ERROR" /var/log/syslog | wc -l');
          buffer.writeln('[INFORMÁTICA FORENSE]');
          buffer.writeln('Permissões POSIX 755: ${perm.rwxString}');
          buffer.writeln('Comando CLI: ${parsedCmd.executable} com pipe: ${parsedCmd.hasPipe}');
          break;
        case LabDomain.programming:
          final queryResult = ProgrammingExecutor.executeSql(
            setupStatements: [
              'CREATE TABLE lab_data (id INT, val TEXT);',
              "INSERT INTO lab_data VALUES (1, 'Evidência 01'), (2, 'Evidência 02');"
            ],
            query: 'SELECT * FROM lab_data;',
          );
          buffer.writeln('[PROGRAMAÇÃO FORENSE / SQL]');
          buffer.writeln('Colunas: ${queryResult.columnNames.join(", ")}');
          buffer.writeln('Registros retornados: ${queryResult.rows.length}');
          break;
        case LabDomain.linguistics:
          final markers = LinguisticsExecutor.analyzeLexicalMarkers('Com certeza eu acho que estive no local.');
          buffer.writeln('[LINGUÍSTICA FORENSE]');
          buffer.writeln('Marcadores discursivos detectados: ${markers.length}');
          for (final m in markers) {
            buffer.writeln('- Categoria: ${m.category} | Termo: "${m.token}"');
          }
          break;
        case LabDomain.multimedia:
          final audio = MultimediaExecutor.inspectAudioProperties(
            sampleRateHz: 44100,
            bitDepth: 16,
            channels: 2,
            totalAudioBytes: 176400 * 2,
          );
          buffer.writeln('[MULTIMÍDIA FORENSE]');
          buffer.writeln('Áudio: ${audio.sampleRateHz}Hz, ${audio.bitDepth}bits, ${audio.durationSeconds}s');
          break;
      }

      final labId = 'lab_demo_${domain.value.toLowerCase()}';
      await widget.db.transaction(() async {
        await widget.db.curriculumDao.insertCurriculum(CurriculumsCompanion.insert(
          id: 'academia_treinos',
          name: 'Academia Forense — treinos locais',
          version: '1',
          description: 'Exercícios didáticos sem valor avaliativo',
        ));
        await widget.db.curriculumDao.insertVolume(VolumesCompanion.insert(
          id: 'academia_treinos_volume',
          curriculumId: 'academia_treinos',
          volumeNumber: 0,
          title: 'Exercícios locais',
          discipline: 'Treinos',
          description: 'Demonstrações sem aprovação acadêmica',
          totalChapters: 1,
        ));
        await widget.db.curriculumDao.insertChapter(ChaptersCompanion.insert(
          id: 'academia_treinos_capitulo',
          volumeId: 'academia_treinos_volume',
          chapterNumber: 0,
          title: 'Exemplos didáticos',
          orderIndex: 0,
        ));
        await widget.db.laboratoryDao.insertLaboratory(LaboratoriesCompanion.insert(
          id: labId,
          chapterId: 'academia_treinos_capitulo',
          domain: domain.value,
          title: 'Treino — ${domain.displayName}',
          environmentType: 'Simulação local',
          instructionsMarkdown: 'Dados de treino, sem avaliação',
          verificationRubricJson: '{}',
        ));
        await widget.db.laboratoryDao.recordLaboratoryRun(LaboratoryRunsCompanion.insert(
          id: 'run_${domain.value}_${DateTime.now().microsecondsSinceEpoch}',
          laboratoryId: labId,
          executedAt: drift.Value(DateTime.now()),
          commandsExecutedJson: jsonEncode(['treino_${domain.value}']),
          isPassed: false,
          metricsJson: drift.Value(jsonEncode({
            'domain': domain.value,
            'evaluated': false,
            'type': 'didactic_example',
          })),
        ));
      });

      buffer.writeln('✓ Execução registrada no banco de dados relacional (Drift).');
      if (!mounted) return;
      setState(() {
        _labLastSuccess = true;
        _labOutput = buffer.toString();
        _isExecutingLab = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _labLastSuccess = false;
        _labOutput = 'Erro na execução: $e';
        _isExecutingLab = false;
      });
    }
  }

  Widget _buildMeuEspacoTab() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const Text('Meu Espaço', style: ForensicTypography.screenTitle),
        const SizedBox(height: 8),
        const Text(
          'Portfólio profissional, laudos periciais e proficiência técnica.',
          style: ForensicTypography.body,
        ),
        const SizedBox(height: 16),
        ForensicCard(
          title: 'Matriz de Competências',
          subtitle: 'Meta de proficiência: 80%',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sem proficiência mensurada: nenhuma avaliação validada foi concluída.',
                style: ForensicTypography.body,
              ),
              SizedBox(height: 8),
              Text(
                'Avaliações aprovadas: ${_completedAssessments} • Laboratórios avaliados: ${_verifiedLabs} • Estudo: ${_studyHours.toStringAsFixed(1)}h',
                style: ForensicTypography.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ForensicCard(
          title: 'Portfólio de Formação',
          subtitle: 'Exportação de relatório final ainda em desenvolvimento',
          leading: const Icon(Icons.picture_as_pdf_rounded, color: ForensicColors.forestGreenDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O aplicativo ainda não dispõe de exportação de um arquivo PDF real para o dispositivo. '
                'O resumo antigo era apenas exibido na tela, e um hash SHA-256 não equivale a assinatura digital.',
                style: ForensicTypography.body,
              ),
              const SizedBox(height: 16),
              ForensicPrimaryButton(
                onPressed: _exportSignedPdfReport,
                label: 'Ver situação da exportação PDF',
                icon: const Icon(Icons.download_rounded, size: 18),
              ),
            ],
          ),
        ),
        if (_portfolioExportStatus.isNotEmpty) ...[
          const SizedBox(height: 16),
          ForensicCard(
            title: 'Estado da exportação',
            subtitle: 'Nenhum arquivo PDF foi entregue',
            leading: const Icon(Icons.info_outline_rounded, color: ForensicColors.forestGreenPrimary),
            child: SelectableText(
              _portfolioExportStatus,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 16),
        ForensicCard(
          title: 'Configurações Gemini API & Cofre BYOK (§10)',
          subtitle: 'Credencial: $_maskedApiKey • Status: $_aiConnectivityStatus',
          leading: const Icon(Icons.vpn_key_outlined, color: ForensicColors.forestGreenPrimary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sua chave é cadastrada exclusivamente aqui, no aparelho. Não existe uma chave fixa no código do aplicativo.',
                style: ForensicTypography.body,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _geminiKeyController,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(
                  labelText: 'Chave da API Gemini',
                  hintText: 'Cole sua chave aqui',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ForensicPrimaryButton(
                    onPressed: _geminiBusy ? null : _saveGeminiKey,
                    label: 'Salvar chave',
                  ),
                  ForensicSecondaryButton(
                    onPressed: _geminiBusy ? null : _testGeminiKey,
                    isLoading: _geminiBusy,
                    label: 'Testar API e modelos',
                  ),
                  ForensicSecondaryButton(
                    onPressed: _geminiBusy ? null : _removeGeminiKey,
                    label: 'Excluir chave',
                  ),
                ],
              ),
              if (_tutorModels.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tutorModels.any((m) => m.name == _selectedTutorModel)
                      ? _selectedTutorModel : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Modelo Gemini para o professor',
                    border: OutlineInputBorder(),
                  ),
                  items: _tutorModels.map((model) => DropdownMenuItem<String>(
                    value: model.name,
                    child: Text(model.displayName ?? model.shortId,
                        overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() => _selectedTutorModel = value);
                    try {
                      await _geminiStorage.write(
                        key: 'gemini_tutor_model', value: value);
                    } catch (_) {
                      if (mounted) {
                        setState(() => _aiConnectivityStatus =
                            'Não foi possível persistir o modelo selecionado.');
                      }
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportSignedPdfReport() async {
    setState(() {
      _portfolioExportStatus =
          'O fluxo de exportação de relatório ainda não está implementado. '
          'Nenhum PDF foi salvo no aparelho. '
          'Os exercícios didáticos não equivalem a resultados periciais certificados.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ForensicResponsiveScaffold(
      currentIndex: _currentIndex,
      onNavigationIndexChanged: (index) {
        setState(() => _currentIndex = index);
      },
      appBar: AppBar(
        title: const Text('Academia Forense'),
      ),
      body: _buildTabContent(_currentIndex),
    );
  }
}
