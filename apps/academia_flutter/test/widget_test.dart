import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:academia_flutter/academy_v2.dart';
import 'package:academia_flutter/services/offline_library.dart';
import 'package:academia_flutter/chapters/study_catalog.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Catalog references exactly the 26 available chapters',() async {
    final chapters=await StudyCatalog.loadBundledPreviews();
    expect(chapters.length,26);
    expect(chapters.first.title,'Dos dados às evidências');
    expect(chapters.last.number,26);
    expect(chapters.first.originalPdfUrl,contains('/file/d/'));
  });

  test('Verified archive imports without trusting manipulated SHA-256',() async {
    final dir=await Directory.systemTemp.createTemp('academia_pack_test_');
    try{
      final library=OfflineLibrary(root:dir);
      await library.initialize();
      final pdf=utf8.encode('%PDF-1.4\n'+List.filled(200,'x').join());
      final pages=utf8.encode(jsonEncode({
        'chapter':1,'pageCount':1,
        'pages':[{'number':1,'text':'Texto extraído da primeira página.'}]
      }));
      final manifest={'schema':'academia-forense-offline-pack-v2',
        'chapters':[{'chapter':1,'title':'Original de teste',
          'pdf':'pdfs/cap_01.pdf','pages':'pages/cap_01.json',
          'pageCount':1,'sha256':sha256.convert(pdf).toString()}]};
      Archive pack(){
        final a=Archive();
        final header=utf8.encode(jsonEncode(manifest));
        a.addFile(ArchiveFile('manifest.json',header.length,header));
        a.addFile(ArchiveFile('pdfs/cap_01.pdf',pdf.length,pdf));
        a.addFile(ArchiveFile('pages/cap_01.json',pages.length,pages));
        return a;
      }
      final zip=ZipEncoder().encode(pack())!;
      expect(await library.importPack(zip),1);
      expect((await library.pages(1)).first.text,
        'Texto extraído da primeira página.');
      expect(library.chapter(1),isNotNull);
      manifest['chapters']=[{'chapter':1,'title':'Corrompido',
        'pdf':'pdfs/cap_01.pdf','pages':'pages/cap_01.json',
        'pageCount':1,'sha256':List.filled(64,'0').join()}];
      expect(()=>library.importPack(ZipEncoder().encode(pack())!),
        throwsA(isA<FormatException>()));
      // On failed import, the verified old copy remains available.
      expect(library.chapter(1)!.title,'Original de teste');
    }finally{
      await dir.delete(recursive:true);
    }
  });

  testWidgets('Empty library shows no fabricated student achievements',(tester) async {
    final db=AppDatabase(DatabaseConnectionFactory.inMemory());
    final dir=await Directory.systemTemp.createTemp('academia_widget_');
    addTearDown(() async {await db.close();await dir.delete(recursive:true);});
    tester.view.physicalSize=const Size(1280,920);
    tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home:AcademiaV2Screen(
      database:db,privateLibrary:OfflineLibrary(root:dir))));
    for(var i=0;i<40;i++){
      await tester.runAsync(()=>Future<void>.delayed(const Duration(milliseconds:25)));
      await tester.pump(const Duration(milliseconds:50));
      if(find.text('Biblioteca original').evaluate().isNotEmpty)break;
    }
    expect(find.text('Biblioteca original'),findsOneWidget);
    expect(find.textContaining('documentos originais importados'),findsOneWidget);
    expect(find.textContaining('88%'),findsNothing);
    expect(find.textContaining('18.5h'),findsNothing);
    expect(find.textContaining('7/7'),findsNothing);
  });
}
