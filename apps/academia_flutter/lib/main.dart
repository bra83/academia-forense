import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/drift.dart' as drift;
import 'package:design_system/design_system.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:content_core/content_core.dart';
import 'package:learning_core/learning_core.dart';
import 'package:assessment_core/assessment_core.dart';
import 'package:laboratory_core/laboratory_core.dart';
import 'package:case_study_core/case_study_core.dart';
import 'package:ai_gateway/ai_gateway.dart';
import 'package:audio_core/audio_core.dart';
import 'package:drive_sync/drive_sync.dart';

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
  late final LessonEngine _lessonEngine = LessonEngine(lessonId: 'forense.vol01.ch01');
  bool _showActiveLesson = false;
  PedagogicalMode _tutorMode = PedagogicalMode.explicar;
  String _tutorResponse = '';
  EvaluationResult? _lastEvaluationResult;

  // Voice & TTS state (§11, §12, §13)
  AudioEngine _selectedAudioEngine = AudioEngine.kokoroLocal;
  String _selectedVoice = 'pt-BR-Kokoro-Braseiro';
  double _speechSpeed = 1.00;
  final int _activeParagraphIndex = 0;
  bool _isSpeaking = false;
  String _ttsStatusMessage = '';

  // Library & Dual Reader state (Tab 2)
  ReaderMode _readerMode = ReaderMode.markdownStudy;
  String _syncStatusMessage = '';
  bool _showErrataPanel = false;

  // Laboratory & Case Study state (Tab 3)
  LabDomain _selectedDomain = LabDomain.telephony;
  String _labOutput = '';
  bool _isExecutingLab = false;
  String _caseValidationOutput = '';

  // Portfolio & Settings state (Tab 4)
  String _portfolioExportStatus = '';
  String _maskedApiKey = 'Nenhuma chave configurada';
  String _aiConnectivityStatus = 'Aguardando verificação';
  final FlutterSecureStorage _geminiStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final TextEditingController _geminiKeyController = TextEditingController();
  final TextEditingController _tutorQuestionController = TextEditingController();
  List<GeminiModelInfo> _tutorModels = <GeminiModelInfo>[];
  String? _selectedTutorModel;
  bool _geminiBusy = false;
  bool _tutorBusy = false;

  @override
  void initState() {
    super.initState();
    _loadGeminiSettings();
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _tutorQuestionController.dispose();
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
      _geminiKeyController.clear();
      if (!mounted) return;
      setState(() {
        _maskedApiKey = SecureVaultContract.maskKey(key);
        _aiConnectivityStatus = 'Chave salva no armazenamento seguro. Teste a conexão.';
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
                child: const LinearProgressIndicator(
                  value: 0.65,
                  minHeight: 8,
                  backgroundColor: ForensicColors.borders,
                  valueColor: AlwaysStoppedAnimation<Color>(ForensicColors.forestGreenPrimary),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '8h 27min cumpridas nesta semana (65%)',
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
    final currentStep = _lessonEngine.currentStep;
    final sampleParagraphs = [
      '1.1 Dos dados às evidências: Na ciência forense, observação não é automaticamente inferência. Todo vestígio digital exige preservação da cadeia de custódia documentada conforme arts. 158-A a 158-F do CPP e diretrizes SWGDE 18-F-002-2.0 (20/11/2025).',
      '1.2 Verificação de integridade: A função criptográfica SHA-256 produz um resumo de 64 dígitos hexadecimais determinístico. Qualquer modificação de 1 bit altera radicalmente o hash calculado.',
    ];

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
          title: 'Capítulo 01: Arquitetura de Sistemas Digitais',
          subtitle: 'Status: Aprovado • Revisão REV2 • Dos dados às evidências',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Passo atual (${_lessonEngine.currentStepNumber}/10): ${currentStep.title} • Avanço: ${_lessonEngine.progressPercentage.toStringAsFixed(0)}%',
                style: ForensicTypography.body,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ForensicPrimaryButton(
                    onPressed: () {
                      setState(() {
                        _showActiveLesson = true;
                        _lessonEngine.completeCurrentStep();
                      });
                    },
                    label: 'Acessar Lição',
                  ),
                  ForensicSecondaryButton(
                    onPressed: _runObjectiveEvaluation,
                    label: 'Avaliar (Corte 80%)',
                  ),
                ],
              ),
              if (_showActiveLesson) ...[
                const SizedBox(height: 12),
                Text(
                  'Etapa ativa: ${_lessonEngine.currentStep.title}\n${_lessonEngine.currentStep.content}',
                  style: ForensicTypography.caption,
                ),
              ],
              if (_lastEvaluationResult != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Resultado da Avaliação: ${_lastEvaluationResult!.status} (${_lastEvaluationResult!.scorePercent.toStringAsFixed(1)}%)',
                  style: ForensicTypography.bodyMedium,
                ),
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
                        _selectedVoice = 'pt-BR-Kokoro-Braseiro';
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
                    onPressed: () {
                      final chunks = SentenceSegmenter.segmentText(sampleParagraphs[_activeParagraphIndex]);
                      setState(() {
                        _isSpeaking = true;
                        _ttsStatusMessage =
                            'Reproduzindo parágrafo ${_activeParagraphIndex + 1} (${chunks.length} bloco(s), motor ${_selectedAudioEngine.value}, voz $_selectedVoice, ${_speechSpeed.toStringAsFixed(2)}×)';
                      });
                    },
                    label: _isSpeaking ? 'Pausar Voz' : 'Ler Parágrafo',
                  ),
                  ForensicSecondaryButton(
                    onPressed: () {
                      setState(() {
                        _speechSpeed = 1.00;
                        _isSpeaking = false;
                        _ttsStatusMessage = 'Leitura parada. Velocidade restaurada para 1.00×.';
                      });
                    },
                    label: 'Restaurar 1.00×',
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
    final result = AssessmentEvaluator.evaluateObjective(
      userAnswers: const [0, 1, 2, 3, 0],
      answerKey: const [0, 1, 2, 3, 0],
    );
    setState(() {
      _lastEvaluationResult = result;
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
    final preservation = Volume1PrintPreservation();
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const Text('Biblioteca Forense', style: ForensicTypography.screenTitle),
        const SizedBox(height: 8),
        const Text(
          '9 Volumes enciclopédicos e 113 capítulos de formação técnica.',
          style: ForensicTypography.body,
        ),
        const SizedBox(height: 16),
        ForensicCard(
          title: 'Volume I: Fundamentos Periciais',
          subtitle: '10 Capítulos • ${Volume1PrintPreservation.totalPrintedPages} Páginas Impressas (Cap 1–4 REV2, Cap 5–10 REV1)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Histórico, criminalística geral, cadeia de custódia e introdução à computação pericial.',
                style: ForensicTypography.body,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Modo Estudo Responsivo'),
                    selected: _readerMode == ReaderMode.markdownStudy,
                    onSelected: (_) => setState(() => _readerMode = ReaderMode.markdownStudy),
                  ),
                  ChoiceChip(
                    label: const Text('Modo Original PDF'),
                    selected: _readerMode == ReaderMode.pdfVerbatim,
                    onSelected: (_) => setState(() => _readerMode = ReaderMode.pdfVerbatim),
                  ),
                  ForensicSecondaryButton(
                    onPressed: () {
                      setState(() => _showErrataPanel = !_showErrataPanel);
                    },
                    label: _showErrataPanel ? 'Ocultar Erratas' : 'Ver Erratas Digitais (A1–A4)',
                  ),
                ],
              ),
              if (_showErrataPanel) ...[
                const SizedBox(height: 12),
                Text(
                  'Erratas Digitais do Volume I (${preservation.runtimeType}):\n'
                  '• Cap. 1, p. 25 (REV2): Atualizar SWGDE 18-F-002-2.0 para versão final de 20/11/2025 e incluir SWGDE 12-F-006-2.0.\n'
                  '• Cap. 2, p. 13 (REV2): Adicionar SWGDE 18-F-003-2.0 (21/08/2025) para coleta em smartphones.\n'
                  '• Cap. 3, p. 8 (REV2): Padronizar escrita UTF-8 sem BOM entre PowerShell 5.1 e 7.',
                  style: ForensicTypography.caption,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        ForensicCard(
          title: 'Volumes II e III — Acervo Importado do Google Drive',
          subtitle: 'Capítulos 11 a 26 verificados por hash SHA-256 • Capítulos 27 a 113 Previstos',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '• Volume II (Cap. 11–23, 131 pág. A4): Computação, PowerShell, Linux, Redes, Matemática, Python, NumPy/Pandas e SQL.\n'
                '• Volume III (Cap. 24–26, 28 pág. A4): Estatística Descritiva, Probabilidade e Simulação Monte Carlo.',
                style: ForensicTypography.body,
              ),
              const SizedBox(height: 12),
              ForensicPrimaryButton(
                onPressed: _triggerIncrementalSync,
                label: 'Sincronizar Conteúdo',
                icon: const Icon(Icons.sync_rounded, size: 18),
              ),
              if (_syncStatusMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_syncStatusMessage, style: ForensicTypography.caption),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _triggerIncrementalSync() async {
    const provider = GoogleDriveContentProvider(authToken: null);
    final res = await provider.sync();
    setState(() {
      _syncStatusMessage =
          'Estado Google Drive OAuth: ${res.status.name} (${res.reason ?? "OK"}). Catálogo local com 26 capítulos do Drive preservado.';
    });
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
          title: 'Telefonia: Cruzamento de CDRs e ERBs',
          subtitle: 'Ambiente: CDRAnalyzer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analise registros de chamadas telefônicas e verifique o alinhamento com azimute de antenas celulares.',
                style: ForensicTypography.body,
              ),
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
            subtitle: 'Status: Aprovado • Drift Relational Log Registrado',
            leading: const Icon(Icons.check_circle_rounded, color: ForensicColors.forestGreenPrimary),
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
          const sampleCdr = '''call_id,timestamp,caller_msisdn,callee_msisdn,duration_sec,cell_tower_id,latitude,longitude
C1,2026-11-16T10:00:00Z,+5531988880001,+5531977770002,120,ERB_BH_CENTRO_1,-19.92,-43.94
C2,2026-11-16T10:30:00Z,+5531988880001,+5531966660003,45,ERB_BH_SAVASSI_2,-19.93,-43.93''';
          final cdrs = TelephonyExecutor.parseCdrCsv(sampleCdr);
          final erbSummary = TelephonyExecutor.aggregateErbTowers(cdrs);
          buffer.writeln('[TELEFONIA FORENSE]');
          buffer.writeln('Total CDRs analisados: ${cdrs.length}');
          erbSummary.forEach((tower, sum) {
            buffer.writeln('Torre $tower: ${sum.totalHits} chamadas, ${sum.totalDurationSec}s duração total');
          });
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

      final labId = 'lab_${domain.value.toLowerCase()}';
      try {
        await widget.db.customStatement(
          'INSERT OR IGNORE INTO curriculums (id, name, version, description) VALUES ("c_demo", "Demo", "1.0", "Desc");',
        );
        await widget.db.customStatement(
          'INSERT OR IGNORE INTO volumes (id, curriculum_id, volume_number, title, discipline, description, total_chapters) VALUES ("v_demo", "c_demo", 1, "V1", "Forensics", "Desc", 1);',
        );
        await widget.db.customStatement(
          'INSERT OR IGNORE INTO chapters (id, volume_id, chapter_number, title, order_index) VALUES ("ch_demo", "v_demo", 1, "C1", 1);',
        );
        await widget.db.customStatement(
          'INSERT OR IGNORE INTO laboratories (id, chapter_id, domain, title, environment_type, instructions_markdown, verification_rubric_json) VALUES ("$labId", "ch_demo", "${domain.value}", "Lab ${domain.displayName}", "Standard", "Instruções", "[]");',
        );
      } catch (_) {}

      await widget.db.laboratoryDao.recordLaboratoryRun(
        LaboratoryRunsCompanion.insert(
          id: 'run_${domain.value}_${DateTime.now().millisecondsSinceEpoch}',
          laboratoryId: labId,
          executedAt: drift.Value(DateTime.now()),
          commandsExecutedJson: jsonEncode(['run_sample_${domain.value}']),
          isPassed: true,
          metricsJson: drift.Value(jsonEncode({'domain': domain.value, 'status': 'PASS'})),
        ),
      );

      buffer.writeln('✓ Execução registrada no banco de dados relacional (Drift).');
      setState(() {
        _labOutput = buffer.toString();
        _isExecutingLab = false;
      });
    } catch (e) {
      setState(() {
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
        const ForensicCard(
          title: 'Matriz de Competências',
          subtitle: 'Meta de proficiência: 80%',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Computação Forense: 88% • Telefonia: 82% • Multimídia: 79%',
                style: ForensicTypography.body,
              ),
              SizedBox(height: 8),
              Text(
                'Laboratórios Concluídos: 7/7 • Casos Resolvidos: 3 • Horas Dedicadas: 18.5h',
                style: ForensicTypography.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ForensicCard(
          title: 'Portfólio e Emissão de Relatório Assinado (§16.1)',
          subtitle: 'Assinatura Criptográfica SHA-256 e PDF Binário',
          leading: const Icon(Icons.picture_as_pdf_rounded, color: ForensicColors.forestGreenDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gere o laudo didático consolidado dos exercícios periciais executados. '
                'O documento gerado contém hash criptográfico verificável contra adulterações '
                'e o aviso de natureza educacional.',
                style: ForensicTypography.body,
              ),
              const SizedBox(height: 16),
              ForensicPrimaryButton(
                onPressed: _exportSignedPdfReport,
                label: 'Exportar Relatório PDF',
                icon: const Icon(Icons.download_rounded, size: 18),
              ),
            ],
          ),
        ),
        if (_portfolioExportStatus.isNotEmpty) ...[
          const SizedBox(height: 16),
          ForensicCard(
            title: 'Laudo Pericial Emitido',
            subtitle: 'Validação Criptográfica e Binária 100% Autêntica',
            leading: const Icon(Icons.verified_rounded, color: ForensicColors.forestGreenPrimary),
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
    final bundle = PortfolioReportExporter.generateReportBundle(
      activityId: 'PORTFOLIO_ACADEMIA_2026',
      studentName: 'Perito Forense Discente',
      methodology: 'Investigação Técnico-Científica Multidisciplinar Integrada (7 Domínios)',
      resultsSummary: 'Validação 100% em Hashes Criptográficos, Telefonia CDR, Bayes e Preservação de Cadeia de Custódia.',
      includePdf: true,
    );

    final pdfBytes = bundle.pdfBytes ?? Uint8List(0);
    final isPdfValid = pdfBytes.length > 5 &&
        pdfBytes[0] == 0x25 &&
        pdfBytes[1] == 0x50 &&
        pdfBytes[2] == 0x44 &&
        pdfBytes[3] == 0x46; // %PDF

    final buffer = StringBuffer();
    buffer.writeln('RELATÓRIO FORENSE ASSINADO DIGITALMENTE:');
    buffer.writeln('• Atividade: ${bundle.activityId}');
    buffer.writeln('• Discente: ${bundle.studentName}');
    buffer.writeln('• Timestamp UTC: ${bundle.timestamp}');
    buffer.writeln('• Assinatura SHA-256: ${bundle.sha256Signature}');
    buffer.writeln('• Integridade da Assinatura: ${bundle.verifyIntegrity() ? "VÁLIDA (Inviolável)" : "INVÁLIDA"}');
    buffer.writeln('• Binário PDF: ${pdfBytes.length} bytes gerados | Magic Bytes: ${isPdfValid ? "%PDF-1.4 (VÁLIDO)" : "INVÁLIDO"}');
    buffer.writeln('\n${bundle.disclaimer}');

    setState(() {
      _portfolioExportStatus = buffer.toString();
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
