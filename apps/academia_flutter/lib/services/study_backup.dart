import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Portable study preferences only; never exports credentials or database files.
class StudyBackup {
  static const schema='academia-forense-study-backup-v1';
  static const maxBytes=16*1024*1024;
  static bool allowed(String key)=>RegExp(r'^(source_reader_(font|dark|last_chapter|page_\d+|marks_\d+|highlights_\d+)|academia_lesson_correct_\d+)$').hasMatch(key);

  static Uint8List encode(SharedPreferences prefs){
    final data=<String,dynamic>{};
    final keys=prefs.getKeys().where(allowed).toList()..sort();
    for(final key in keys){data[key]=prefs.get(key);}
    final body=jsonEncode(data);
    return Uint8List.fromList(utf8.encode(jsonEncode({
      'schema':schema,'createdAt':DateTime.now().toUtc().toIso8601String(),
      'data':body,'sha256':sha256.convert(utf8.encode(body)).toString(),
    })));
  }

  static Map<String,dynamic> decode(List<int> bytes){
    if(bytes.length>maxBytes)throw const FormatException('Backup excede o limite de 16 MB.');
    final root=jsonDecode(utf8.decode(bytes));
    if(root is! Map||root['schema']!=schema||root['data'] is! String)throw const FormatException('Formato de backup incompatível.');
    final body=root['data'] as String;
    if(sha256.convert(utf8.encode(body)).toString()!=root['sha256'])throw const FormatException('Backup corrompido: SHA-256 divergente.');
    final decoded=jsonDecode(body);
    if(decoded is! Map<String,dynamic>)throw const FormatException('Dados inválidos.');
    for(final e in decoded.entries){
      if(!allowed(e.key)||!_valid(e.key,e.value))throw FormatException('Registro inválido: '+e.key);
    }
    return decoded;
  }

  static bool _valid(String key,dynamic value){
    if(key=='source_reader_font')return value is num&&value>=12&&value<=36;
    if(key=='source_reader_dark'||key.startsWith('academia_lesson_correct_'))return value is bool;
    if(key.startsWith('source_reader_highlights_')){
      try{
        if(value is! String)return false;
        final rows=jsonDecode(value);
        return rows is List&&rows.every((r)=>r is Map&&r['page'] is int&&r['start'] is int&&r['end'] is int&&r['text'] is String);
      }catch(_){return false;}
    }
    if(key.startsWith('source_reader_marks_'))return value is List&&value.every((v)=>v is String&&(int.tryParse(v)??-1)>=0);
    return value is int&&value>=0;
  }

  /// Existing notes and bookmarks are unioned; existing settings are retained.
  /// Completed lessons are never reset by an older backup.
  static Future<int> merge(SharedPreferences prefs,Map<String,dynamic> data) async {
    final staged=<String,dynamic>{};
    for(final e in data.entries){
      if(!allowed(e.key)||!_valid(e.key,e.value))throw const FormatException('Registro inválido.');
      final current=prefs.get(e.key);
      if(current!=null&&!_valid(e.key,current))throw FormatException('Registro local ilegível: '+e.key);
      if(current==null){staged[e.key]=e.value;continue;}
      if(e.key.startsWith('source_reader_highlights_')){
        final existing=(jsonDecode(current as String) as List);
        final incoming=jsonDecode(e.value as String) as List;
        final unique=<String,dynamic>{};
        for(final row in [...existing,...incoming]){
          final ordered=Map<String,dynamic>.from(row as Map);
          final keys=ordered.keys.toList()..sort();
          final canonical=jsonEncode({for(final k in keys)k:ordered[k]});
          unique[canonical]=row;
        }
        staged[e.key]=jsonEncode(unique.values.toList());
      }else if(e.key.startsWith('source_reader_marks_')){
        staged[e.key]=<String>{...(current as List).cast<String>(),...(e.value as List).cast<String>()}.toList();
      }else if(e.key.startsWith('academia_lesson_correct_')){
        staged[e.key]=(current as bool)||(e.value as bool);
      }
    }
    final original={for(final key in staged.keys)key:prefs.get(key)};
    try{
      for(final e in staged.entries){if(!await _write(prefs,e.key,e.value))throw StateError('Falha de gravação: '+e.key);}
    }catch(_){
      for(final e in original.entries){
        if(e.value==null){await prefs.remove(e.key);}else{await _write(prefs,e.key,e.value);}
      }
      rethrow;
    }
    return staged.length;
  }
  static Future<bool> _write(SharedPreferences p,String k,dynamic v){
    if(v is bool)return p.setBool(k,v);
    if(k=='source_reader_font'&&v is num)return p.setDouble(k,v.toDouble());
    if(v is int)return p.setInt(k,v);
    if(v is double)return p.setDouble(k,v);
    if(v is String)return p.setString(k,v);
    if(v is List)return p.setStringList(k,v.cast<String>());
    throw const FormatException('Tipo inválido.');
  }

  static Future<bool> exportFile() async {
    final bytes=encode(await SharedPreferences.getInstance());
    final name='Academia-Forense-Caderno-'+DateTime.now().toIso8601String().replaceAll(':','-')+'.json';
    return (await FilePicker.platform.saveFile(dialogTitle:'Salvar backup de estudos',fileName:name,bytes:bytes))!=null;
  }
  static Future<Map<String,dynamic>?> pickBackup() async {
    final picked=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['json'],allowMultiple:false,withData:false);
    if(picked==null)return null;
    final f=picked.files.single;
    if(f.size>maxBytes)throw const FormatException('Backup excede o limite.');
    final bytes=f.bytes??await File(f.path!).readAsBytes();
    return decode(bytes);
  }
}
