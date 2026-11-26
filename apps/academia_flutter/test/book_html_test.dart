import 'package:flutter_test/flutter_test.dart';
import 'package:academia_flutter/chapters/book_html.dart';

void main(){
  test('PDF lines are assembled into paragraphs with real justified HTML',(){
    const source='24.1 — O que a estatística descritiva realmente faz?\n'
      'Em linguagem cotidiana: imagine cem linhas de chamadas em uma\n'
      'tabela. Ler cada uma pode ser difícil.\n'
      'A estatística resume os registros observados.\n'
      'Figura 1. Distribuição de eventos\n'
      'REGRA NORTEADORA\n'
      'Hash igual não comprova autoria.';
    final html=SourceHtmlConverter.pageHtml(source,
      fontSize:19,chapter:24,screen:0);
    expect(html,contains('text-align:justify'));
    expect(html,contains('font-size:19.0px'));
    expect(html,contains('<h2 id="b0"'));
    expect(html,contains('Em linguagem cotidiana:'));
    expect(html,contains('<strong>Em linguagem cotidiana:</strong>'));
    expect(html,contains('<figcaption'));
    expect(html,contains('<aside'));
    expect(html,contains('tabela. Ler cada uma pode ser difícil.'));
    expect(html,contains('lang="pt-BR"'));
    expect(html,contains('BookBridge.postMessage'));
  });

  test('All original non-empty text is represented in HTML fragments',(){
    const text='1.1 — Seção\n'
      'Um conteúdo com <tags> & símbolos especiais.\n'
      'Outro trecho composto.\n'
      'Figura 2. Legenda';
    final parts=SourceHtmlConverter.parse(text);
    expect(parts.length,greaterThan(1));
    final html=SourceHtmlConverter.pageHtml(text,
      fontSize:17,chapter:1,screen:0);
    expect(html,contains('&lt;tags&gt; &amp; símbolos'));
    expect(html,contains('Outro trecho composto.'));
    expect(html,contains('Figura 2. Legenda'));
    expect(html,contains('content="default-src'));
  });

  test('Stable paragraph IDs and saved highlighting anchors',(){
    const source='1.1 — Título\n'
      'Uma linha com integridade verificável.';
    final html=SourceHtmlConverter.pageHtml(source,
      fontSize:17,chapter:1,screen:2,
      highlights:const [
        {'page':2,'start':-1,'end':-1,'text':'integridade',
        'htmlBlock':'b1','htmlStart':14,'htmlEnd':24},
      ]);
    expect(html,contains('"block":"b1"'));
    expect(html,contains('"quote":"integridade"'));
    expect(html,contains('mark.saved'));
    expect(html,contains("mark.className='saved'"));
  });

  test('Volume I cover and editorial labels render without spaced letters',(){
    const cover='E N C I C L O P É D I A  D E  C I Ê N C I A S  F O R E N S E S  ·  V O L U M E  1';
    final html=SourceHtmlConverter.pageHtml(cover,fontSize:15,chapter:1,screen:0,
      layout:const [
        {'kind':'h4','text':cover},
        {'kind':'h2','text':'Dos dados\nàs evidências'},
        {'kind':'p','text':'Fundamentos do raciocínio forense'},
        {'kind':'h4','text':'N O TA A O  L E I T O R'},
      ]);
    expect(html,contains('<small id="b0"'));
    expect(html,contains('Enciclopédia de Ciências Forenses · Volume 1'));
    expect(html,isNot(contains(cover)));
    expect(html,contains('Nota ao leitor'));
    expect(html,contains('Fundamentos do raciocínio forense'));
    expect(html,contains('letter-spacing:normal'));
  });


  test('legacy cover joins title, separates glued note and excludes print metadata from speech',(){
    const raw='Dos dados\nàs evidências\n'
      'Capítulo 1 · Edição inaugural 12 novembro 2026 · A4 · PDF pesquisável\n'
      'EDIÇÃO REVISADA 2 · NOVEMBRO 2026N O TA A O L E I T O R\n'
      'Este volume foi escrito para quem está retomando os estudos.\n'
      'O texto deve ser memoriza‐\ndo.';
    final html=SourceHtmlConverter.pageHtml(raw,fontSize:19,chapter:1,screen:0);
    final speech=SourceHtmlConverter.narrationText(raw);
    expect(html,contains('Dos dados às evidências'));
    expect(html,contains('Nota ao leitor'));
    expect(html,isNot(contains('PDF pesquisável')));
    expect(html,isNot(contains('2026N O TA')));
    expect(speech,contains('Nota ao leitor'));
    expect(speech,contains('memorizado'));
    expect(speech,isNot(contains('EDIÇÃO REVISADA')));
    expect(speech,isNot(contains('Edição inaugural')));
  });

  test('structured speech follows the displayed page and excludes cover imprint',(){
    const layout=[
      {'kind':'h4','text':'E N C I C L O P É D I A D E C I Ê N C I A S F O R E N S E S · V O L U M E 1'},
      {'kind':'h2','text':'Título desta página'},
      {'kind':'p','text':'Somente o conteúdo aberto.'},
      {'kind':'pre','text':'Capítulo 1 · Edição inaugural\n12 novembro 2026 · A4 · PDF pesquisável'},
    ];
    final speech=SourceHtmlConverter.narrationText('Texto bruto diferente',layout:layout);
    expect(speech,contains('Título desta página'));
    expect(speech,contains('Somente o conteúdo aberto.'));
    expect(speech,isNot(contains('Texto bruto diferente')));
    expect(speech,isNot(contains('PDF pesquisável')));
  });

}
