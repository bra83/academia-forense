import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:persistence_core/persistence_core.dart';
import 'academy_v2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AcademiaForenseApp());
}

class AcademiaForenseApp extends StatefulWidget {
  const AcademiaForenseApp({super.key,this.database});
  final AppDatabase? database;

  @override
  State<AcademiaForenseApp> createState()=>_AcademiaForenseAppState();
}

class _AcademiaForenseAppState extends State<AcademiaForenseApp> {
  late final AppDatabase _db;
  late final bool _ownsDatabase;

  @override
  void initState() {
    super.initState();
    _ownsDatabase=widget.database==null;
    _db=widget.database??AppDatabase(DatabaseConnectionFactory.onDisk());
  }

  @override
  void dispose() {
    if(_ownsDatabase) {
      _db.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context)=>MaterialApp(
    title:'Academia Forense — Laboratório de Formação',
    theme:ForensicTheme.lightTheme,
    debugShowCheckedModeBanner:false,
    builder:(context,child)=>MediaQuery(
      data:MediaQuery.of(context).copyWith(
        textScaler:MediaQuery.textScalerOf(context).clamp(maxScaleFactor:1.6)),
      child:child!),
    home:AcademiaV2Screen(database:_db),
  );
}
