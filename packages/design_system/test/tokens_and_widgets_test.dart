import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

void main() {
  group('ForensicCard Widget (§5.1)', () {
    testWidgets('renders title, subtitle, child and triggers onTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ForensicTheme.lightTheme,
          home: Scaffold(
            body: ForensicCard(
              title: 'Evidência #01',
              subtitle: 'Registro de Metadados',
              onTap: () => tapped = true,
              child: const Text('Conteúdo do laudo pericial'),
            ),
          ),
        ),
      );

      expect(find.text('Evidência #01'), findsOneWidget);
      expect(find.text('Registro de Metadados'), findsOneWidget);
      expect(find.text('Conteúdo do laudo pericial'), findsOneWidget);

      await tester.tap(find.byType(ForensicCard));
      expect(tapped, isTrue);
    });
  });

  group('Forensic Buttons (§5.1 - 48dp minimum touch target)', () {
    testWidgets('ForensicPrimaryButton has minimum 48dp height and handles tap', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ForensicTheme.lightTheme,
          home: Scaffold(
            body: ForensicPrimaryButton(
              label: 'Iniciar Exame',
              icon: const Icon(Icons.play_arrow),
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      final Finder buttonFinder = find.byType(ForensicPrimaryButton);
      expect(buttonFinder, findsOneWidget);

      final Size size = tester.getSize(buttonFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));

      await tester.tap(buttonFinder);
      expect(pressed, isTrue);
    });

    testWidgets('ForensicSecondaryButton and OutlinedButton enforce >= 48dp target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ForensicTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                ForensicSecondaryButton(
                  label: 'Revisar',
                  onPressed: () {},
                ),
                ForensicOutlinedButton(
                  label: 'Cancelar',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      final Size secSize = tester.getSize(find.byType(ForensicSecondaryButton));
      final Size outSize = tester.getSize(find.byType(ForensicOutlinedButton));

      expect(secSize.height, greaterThanOrEqualTo(48.0));
      expect(outSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Buttons in loading state disable onTap and show progress spinner', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ForensicTheme.lightTheme,
          home: Scaffold(
            body: ForensicPrimaryButton(
              label: 'Processando',
              isLoading: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(ForensicPrimaryButton));
      expect(pressed, isFalse);
    });
  });

  group('Forensic State Views (§5.1)', () {
    testWidgets('ForensicLoadingView renders custom loading message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ForensicLoadingView(message: 'Carregando caso de estudo...'),
          ),
        ),
      );

      expect(find.text('Carregando caso de estudo...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ForensicErrorView renders error message and triggers retry', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ForensicTheme.lightTheme,
          home: Scaffold(
            body: ForensicErrorView(
              title: 'Falha de Conexão',
              message: 'Não foi possível carregar a revisão do capítulo.',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Falha de Conexão'), findsOneWidget);
      expect(find.text('Não foi possível carregar a revisão do capítulo.'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      expect(retried, isTrue);
    });

    testWidgets('ForensicEmptyView renders empty state and CTA', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ForensicTheme.lightTheme,
          home: Scaffold(
            body: ForensicEmptyView(
              title: 'Nenhuma anotação encontrada',
              message: 'Você ainda não fez destaques neste capítulo.',
              actionLabel: 'Criar Anotação',
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Nenhuma anotação encontrada'), findsOneWidget);
      await tester.tap(find.text('Criar Anotação'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('ForensicSuccessView renders success message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ForensicSuccessView(
              title: 'Avaliação Concluída',
              message: 'Você atingiu 85% de proficiência.',
            ),
          ),
        ),
      );

      expect(find.text('Avaliação Concluída'), findsOneWidget);
      expect(find.text('Você atingiu 85% de proficiência.'), findsOneWidget);
    });
  });

  group('Dual Responsive Navigation (§5.2)', () {
    testWidgets('Narrow screen (<800dp) displays 5-tab Bottom NavigationBar', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ForensicTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return ForensicResponsiveScaffold(
                currentIndex: selectedIndex,
                onNavigationIndexChanged: (idx) {
                  setState(() => selectedIndex = idx);
                },
                body: Center(child: Text('Current: $selectedIndex')),
              );
            },
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      // Verify all 5 canonical tabs
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Estudar'), findsOneWidget);
      expect(find.text('Biblioteca'), findsOneWidget);
      expect(find.text('Laboratório'), findsOneWidget);
      expect(find.text('Meu Espaço'), findsOneWidget);

      // Tap on 'Laboratório' (tab 3)
      await tester.tap(find.text('Laboratório'));
      await tester.pumpAndSettle();
      expect(selectedIndex, equals(3));
      expect(find.text('Current: 3'), findsOneWidget);
    });

    testWidgets('Wide screen (>=800dp) displays lateral NavigationRail', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      int selectedIndex = 1;

      await tester.pumpWidget(
        MaterialApp(
          theme: ForensicTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return ForensicResponsiveScaffold(
                currentIndex: selectedIndex,
                onNavigationIndexChanged: (idx) {
                  setState(() => selectedIndex = idx);
                },
                body: const Center(child: Text('Desktop Workspace')),
              );
            },
          ),
        ),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Desktop Workspace'), findsOneWidget);
    });
  });
}
