import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:academia_flutter/chapters/lesson_blueprints.dart';
import 'package:academia_flutter/chapters/lesson_depth_view.dart';
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
    expect(deepLessons.length,26);
    for(final plan in deepLessons.values){
      expect(plan.sections.length,3);
      expect(plan.visualLabels.length,plan.visualDetails.length);
      expect(plan.sections.map((s)=>s.title).toSet().length,3);
      for(final section in plan.sections){
        expect(section.explanation.length,greaterThan(280));
        expect(section.demonstration.length,greaterThan(80));
      }
    }
    expect(deepLessons.values.map((x)=>x.kind).toSet().length,7);
    expect(blueprintForChapter(1).focus,
      'Um registro não é uma conclusão');
    expect(blueprintForChapter(25).focus,
      'Probabilidade depende da taxa de base');
  });

  Future<void> tapOnScreen(WidgetTester tester, Finder finder) async {
    // Scrollable.ensureVisible schedules a layout update; pump before tapping.
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pumpAndSettle(
      const Duration(milliseconds:100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds:5),
    );
  }

  testWidgets('Guided Android lesson is interactive, not a PDF reader',(tester) async {
    SharedPreferences.setMockInitialValues(<String,Object>{});
    // Avoid genuine dart:io futures inside the widget tester's fake-async zone.
    // This classroom route needs only the empty-library lookup, no filesystem I/O.
    tester.view.physicalSize=const Size(480,1000);
    tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final lib=OfflineLibrary(root:Directory.systemTemp);
    await tester.pumpWidget(MaterialApp(home:GuidedLessonScreen(
      chapterNumber:1,chapterTitle:'Dos dados às evidências',library:lib,
    )));
    await tester.pumpAndSettle(const Duration(milliseconds:100), EnginePhase.sendSemanticsUpdate, const Duration(seconds:5));
    expect(find.text('Um registro não é uma conclusão'),findsOneWidget);
    expect(find.text('Ver exemplo visual'),findsOneWidget);
    await tapOnScreen(tester,find.text('Ver exemplo visual'));
    expect(find.text('O percurso de uma análise'),findsOneWidget);
    await tapOnScreen(tester,find.text('Experimentar na prática'));
    expect(find.text('Laboratório com resultado observável'),findsOneWidget);
    final field=find.byType(TextField).first;
    await tester.enterText(field,'REGISTRO 001 | evento 14:33');
    await tester.pumpAndSettle(const Duration(milliseconds:100), EnginePhase.sendSemanticsUpdate, const Duration(seconds:5));
    expect(find.textContaining('hashes diferentes'),findsOneWidget);
    await tapOnScreen(tester,find.text('Registrar resultado calculado'));
    await tapOnScreen(tester,find.text('Aplicar o que aprendi'));
    expect(find.text('Você consegue justificar a conclusão?'),findsOneWidget);
    await tapOnScreen(tester,find.text(blueprintForChapter(1).choices.first));
    await tapOnScreen(tester,find.text('Conferir minha resposta'));
    expect(find.textContaining('progresso registrado'),findsWidgets);
    final prefs=await SharedPreferences.getInstance();
    expect(prefs.getBool('academia_lesson_correct_1'),isTrue);
  }, timeout: Timeout(const Duration(minutes:1)));
}
