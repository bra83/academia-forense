import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:academia_flutter/chapters/reader_typography.dart';

void main(){
  test('PDF-derived structure has distinct hierarchy',(){
    expect(SourceTypography.classify('24.1 — O que é estatística?'),
      ReaderLineKind.section);
    expect(SourceTypography.classify('11.2. Bits e bytes'),
      ReaderLineKind.section);
    expect(SourceTypography.classify('Figura 4. Arquivos diferentes'),
      ReaderLineKind.caption);
    expect(SourceTypography.classify('REGRA NORTEADORA'),
      ReaderLineKind.kicker);
    expect(SourceTypography.classify('Objetivos e pré-requisitos'),
      ReaderLineKind.heading);
    expect(SourceTypography.classify('Uma linha normal de texto.'),
      ReaderLineKind.body);
  });
  test('Typography is lossless and highlights exactly the source offsets',(){
    const s='24.1 — Título da seção\nEm linguagem profissional: análise.\nFigura 1. Legenda\n';
    final start=s.indexOf('análise');
    final spans=SourceTypography.spans(s,fontSize:17,color:Colors.black,
      highlights:[ReaderMark(start,start+7)]);
    final combined=TextSpan(children:spans);
    expect(combined.toPlainText(),s);
    expect(spans.any((p)=>p.style?.fontWeight==FontWeight.w800),isTrue);
    expect(spans.any((p)=>p.text=='análise' &&
      p.style?.backgroundColor==const Color(0xFFFFD66B)),isTrue);
    expect(spans.any((p)=>p.text=='Em linguagem profissional:' &&
      p.style?.fontWeight==FontWeight.bold),isTrue);
  });
  test('No characters are lost across split pages or unexpected highlights',(){
    final text=List.generate(200,(i)=>i%7==0?
      '${i}.1 — Título teste\n':'Linha ${i}: um teste.\n').join();
    final spans=SourceTypography.spans(text,fontSize:23,color:Colors.black,
      highlights:[ReaderMark(-20,8),ReaderMark(40,60),
        ReaderMark(text.length-5,text.length+99)]);
    expect(TextSpan(children:spans).toPlainText(),text);
  });
}
