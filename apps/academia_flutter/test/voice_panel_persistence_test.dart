import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:academia_flutter/chapters/native_book_reader.dart';
import 'package:academia_flutter/chapters/study_catalog.dart';
import 'package:academia_flutter/services/offline_library.dart';
import 'package:academia_flutter/services/voice_reader_v2.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Closing and reopening audio controls keeps the same player',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize=const Size(480,960);
    tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const chapter=StudyChapter(
      id:'ch01',volume:1,number:1,title:'Dados às evidências',
      edition:'Edição de estudo',editorialStatus:'Publicado',
      pdfFileId:'',sections:[]);
    await tester.pumpWidget(MaterialApp(home:NativeBookReader(
      initialChapter:1,catalog:const [chapter],
      library:OfflineLibrary(root:Directory.systemTemp),
      getApiKey:() async => null,textModel:null,speechModel:null)));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ouvir'),findsOneWidget);
    // The player exists even while controls are offstage.
    final player=find.byType(VoiceReaderV2,skipOffstage:false);
    expect(player,findsOneWidget);
    final state=tester.state(player);
    await tester.tap(find.byTooltip('Ouvir'));
    await tester.pumpAndSettle();
    expect(find.text('Testar voz (frase curta)'),findsOneWidget);
    expect(identical(tester.state(player),state),isTrue);
    await tester.tap(find.byTooltip('Minimizar controles sem parar a voz'));
    await tester.pumpAndSettle();
    expect(find.byType(VoiceReaderV2),findsNothing);
    expect(find.byType(VoiceReaderV2,skipOffstage:false),findsOneWidget);
    expect(identical(tester.state(player),state),isTrue);
    await tester.tap(find.byTooltip('Ouvir'));
    await tester.pumpAndSettle();
    expect(find.text('Testar voz (frase curta)'),findsOneWidget);
    expect(identical(tester.state(player),state),isTrue);
  });
}
