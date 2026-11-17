import 'dart:convert';

import 'package:flutter/services.dart';

import '../services/offline_library.dart';

/// A reader screen is deliberately distinguished from a numbered PDF page.
class BookScreen {
  const BookScreen({required this.number,required this.text});
  final int number;
  final String text;
}

class BookChapter {
  const BookChapter({
    required this.chapter,
    required this.sourceName,
    required this.originalPages,
    required this.exactPdfPages,
    required this.screens,
  });
  final int chapter;
  final String sourceName;
  final int originalPages;
  final bool exactPdfPages;
  final List<BookScreen> screens;
  String get completeText => screens.map((e)=>e.text).join(
    exactPdfPages?'\n':'');
}

/// Reflows the extracted text without deleting paragraphs or inventing
/// the original PDF page boundaries.
class BookPaginator {
  static List<BookScreen> paginate(String text,{int targetChars=2100}) {
    if(text.isEmpty)return const [BookScreen(number:1,text:'')];
    if(targetChars<100)throw ArgumentError.value(targetChars);
    final result=<BookScreen>[];
    var start=0;
    while(start<text.length){
      final ideal=(start+targetChars).clamp(0,text.length);
      var end=ideal;
      if(ideal<text.length) {
        final newline=text.lastIndexOf('\n',ideal);
        final gap=targetChars~/3;
        if(newline>start+gap) {
          end=newline+1;
        } else {
          final space=text.lastIndexOf(' ',ideal);
          if(space>start+gap)end=space+1;
        }
      }
      if(end<=start)end=ideal;
      result.add(BookScreen(
        number:result.length+1,text:text.substring(start,end)));
      start=end;
    }
    return result;
  }
}

class SourceBookLibrary {
  const SourceBookLibrary();

  Future<BookChapter> load(int chapter,OfflineLibrary library) async {
    if(chapter<1 || chapter>26)throw ArgumentError.value(chapter,'chapter');
    // A previously imported, verified ZIP contains the *real* page mapping.
    final original=await library.pages(chapter);
    if(original.isNotEmpty) {
      return BookChapter(
        chapter:chapter,sourceName:'Páginas extraídas do PDF original',
        originalPages:original.length,exactPdfPages:true,
        screens:original.map((p)=>BookScreen(number:p.number,text:p.text))
          .toList(growable:false));
    }
    final name=chapter.toString().padLeft(2,'0');
    // Decode locally instead of spawning an isolate for chapters above 50KB.
    // It also keeps native-reader widget tests deterministic.
    final asset=await rootBundle.load('assets/books/chapter'+name+'.json');
    final source=utf8.decode(asset.buffer.asUint8List(
      asset.offsetInBytes,asset.lengthInBytes));
    final parsed=jsonDecode(source) as Map<String,dynamic>;
    if(parsed['chapter']!=chapter)throw FormatException(
      'Fonte do livro divergente: capítulo $chapter');
    final text=(parsed['body'] as String).replaceAll('\r\n','\n');
    if(text.length<2000)throw FormatException(
      'Transcrição incompleta no capítulo $chapter');
    return BookChapter(
      chapter:chapter,
      sourceName:(parsed['sourceName']??'PDF original').toString(),
      originalPages:(parsed['originalPageCount'] as num).toInt(),
      exactPdfPages:false,
      screens:BookPaginator.paginate(text),
    );
  }
}

class SourceExerciseSections {
  const SourceExerciseSections({required this.exercises,
    required this.answerKey});
  final String exercises;
  final String answerKey;
  bool get hasExercises=>exercises.trim().isNotEmpty;
  bool get hasAnswerKey=>answerKey.trim().isNotEmpty;

  static SourceExerciseSections fromOriginal(String content) {
    final source=content.replaceAll('\r','');
    // PDF text extraction often concatenates page footers and numbered
    // headings (e.g. "PÁGINA 724.13 — Exercícios graduais").
    // Find the last real section title even when it is not line-leading.
    final exercisePattern=RegExp(
      r'Exercícios\s+(?:graduais|graduados|e\s+avaliação|práticos|de\s+revisão)',
      caseSensitive:false);
    final keyPattern=RegExp(
      r'(?:Gabarito\s+comentado|Respostas\s+comentadas|Correção\s+comentada)',
      caseSensitive:false);
    final stopPattern=RegExp(
      r'(?:Glossário\s+(?:essencial|técnico)|Referências\s+bibliográficas|Próximos\s+passos)',
      caseSensitive:false);
    final exerciseMatches=exercisePattern.allMatches(source).toList();
    final keyMatches=keyPattern.allMatches(source).toList();
    if(exerciseMatches.isEmpty){
      return const SourceExerciseSections(exercises:'',answerKey:'');
    }
    // Prefer the last formal exercise section, not an incidental
    // early mention of "exercícios" in a pedagogical preface.
    final start=exerciseMatches.last.start;
    final nextKey=keyMatches.where((m)=>m.start>start).toList();
    final nextStop=stopPattern.allMatches(source)
      .where((m)=>m.start>start).toList();
    var end=source.length;
    if(nextKey.isNotEmpty)end=nextKey.first.start;
    if(nextStop.isNotEmpty && nextStop.first.start<end) {
      end=nextStop.first.start;
    }
    var answer='';
    if(nextKey.isNotEmpty) {
      final keyStart=nextKey.first.start;
      final keyStops=stopPattern.allMatches(source)
        .where((m)=>m.start>keyStart).toList();
      final keyEnd=keyStops.isEmpty?source.length:keyStops.first.start;
      answer=source.substring(keyStart,keyEnd).trim();
    }
    return SourceExerciseSections(
      exercises:source.substring(start,end).trim(),
      answerKey:answer,
    );
  }
}
