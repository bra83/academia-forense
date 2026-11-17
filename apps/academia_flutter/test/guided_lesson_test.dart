import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:academia_flutter/chapters/lesson_blueprints.dart';
import 'package:academia_flutter/chapters/guided_lesson_screen.dart';
import 'package:academia_flutter/services/offline_library.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('26 chapters provide distinct accurate didactic decision exercises',() {
    expect(guidedLessons.length,26);
    final chapters=guidedLessons.map((e)=>e.number).toSet();
    expect(chapters.length,26);
    expect(chapters,Set<int>.from(List<int>.generate(26,(i)=>i+1)));
    for(final lesson in guidedLessons) {
      expect(lesson.focus.trim().length,greaterThan(10));
      expect(lesson.explanation.trim().length,greaterThan(40));
      expect(lesson.example.trim().length,greaterThan(40));
      expect(lesson.warning.trim().length,greaterThan(30));
      expect(lesson.choices.length,3);
      expect(lesson.correct,inInclusiveRange(0,2));
      expect(lesson.choices.toSet().length,3);
      expect(lesson.flow.length,5);
      expect(lesson.feedback.trim().length,greaterThan(25));
    }
    expect(blueprintForChapter(1).focus,
      'Um registro não é uma conclusão');
    expect(blueprintForChapter(25).focus,
      'Probabilidade depende da taxa de base');
  });

  testWidgets('Guided Android lesson is interactive, not a PDF reader',(tester) async {
    SharedPreferences.setMockInitialValues(<String,Object>{});
    final dir=await Directory.systemTemp.createTemp('academia_lesson_');
    addTearDown(()=>dir.delete(recursive:true));
    tester.view.physicalSize=const Size(480,1000);
    tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final lib=OfflineLibrary(root:dir);
    await lib.initialize();
    await tester.pumpWidget(MaterialApp(home:GuidedLessonScreen(
      chapterNumber:1,chapterTitle:'Dos dados às evidências',library:lib,
    )));
    await tester.pumpAndSettle();
    expect(find.text('Um registro não é uma conclusão'),findsOneWidget);
    expect(find.text('Ver exemplo visual'),findsOneWidget);
    await tester.ensureVisible(find.text('Ver exemplo visual'));
    await tester.tap(find.text('Ver exemplo visual'));
    await tester.pumpAndSettle();
    expect(find.text('O percurso de uma análise'),findsOneWidget);
    await tester.ensureVisible(find.text('Experimentar na prática'));
    await tester.tap(find.text('Experimentar na prática'));
    await tester.pumpAndSettle();
    expect(find.text('Laboratório com resultado observável'),findsOneWidget);
    final field=find.byType(TextField).first;
    await tester.enterText(field,'REGISTRO 001 | evento 14:33');
    await tester.pumpAndSettle();
    expect(find.textContaining('hashes diferentes'),findsOneWidget);
    await tester.ensureVisible(find.text('Aplicar o que aprendi'));
    await tester.tap(find.text('Aplicar o que aprendi'));
    await tester.pumpAndSettle();
    expect(find.text('Você consegue justificar a conclusão?'),findsOneWidget);
    await tester.ensureVisible(find.byType(RadioListTile<int>).first);
    await tester.tap(find.byType(RadioListTile<int>).first);
    await tester.ensureVisible(find.text('Conferir minha resposta'));
    await tester.tap(find.text('Conferir minha resposta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('prática realizada'),findsWidgets);
    final prefs=await SharedPreferences.getInstance();
    expect(prefs.getBool('academia_lesson_correct_1'),isTrue);
  });
}
