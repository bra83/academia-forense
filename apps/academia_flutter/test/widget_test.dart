import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:academia_flutter/main.dart';

void main() {
  late AppDatabase testDb;

  setUp(() {
    testDb = AppDatabase(DatabaseConnectionFactory.inMemory());
  });

  tearDown(() async {
    await testDb.close();
  });

  testWidgets('AcademiaForenseApp renders home screen, cards, and navigates tabs', (WidgetTester tester) async {
    // Set mobile viewport
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(AcademiaForenseApp(database: testDb));
    await tester.pumpAndSettle();

    // Verify initial Início tab
    expect(find.text('Academia Forense'), findsWidgets);
    expect(find.text('Meta Semanal de Estudos (§17.1)'), findsOneWidget);
    expect(find.text('Volume I — Preservação Editorial (§24.2)'), findsOneWidget);

    // Tap 'Estudar' (tab 1)
    await tester.tap(find.text('Estudar'));
    await tester.pumpAndSettle();
    expect(find.text('Plano de Estudos'), findsOneWidget);
    expect(find.textContaining('Capítulo 01:'), findsOneWidget);

    // Tap 'Biblioteca' (tab 2)
    await tester.tap(find.text('Biblioteca'));
    await tester.pumpAndSettle();
    expect(find.text('Biblioteca Forense'), findsOneWidget);
    expect(find.textContaining('Volume I: Fundamentos'), findsOneWidget);

    // Tap 'Laboratório' (tab 3)
    await tester.tap(find.text('Laboratório'));
    await tester.pumpAndSettle();
    expect(find.text('Laboratórios Periciais'), findsOneWidget);
    expect(find.text('Telefonia: Cruzamento de CDRs e ERBs'), findsOneWidget);

    // Tap 'Meu Espaço' (tab 4)
    await tester.tap(find.text('Meu Espaço'));
    await tester.pumpAndSettle();
    expect(find.text('Meu Espaço'), findsWidgets);
    expect(find.text('Matriz de Competências'), findsOneWidget);
  });

  testWidgets('AcademiaForenseApp renders lateral rail on desktop viewport', (WidgetTester tester) async {
    // Set desktop viewport (>= 800dp)
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(AcademiaForenseApp(database: testDb));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Estudar tab runs 80% assessment gate, Kokoro TTS, and Gemini RAG Tutor', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(AcademiaForenseApp(database: testDb));
    await tester.pumpAndSettle();

    // Navigate to Estudar
    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();

    // Run 80% passing assessment
    expect(find.text('Avaliar (Corte 80%)'), findsOneWidget);
    await tester.tap(find.text('Avaliar (Corte 80%)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Resultado da Avaliação: APROVADO (100.0%)'), findsOneWidget);

    // Run Kokoro TTS paragraph reader
    expect(find.text('Ler Parágrafo'), findsOneWidget);
    await tester.tap(find.text('Ler Parágrafo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Reproduzindo parágrafo 1'), findsOneWidget);

    // Run Gemini RAG Tutor
    await tester.tap(find.text('Consultar Tutor com Citação Verificável'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Digite uma pergunta'), findsWidgets);
  });

  testWidgets('Biblioteca tab switches Dual-Mode Reader, shows errata, and triggers Drive sync', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(AcademiaForenseApp(database: testDb));
    await tester.pumpAndSettle();

    // Navigate to Biblioteca
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    // Toggle errata panel
    expect(find.text('Ver Erratas Digitais (A1–A4)'), findsOneWidget);
    await tester.tap(find.text('Ver Erratas Digitais (A1–A4)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('SWGDE 18-F-002-2.0'), findsOneWidget);

    // Trigger incremental sync
    expect(find.text('Sincronizar Conteúdo'), findsOneWidget);
    await tester.tap(find.text('Sincronizar Conteúdo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Estado Google Drive OAuth:'), findsOneWidget);
  });

  testWidgets('Laboratório tab allows executing lab and displays diagnostics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(AcademiaForenseApp(database: testDb));
    await tester.pumpAndSettle();

    // Navigate to Laboratório
    await tester.tap(find.byIcon(Icons.biotech_outlined));
    await tester.pumpAndSettle();

    // Tap Executar Laboratório
    expect(find.text('Executar Laboratório'), findsOneWidget);
    await tester.tap(find.text('Executar Laboratório'));
    await tester.pumpAndSettle();

    // Verify diagnostic card appears
    expect(find.text('Diagnóstico da Execução Forense'), findsOneWidget);
    expect(find.textContaining('TELEFONIA FORENSE'), findsOneWidget);
  });

  testWidgets('Meu Espaço tab exports signed PDF report and verifies signature', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(AcademiaForenseApp(database: testDb));
    await tester.pumpAndSettle();

    // Navigate to Meu Espaço
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    // Tap Exportar Relatório PDF
    expect(find.text('Exportar Relatório PDF'), findsOneWidget);
    await tester.tap(find.text('Exportar Relatório PDF'));
    await tester.pumpAndSettle();

    // Verify Laudo Pericial Emitido appears with signature and disclaimer
    expect(find.text('Laudo Pericial Emitido'), findsOneWidget);
    expect(find.textContaining('Assinatura SHA-256'), findsOneWidget);
    expect(find.textContaining('DECLARAÇÃO EDUCACIONAL INTERNA'), findsOneWidget);
  });
}
