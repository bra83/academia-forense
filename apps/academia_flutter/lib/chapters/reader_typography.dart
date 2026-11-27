import 'package:flutter/material.dart';

/// Lossless typography for text transcribed from the source PDF.
/// It styles textual structure while leaving every character at its original
/// offset, so text selection and saved highlights remain reproducible.
class ReaderMark {
  const ReaderMark(this.start,this.end);
  final int start;
  final int end;
}

enum ReaderLineKind { body, title, section, heading, kicker, caption, label, reference }

class SourceTypography {
  const SourceTypography._();

  static final RegExp _section = RegExp(
    r'^\d{1,3}\.\d{1,2}(?:\.\d+)?\s*[—–.:-]?\s*\S');
  static final RegExp _chapter = RegExp(
    r'^(?:CAP[IÍ]TULO\s+)?\d{1,3}\.\s+[A-Za-zÀ-ÿ]');
  static final RegExp _kicker = RegExp(
    r'^(?:REGRA|ATEN[CÇ][AÃ]O|NOTA|AVISO|IMPORTANTE|LIMITE|PASSO|PROCEDIMENTO|OBJETIVOS|CONCLUS[AÃ]O|EXERC[IÍ]CIO|LABORAT[OÓ]RIO|CHECKLIST)\b',
    caseSensitive:false);
  static final RegExp _caption = RegExp(
    r'^(?:Figura|Tabela|Quadro|Gr[aá]fico|Fonte:)\s*\d*',
    caseSensitive:false);
  static final RegExp _heading = RegExp(
    r'^(?:Como usar esta enciclop[eé]dia|O que este cap[ií]tulo|O que voc[eê] ser[aá] capaz|Objetivos e pr[eé]-requisitos|Terminologia que voc[eê] precisa|Exemplo inteiramente explicado|Exemplo resolvido|Exemplo guiado|Gloss[aá]rio|Gabarito|Respostas comentadas|Refer[eê]ncias|Pr[oó]ximos passos|Arquitetura dos volumes|As quatro escalas|Popula[cç][aã]o, amostra|M[eé]dia ponderada|Experimento de sensibilidade|Cadeia de cust[oó]dia)\b',
    caseSensitive:false);
  static final RegExp _inlineLabel = RegExp(
    r'^(?:Em linguagem (?:cotidiana|profissional)|Exemplo (?:guiado|resolvido(?: \d+)?|forense|sint[eé]tico)|Defini[cç][aã]o t[eé]cnica(?: - [^:]+)?|Objetivo central|N[ií]vel|Pr[eé]-requisitos|Regra de seguran[cç]a|Popula[cç][aã]o estat[ií]stica|Amostra|Conjunto dispon[ií]vel|Unidade de observa[cç][aã]o|Amplitude total|Vari[aâ]ncia amostral|Fonte|Metadado|Artefato digital|Proveni[eê]ncia):',
    caseSensitive:false);

  static ReaderLineKind classify(String raw) {
    final line=raw.trim();
    if(line.isEmpty)return ReaderLineKind.body;
    if(line.startsWith('ENCICLOPÉDIA DE CIÊNCIAS FORENSES') ||
        line.startsWith('FORMAÇÃO TÉCNICO-CIENTÍFICA') ||
        line.startsWith('EDIÇÃO DE ESTUDO') ||
        line.startsWith('VOLUME III /') ||
        line.startsWith('C O L E Ç Ã O')) {
      return ReaderLineKind.reference;
    }
    if(_section.hasMatch(line) || _chapter.hasMatch(line)) {
      return ReaderLineKind.section;
    }
    if(_caption.hasMatch(line))return ReaderLineKind.caption;
    if(_heading.hasMatch(line))return ReaderLineKind.heading;
    if(_kicker.hasMatch(line))return ReaderLineKind.kicker;
    if(RegExp(r'^[A-ZÁÀÃÂÉÊÍÓÔÕÚÇ0-9 /·–—-]{8,}$').hasMatch(line) &&
        line.length<100) {
      return ReaderLineKind.kicker;
    }
    // Covers commonly split title pages without promoting ordinary prose.
    if(line.length<70 &&
       (line=='Dos dados' || line=='às evidências' ||
        line=='Estatística descritiva' ||
        line=='Computador, armazenamento e' ||
        line=='ambiente de trabalho')) {
      return ReaderLineKind.title;
    }
    if(line.startsWith('Capítulo ') || line.startsWith('CAPÍTULO ')) {
      return ReaderLineKind.label;
    }
    return ReaderLineKind.body;
  }

  static TextStyle _style(ReaderLineKind kind,double font,Color ink) {
    final muted=ink;
    switch(kind){
      case ReaderLineKind.title:
        return TextStyle(fontSize:font*1.52,height:1.26,
          fontWeight:FontWeight.w800,color:ink);
      case ReaderLineKind.section:
        return TextStyle(fontSize:font*1.20,height:1.52,
          fontWeight:FontWeight.w800,color:ink);
      case ReaderLineKind.heading:
        return TextStyle(fontSize:font*1.10,height:1.52,
          fontWeight:FontWeight.w700,color:ink);
      case ReaderLineKind.kicker:
        return TextStyle(fontSize:font*0.94,height:1.6,
          fontWeight:FontWeight.w800,letterSpacing:0.5,
          color:ink);
      case ReaderLineKind.caption:
        return TextStyle(fontSize:font*0.83,height:1.53,
          fontStyle:FontStyle.italic,color:muted);
      case ReaderLineKind.label:
        return TextStyle(fontSize:font*0.88,height:1.5,
          fontWeight:FontWeight.w700,color:ink);
      case ReaderLineKind.reference:
        return TextStyle(fontSize:font*0.72,height:1.45,
          letterSpacing:0.3,color:muted);
      case ReaderLineKind.body:
        return TextStyle(fontSize:font,height:1.64,color:ink);
    }
  }

  /// Returns styled spans whose concatenated plain text EXACTLY equals [source].
  /// Selection offsets and re-opening annotations thus stay stable.
  static List<TextSpan> spans(String source,{
    required double fontSize,
    required Color color,
    List<ReaderMark> highlights=const [],
  }) {
    final spans=<TextSpan>[];
    var lineStart=0;
    while(lineStart<source.length){
      final n=source.indexOf('\n',lineStart);
      final end=n<0?source.length:n+1;
      final raw=source.substring(lineStart,end);
      final role=classify(raw);
      final base=_style(role,fontSize,color);

      final boundaries=<int>{lineStart,end};
      final active=<ReaderMark>[];
      for(final mark in highlights){
        final a=mark.start.clamp(lineStart,end).toInt();
        final b=mark.end.clamp(lineStart,end).toInt();
        if(b>a) {
          boundaries.add(a);boundaries.add(b);active.add(mark);
        }
      }
      final inline=_inlineLabel.firstMatch(raw);
      if(inline!=null)boundaries.add(lineStart+inline.end);
      final stops=boundaries.toList()..sort();
      for(var i=0;i+1<stops.length;i++){
        final a=stops[i],b=stops[i+1];
        if(b<=a)continue;
        final marked=active.any((m)=>m.start<b && m.end>a);
        final boldPrefix=inline!=null && a<lineStart+inline.end;
        spans.add(TextSpan(
          text:source.substring(a,b),
          style:base.copyWith(
            fontWeight:boldPrefix?FontWeight.bold:base.fontWeight,
            color:marked?Colors.black:base.color,
            backgroundColor:marked?const Color(0xFFFFD66B):null),
        ));
      }
      lineStart=end;
    }
    return spans;
  }
}
