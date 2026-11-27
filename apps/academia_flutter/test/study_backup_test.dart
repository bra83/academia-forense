import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:academia_flutter/services/study_backup.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  test('study backup excludes credentials and detects altered payload',() async {
    SharedPreferences.setMockInitialValues({'source_reader_page_10':2,'source_reader_font':19.0,'gemini_api_key':'private'});
    final p=await SharedPreferences.getInstance();
    final bytes=StudyBackup.encode(p);
    final data=StudyBackup.decode(bytes);
    expect(data['source_reader_page_10'],2);
    expect(data.containsKey('gemini_api_key'),isFalse);
    final changed=jsonDecode(utf8.decode(bytes)) as Map;
    changed['data']='{}';
    expect(()=>StudyBackup.decode(utf8.encode(jsonEncode(changed))),throwsFormatException);
  });
  test('restore merges notes, retains local settings and never resets completed lessons',() async {
    final a={'page':1,'start':0,'end':3,'text':'abc'};
    final b={'page':2,'start':0,'end':3,'text':'def'};
    SharedPreferences.setMockInitialValues({
      'source_reader_highlights_10':jsonEncode([a]),'source_reader_font':22.0,
      'source_reader_marks_10':['1'],'academia_lesson_correct_10':true,
    });
    final p=await SharedPreferences.getInstance();
    final data={'source_reader_highlights_10':jsonEncode([a,b]),
      'source_reader_font':15.0,'source_reader_marks_10':['2'],
      'academia_lesson_correct_10':false,'source_reader_page_10':7};
    await StudyBackup.merge(p,data);
    await StudyBackup.merge(p,data);
    expect(jsonDecode(p.getString('source_reader_highlights_10')!),[a,b]);
    expect(p.getDouble('source_reader_font'),22.0);
    expect(p.getStringList('source_reader_marks_10'),['1','2']);
    expect(p.getBool('academia_lesson_correct_10'),true);
    expect(p.getInt('source_reader_page_10'),7);
  });
}
