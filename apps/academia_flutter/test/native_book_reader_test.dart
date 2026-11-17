import 'dart:io';

import 'package:academia_flutter/chapters/native_book_models.dart';
import 'package:academia_flutter/chapters/native_book_reader.dart';
import 'package:academia_flutter/chapters/study_catalog.dart';
import 'package:academia_flutter/services/offline_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Reflow preserves 100% of the source characters',(){
    final original=List.generate(300,(n)=>
      'Parágrafo $n. Dados, hipótese e limites: áéíóú.\n').join();
    final screens=BookPaginator.paginate(original,targetChars:160);
    expect(screens.length,greaterThan(20));
    expect(screens.map((p)=>p.text).join(),original);
    expect(screens.first.number,1);
    expect(screens.last.number,screens.length);
  });

  test('All 26 PDF source transcriptions load offline without imports',() async {
    final lib=OfflineLibrary(root:Directory.systemTemp);
    var totalChars=0;
    final titles=<String>{};
    for(var chapter=1;chapter<=26;chapter++){
      final book=await const SourceBookLibrary().load(chapter,lib);
      expect(book.chapter,chapter);
      expect(book.originalPages,greaterThanOrEqualTo(9));
      expect(book.exactPdfPages,isFalse);
      expect(book.completeText.length,greaterThan(10000));
      expect(book.completeText.toLowerCase(),contains('forens'));
      expect(book.screens.length,greaterThan(3));
      totalChars+=book.completeText.length;
      titles.add(book.sourceName);
    }
    expect(totalChars,greaterThan(500000));
    expect(titles.length,26);
  });

  test('Actual source exercises are extracted, not replaced by canned quizzes',() async {
    final lib=OfflineLibrary(root:Directory.systemTemp);
    for(final chapter in [1,2,4,11,17,20,24,25,26]){
      final book=await const SourceBookLibrary().load(chapter,lib);
      final exercises=SourceExerciseSections.fromOriginal(book.completeText);
      expect(exercises.hasExercises,isTrue,
        reason:'Original chapter $chapter must expose its exercise section');
      expect(exercises.exercises.length,greaterThan(150));
    }
  });

  testWidgets('Android reader provides chapters, font and voice controls',(
      tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize=const Size(430,960);
    tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const chapter=StudyChapter(
      id:'forense.vol01.ch01',volume:1,number:1,
      title:'Dos dados às evidências',edition:'REV2',
      editorialStatus:'Publicado',pdfFileId:'',
      sections:[]);
    await tester.pumpWidget(MaterialApp(home:NativeBookReader(
      initialChapter:1,catalog:const [chapter],
      library:OfflineLibrary(root:Directory.systemTemp),
      getApiKey:()async=>null,textModel:null,speechModel:null,
    )));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds:120));
    });
    for(var i=0;i<40;i++){
      await tester.pump(const Duration(milliseconds:100));
      if(find.text('Enciclopédia — leitura integral').evaluate().isNotEmpty)break;
    }
    if(find.text('Enciclopédia — leitura integral').evaluate().isEmpty){
      final visible=tester.widgetList<Text>(find.byType(Text))
        .map((widget)=>widget.data).toList();
      fail('Leitor não entrou na tela principal. Textos: $visible');
    }
    expect(find.text('Enciclopédia — leitura integral'),findsOneWidget);
    expect(find.textContaining('Tela 1 de'),findsWidgets);
    expect(find.byTooltip('Aumentar fonte'),findsOneWidget);
    expect(find.text('Gemini'),findsOneWidget);
    expect(find.text('Exercícios'),findsOneWidget);
  },timeout:const Timeout(Duration(minutes:1)));
}
