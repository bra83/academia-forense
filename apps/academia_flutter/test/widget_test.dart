import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:academia_flutter/main.dart';
import 'package:academia_flutter/chapters/study_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(DatabaseConnectionFactory.inMemory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> start(WidgetTester tester, {double w = 1280, double h = 1600}) async {
    tester.view.physicalSize = Size(w, h);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(AcademiaForenseApp(database: db));
    await tester.pumpAndSettle();
  }

  Future<void> awaitChapterList(WidgetTester tester) async {
    for (var attempt = 0; attempt < 50; attempt++) {
      await tester.runAsync(() => Future<void>.delayed(
        const Duration(milliseconds: 10),
      ));
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Abrir capítulo').evaluate().isNotEmpty) return;
    }
    fail('O catálogo não ficou acessível na Biblioteca.');
  }

  test('Catálogo local não fabrica capítulos ausentes nem confunde revisão', () async {
    final chapters = await StudyCatalog.loadBundledPreviews();
    expect(chapters.length, 26);
    expect(chapters.first.number, 1);
    expect(chapters.first.title, 'Dos dados às evidências');
    expect(chapters.last.number, 26);
    expect(chapters.first.originalPdfUrl.contains('/file/d/'), isTrue);
    expect(chapters.first.sections.isNotEmpty, isTrue);
  });

  testWidgets('Cinco abas e catálogo legível em tela Android', (tester) async {
    await start(tester, w: 412, h: 915);
    expect(find.text('Academia Forense'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('Biblioteca'));
    await tester.pump();
    await awaitChapterList(tester);
    expect(find.text('Biblioteca Forense'), findsOneWidget);
    expect(find.textContaining('26 PDFs foram referenciados'), findsOneWidget);
    expect(find.textContaining('Cap. 01'), findsWidgets);
    expect(find.text('Sincronizar Conteúdo'), findsNothing);
  });

  testWidgets('Navegação desktop tem barra lateral', (tester) async {
    await start(tester);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Competências não podem começar com percentuais fictícios', (tester) async {
    await start(tester);
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Matriz de Competências'), findsOneWidget);
    expect(find.textContaining('Sem proficiência mensurada'), findsOneWidget);
    expect(find.textContaining('88%'), findsNothing);
    expect(find.textContaining('18.5h'), findsNothing);
    expect(find.textContaining('7/7'), findsNothing);
  });

  testWidgets('Avaliação não pode aprovar automaticamente', (tester) async {
    await start(tester);
    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Situação da avaliação'), findsOneWidget);
    await tester.tap(find.text('Situação da avaliação'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Avaliação indisponível'), findsWidgets);
    expect(find.textContaining('APROVADO (100.0%)'), findsNothing);
  });

  testWidgets('Leitor de capítulos abre o conteúdo local sem fingir PDF integral', (tester) async {
    await start(tester);
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pump();
    await awaitChapterList(tester);
    await tester.tap(find.text('Abrir capítulo').first);
    await tester.pumpAndSettle();
    expect(find.text('Dos dados às evidências'), findsWidgets);
    expect(find.text('Abrir PDF integral no Google Drive'), findsOneWidget);
    expect(find.textContaining('somente trechos de pré-visualização'), findsWidgets);
  });

  testWidgets('Laboratório CDR grava com FK válida e nunca marca aprovação', (tester) async {
    await start(tester);
    await tester.tap(find.byIcon(Icons.biotech_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Executar Laboratório'), findsOneWidget);
    await tester.tap(find.text('Executar Laboratório'));
    await tester.pumpAndSettle();
    final runs = await db.customSelect(
      'SELECT laboratory_id, is_passed FROM laboratory_runs',
    ).get();
    expect(runs.length, 1);
    expect(runs.first.read<int>('is_passed'), 0);
    expect(find.textContaining('Exemplo executado e salvo'), findsWidgets);
    expect(find.textContaining('FOREIGN KEY constraint failed'), findsNothing);
  });

  testWidgets('Exportação não declara um PDF inexistente como assinado', (tester) async {
    await start(tester);
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Ver situação da exportação PDF'), findsOneWidget);
    await tester.tap(find.text('Ver situação da exportação PDF'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nenhum PDF foi salvo'), findsWidgets);
    expect(find.text('Laudo Pericial Emitido'), findsNothing);
  });
}
