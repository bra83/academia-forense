import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:design_system/design_system.dart';
import 'package:persistence_core/persistence_core.dart';
import 'study_catalog.dart';

class ChapterReaderScreen extends StatefulWidget {
  const ChapterReaderScreen({
    super.key,
    required this.chapter,
    required this.database,
    this.onSessionSaved,
  });
  final StudyChapter chapter;
  final AppDatabase database;
  final VoidCallback? onSessionSaved;

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  final DateTime _opened = DateTime.now();
  bool _saving = false;
  bool _saved = false;
  String _feedback = '';

  Future<void> _openOriginalPdf() async {
    final id = widget.chapter.pdfFileId;
    if (id.isEmpty) {
      setState(() => _feedback = 'Este capítulo não tem um PDF de origem identificado.');
      return;
    }
    try {
      final ok = await launchUrl(
        Uri.parse(widget.chapter.originalPdfUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!ok && mounted) {
        setState(() => _feedback = 'Não foi possível abrir o Google Drive.');
      }
    } catch (_) {
      if (mounted) setState(() => _feedback = 'Não foi possível abrir o Google Drive.');
    }
  }

  Future<void> _copyOriginalPdf() async {
    await Clipboard.setData(ClipboardData(text: widget.chapter.originalPdfUrl));
    if (mounted) setState(() => _feedback = 'Link do PDF copiado.');
  }

  Future<void> _recordStudyTime() async {
    if (_saving || _saved) return;
    setState(() => _saving = true);
    final duration = DateTime.now().difference(_opened).inSeconds;
    try {
      final sessionId = 'study_' + widget.chapter.number.toString() +
          '_' + DateTime.now().microsecondsSinceEpoch.toString();
      await widget.database.userProgressDao.startStudySession(
        StudySessionsCompanion.insert(
          id: sessionId,
          chapterId: widget.chapter.id,
        ),
      );
      await widget.database.userProgressDao.endStudySession(
        sessionId,
        durationSeconds: duration,
      );
      if (!mounted) return;
      setState(() {
        _saved = true;
        _feedback = 'Sessão registrada: ' + duration.toString() + ' segundos reais.';
      });
      widget.onSessionSaved?.call();
    } catch (_) {
      if (mounted) {
        setState(() => _feedback =
            'Não foi possível registrar o estudo. Nenhuma hora foi contabilizada.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    return Scaffold(
      appBar: AppBar(title: Text('Capítulo ' + chapter.number.toString())),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(chapter.title, style: ForensicTypography.screenTitle),
          const SizedBox(height: 8),
          Text('Volume ' + chapter.volume.toString() +
              ' • ' + chapter.edition + ' • ' + chapter.editorialStatus,
              style: ForensicTypography.caption),
          const SizedBox(height: 16),
          const Text(
            'ATENÇÃO — Este arquivo contém somente trechos de pré-visualização '
            'importados pelo Antigravity, não uma transcrição completa nem '
            'uma versão conferida do PDF. Para estudar o conteúdo correto, '
            'abra o documento original.',
            style: ForensicTypography.body,
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ForensicPrimaryButton(
              onPressed: _openOriginalPdf,
              label: 'Abrir PDF integral no Google Drive',
            ),
            ForensicSecondaryButton(
              onPressed: _copyOriginalPdf,
              label: 'Copiar link do PDF',
            ),
          ]),
          const SizedBox(height: 24),
          Text('Prévia disponível no aparelho', style: ForensicTypography.sectionTitle),
          const SizedBox(height: 8),
          if (chapter.sections.isEmpty)
            const Text('Nenhuma seção textual foi incluída neste pacote.')
          else
            for (final section in chapter.sections) ...[
              const SizedBox(height: 16),
              Text(section.title, style: ForensicTypography.subTitle),
              const SizedBox(height: 8),
              SelectableText(section.text, style: ForensicTypography.body),
              const Divider(height: 32),
            ],
          const SizedBox(height: 16),
          ForensicSecondaryButton(
            onPressed: _saving || _saved ? null : _recordStudyTime,
            label: _saved ? 'Sessão registrada' : 'Registrar tempo desta sessão',
          ),
          if (_feedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_feedback, style: ForensicTypography.caption),
          ],
        ],
      ),
    );
  }
}
