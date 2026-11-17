import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:crypto/crypto.dart';
import 'package:persistence_core/persistence_core.dart';

/// An actual exported didactic report. A hash is NOT a digital signature.
class ForensicReportV2 {
  static Future<String> export(AppDatabase db) async {
    final sessions=await db.userProgressDao.getRecentStudySessions(limit:10000);
    final labRows=await db.customSelect(
      'SELECT laboratory_id, executed_at, is_passed, metrics_json '
      'FROM laboratory_runs ORDER BY executed_at DESC LIMIT 200').get();
    final attemptRows=await db.customSelect(
      'SELECT score, passed, timestamp FROM assessment_attempts '
      'ORDER BY timestamp DESC LIMIT 200').get();
    final seconds=sessions.fold<int>(0,(sum,s)=>sum+s.durationSeconds);
    final pdf=pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat:PdfPageFormat.a4,
      margin:const pw.EdgeInsets.all(36),
      build:(ctx)=>[
        pw.Text('ACADEMIA FORENSE',style:pw.TextStyle(
          fontSize:22,fontWeight:pw.FontWeight.bold)),
        pw.SizedBox(height:8),
        pw.Text('RELATORIO DIDATICO DE ATIVIDADES',
          style:pw.TextStyle(fontSize:15,fontWeight:pw.FontWeight.bold)),
        pw.SizedBox(height:12),
        pw.Text('Gerado em: '+DateTime.now().toIso8601String()),
        pw.Text('Natureza: documento educacional, sem valor de laudo judicial.'),
        pw.SizedBox(height:16),
        pw.Text('TEMPO DE ESTUDO REGISTRADO',
          style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),
        pw.Text('Sessoes: '+sessions.length.toString()),
        pw.Text('Duracao efetivamente registrada: '+
          (seconds/3600).toStringAsFixed(2)+' horas'),
        pw.SizedBox(height:12),
        pw.Text('ATIVIDADES LABORATORIAIS',
          style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),
        pw.Text('Total de execucoes registradas: '+labRows.length.toString()),
        ...labRows.take(35).map((row)=>pw.Text(
          row.read<String>('laboratory_id')+
          ' | Avaliacao formal: '+(row.read<int>('is_passed')==1?'aprovada':'nao avaliada'),
          style:const pw.TextStyle(fontSize:9))),
        pw.SizedBox(height:12),
        pw.Text('AVALIACOES RESPONDIDAS',
          style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),
        pw.Text('Tentativas gravadas: '+attemptRows.length.toString()),
        ...attemptRows.take(35).map((row)=>pw.Text(
          'Nota: '+(row.read<double>('score')*100).toStringAsFixed(1)+
          '% | '+(row.read<int>('passed')==1?'Acima do corte':'Abaixo do corte'),
          style:const pw.TextStyle(fontSize:9))),
        pw.SizedBox(height:20),
        pw.Text('AVISO DE INTEGRIDADE E LIMITACOES',
          style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),
        pw.Text('Este PDF registra apenas atividades realmente armazenadas no '
          'aplicativo. Nao declara competencia profissional, nao e certificado, '
          'nao reproduz caso real e nao tem assinatura digital qualificada.',
          style:const pw.TextStyle(fontSize:10)),
      ],
    ));
    final bytes=await pdf.save();
    final digest=sha256.convert(bytes).toString();
    await Printing.sharePdf(
      bytes:bytes,filename:'Academia_Forense_Relatorio_Didatico.pdf');
    return digest;
  }
}
