import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:academia_flutter/chapters/book_html.dart';
import 'package:academia_flutter/chapters/native_book_models.dart';
import 'package:academia_flutter/services/offline_library.dart';

List<int> fixture({bool structured=true,bool badHash=false,int chapter=1,Object revision='REV2',int layoutVersion=1}){
  final pdf=utf8.encode('%PDF-1.7\n' + List.filled(130,'0').join());
  final page=<String,dynamic>{'number':1,'text':'Título\nTexto preservado'};
  if(structured){
    page['layout']=[{'kind':'h2','text':'Título'},{'kind':'p','text':'Texto preservado'}];
    // Minimal marker fixture exercises format validation, not JPEG decoding.
    page['visualJpeg']=base64Encode([255,216,255,217]);
  }
  if(structured && layoutVersion==2){page['layout']=[{'kind':'table','text':'Quadro','rows':[['A','B'],['1','2']]},{'kind':'formula','text':'x = 1'},{'kind':'exercise','text':'Questão'},{'kind':'answer','text':'Resposta'}];}
  final text=utf8.encode(jsonEncode({'chapter':chapter,'layoutVersion':structured?layoutVersion:0,'pages':[page]}));
  final suffix=chapter.toString().padLeft(2,'0');
  final row=<String,dynamic>{'chapter':chapter,'title':'Dos dados às evidências','revision':revision,'pdf':'pdfs/cap_$suffix.pdf','pages':'pages/cap_$suffix.json','pageCount':1,'sha256':sha256.convert(pdf).toString()};
  if(structured){
    row['layoutVersion']=layoutVersion;
    row['pagesSha256']=badHash?'invalid':sha256.convert(text).toString();
  }
  final manifest=utf8.encode(jsonEncode({'schema':'academia-forense-offline-pack-v2','chapterCount':1,'chapters':[row]}));
  final archive=Archive()
    ..addFile(ArchiveFile('pdfs/cap_$suffix.pdf',pdf.length,pdf))
    ..addFile(ArchiveFile('pages/cap_$suffix.json',text.length,text))
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
  test('novos capítulos, revisão legada e conteúdo rico são importáveis',() async{
    final root=await Directory.systemTemp.createTemp('forense-extension-');
    addTearDown(()=>root.delete(recursive:true));
    final lib=OfflineLibrary(root:root);
    expect(await lib.importPack(fixture(chapter:114,layoutVersion:2,revision:'REV2')),1);
    final book=await const SourceBookLibrary().load(114,lib);
    expect(book.screens.single.layout.first['kind'],'table');
    expect(lib.chapter(114)?.revision,2);
    expect(await lib.importPack(fixture(chapter:114,revision:1)),0);
    expect(lib.chapter(114)?.layoutVersion,2);
    final html=SourceHtmlConverter.pageHtml(book.completeText,fontSize:20,chapter:114,screen:0,layout:book.screens.single.layout);
    expect(html,contains('<table>'));
    expect(html,contains('<th>A</th>'));
    expect(html,contains('class="formula"'));
    expect(html,contains('Questão'));
  });
  test('layout escapes text and uses safe structural tags',(){
    final html=SourceHtmlConverter.pageHtml('raw',fontSize:24,chapter:1,screen:0,
      layout:[{'kind':'h2','text':'Título <script>'},{'kind':'pre','text':'A | B\n1 | 2'}]);
    expect(html,contains('Título &lt;script&gt;'));
    expect(html,contains('<pre id="b1"'));
    expect(html,contains('A | B\n1 | 2'));
  });
  test('Native figures, tables and code render as separate semantic blocks; code is not read as prose',(){
    const layout=[
      {'kind':'h2','text':'Preservação, aquisição e cadeia de custódia'},
      {'kind':'table','text':'Termo · Uso técnico\nColeta · Receber vestígios','rows':[['Termo','Uso técnico'],['Coleta','Receber vestígios']]},
      {'kind':'pre','text':'$base = Join-Path $home "LAB"\n  $copia = $base'},
      {'kind':'figure','text':'Figura 2.1. Fluxo conceitual','jpeg':'/9j/2Q=='},
      {'kind':'p','text':'O hash não demonstra autoria.'},
    ];
    final html=SourceHtmlConverter.pageHtml('raw',fontSize:20,chapter:2,screen:3,layout:layout);
    expect(html,contains('<table>'));
    expect(html,isNot(contains('<p>Termo · Uso técnico')));
    expect(html,contains('<pre id="b2"><code>'));
    expect(html,contains('data-copy="b2"'));
    expect(html,contains('  $copia = $base'));
    expect(html,contains('<figure id="b3">'));
    final speech=SourceHtmlConverter.narrationText('raw',layout:layout);
    expect(speech,contains('Figura 2.1.'));
    expect(speech,contains('O hash não demonstra autoria.'));
    expect(speech,contains('Coleta'));
    expect(speech,isNot(contains('Join-Path')));
  });

}
