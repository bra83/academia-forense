import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:academia_flutter/chapters/book_html.dart';
import 'package:academia_flutter/chapters/native_book_models.dart';
import 'package:academia_flutter/services/offline_library.dart';

List<int> fixture({bool structured=true,bool badHash=false}){
  final pdf=utf8.encode('%PDF-1.7\n' + List.filled(130,'0').join());
  final page=<String,dynamic>{'number':1,'text':'Título\nTexto preservado'};
  if(structured){
    page['layout']=[{'kind':'h2','text':'Título'},{'kind':'p','text':'Texto preservado'}];
    // Minimal marker fixture exercises format validation, not JPEG decoding.
    page['visualJpeg']=base64Encode([255,216,255,217]);
  }
  final text=utf8.encode(jsonEncode({'chapter':1,'layoutVersion':structured?1:0,'pages':[page]}));
  final row=<String,dynamic>{'chapter':1,'title':'Dos dados às evidências','pdf':'pdfs/cap_01.pdf','pages':'pages/cap_01.json','pageCount':1,'sha256':sha256.convert(pdf).toString()};
  if(structured){
    row['layoutVersion']=1;
    row['pagesSha256']=badHash?'invalid':sha256.convert(text).toString();
  }
  final manifest=utf8.encode(jsonEncode({'schema':'academia-forense-offline-pack-v2','chapterCount':1,'chapters':[row]}));
  final archive=Archive()
    ..addFile(ArchiveFile('pdfs/cap_01.pdf',pdf.length,pdf))
    ..addFile(ArchiveFile('pages/cap_01.json',text.length,text))
    ..addFile(ArchiveFile('manifest.json',manifest.length,manifest));
  return ZipEncoder().encode(archive)!;
}
void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  test('structured page and raw text survive import and reload; old pack cannot downgrade it',() async{
    final root=await Directory.systemTemp.createTemp('forense-structured-');
    addTearDown(()=>root.delete(recursive:true));
    final lib=OfflineLibrary(root:root);
    expect(await lib.importPack(fixture()),1);
    final reopened=OfflineLibrary(root:root);
    await reopened.initialize();
    final book=await const SourceBookLibrary().load(1,reopened);
    expect(book.completeText,'Título\nTexto preservado');
    expect(book.screens.single.layout.first['kind'],'h2');
    expect(book.screens.single.visualJpeg,isNotNull);
    expect((await reopened.pages(1)).single.visualJpeg,isNull);
    expect(await reopened.importPack(fixture(structured:false)),0);
    expect(reopened.chapter(1)?.layoutVersion,1);
  });
  test('corrupted layout hash is rejected without replacing prior chapter',() async{
    final root=await Directory.systemTemp.createTemp('forense-invalid-');
    addTearDown(()=>root.delete(recursive:true));
    final lib=OfflineLibrary(root:root);
    await lib.importPack(fixture());
    await expectLater(lib.importPack(fixture(badHash:true)),throwsFormatException);
    expect((await lib.pages(1,includeLayout:true)).single.layout.length,2);
  });
  test('layout escapes text and uses safe structural tags',(){
    final html=SourceHtmlConverter.pageHtml('raw',fontSize:24,chapter:1,screen:0,
      layout:[{'kind':'h2','text':'Título <script>'},{'kind':'pre','text':'A | B\n1 | 2'}]);
    expect(html,contains('Título &lt;script&gt;'));
    expect(html,contains('<pre id="b1"'));
    expect(html,contains('A | B\n1 | 2'));
  });
}
