import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:academia_flutter/chapters/book_html.dart';
import 'package:academia_flutter/chapters/study_catalog.dart';
import 'package:academia_flutter/chapters/study_notebook.dart';

void main(){
  test('currículo oficial mantém 113 títulos e nove volumes',(){
    expect(StudyCatalog.plannedTitles.length,113);
    expect(StudyCatalog.volumeTitles.length,9);
    expect(StudyCatalog.volumeFor(10),1);
    expect(StudyCatalog.volumeFor(11),2);
    expect(StudyCatalog.volumeFor(113),9);
    expect(StudyCatalog.volumeFor(114),10);
    expect(()=>StudyCatalog.volumeFor(1000),throwsRangeError);
  });
  test('busca normaliza acentos e espaços',(){
    expect(studyFold('  PERÍCIA\n Digital '),'pericia digital');
    expect(studyFold('Geolocalização'),'geolocalizacao');
  });
  test('HTML tem contraste integral, fonte ampla e texto escapado',(){
    final light=SourceHtmlConverter.pageHtml('A < B & C',fontSize:12,chapter:1,screen:0);
    final dark=SourceHtmlConverter.pageHtml('A < B & C',fontSize:36,chapter:1,screen:0,dark:true);
    expect(light,contains('background:#ffffff;color:#000000'));
    expect(dark,contains('background:#000000;color:#ffffff'));
    expect(dark,contains('36.0px'));
    expect(dark,contains('A &lt; B &amp; C'));
  });
  testWidgets('caderno recupera nota existente e navega à origem',(tester) async {
    SharedPreferences.setMockInitialValues({'source_reader_highlights_10':jsonEncode([
      {'page':2,'start':0,'end':8,'text':'Vestígio','note':'Revisar','savedAt':'2026-11-26T00:00:00'}])});
    int? chapter,page;
    String? quote;
    final c=StudyChapter(id:'forense.vol01.ch10',volume:1,number:10,title:'Laboratório integrador',edition:'1',editorialStatus:'Importado',pdfFileId:'',sections:const []);
    await tester.pumpWidget(MaterialApp(home:StudyNotebook(catalog:[c],openChapter:(n,p,q) async {chapter=n;page=p;quote=q;})));
    await tester.pumpAndSettle();
    expect(find.text('Minha anotação: Revisar'),findsOneWidget);
    await tester.tap(find.text('Abrir capítulo'));
    await tester.pumpAndSettle();
    expect(chapter,10);
    expect(page,2);
    expect(quote,'Vestígio');
  });
}
