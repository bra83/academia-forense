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
}
