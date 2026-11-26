import 'dart:convert';

/// Converts the complete PDF text transcription into formatted HTML on device.
/// It never substitutes summarized or generated material for the PDF text.
class SourceHtmlConverter {
  const SourceHtmlConverter._();

  static final RegExp section=RegExp(r'^\d{1,3}\.\d{1,2}(?:\.\d+)?\s*[—–.:]?\s*\S');
  static final RegExp heading=RegExp(r'^(?:Como usar esta enciclop[eé]dia|O que voc[eê] ser[aá] capaz|O que este cap[ií]tulo|Objetivos e pr[eé]-requisitos|Terminologia|Exemplo inteiramente explicado|Gloss[aá]rio|Gabarito|Exerc[ií]cios graduad|Refer[eê]ncias|Pr[oó]ximos passos|Arquitetura dos volumes|As quatro escalas|Popula[cç][aã]o, amostra|M[eé]dia ponderada|Cadeia de cust[oó]dia)\b',caseSensitive:false);
  static final RegExp caption=RegExp(r'^(?:Figura|Tabela|Quadro|Gr[aá]fico)\s*\d+[\s.:]',caseSensitive:false);
  static final RegExp callout=RegExp(r'^(?:REGRA NORTEADORA|REGRA DE SEGURAN[CÇ]A|ATEN[CÇ][AÃ]O|CUIDADO|AVISO|ERRO COMUM|IMPORTANTE)(?:[:\s]|$)',caseSensitive:false);
  static final RegExp footer=RegExp(r'^(?:ENCICLOP[EÉ]DIA DE CI[EÊ]NCIAS FORENSES|FORMA[CÇ][AÃ]O T[EÉ]CNICO-CIENT[IÍ]FICA|EDI[CÇ][AÃ]O DE ESTUDO|P[AÁ]GINA\s+\d+|C\s*A\s*P\s*[IÍ]\s*T\s*U\s*L\s*O|E\s*N\s*C\s*I\s*C\s*L\s*O\s*P)',caseSensitive:false);
  static final RegExp lead=RegExp(r'^((?:Em linguagem (?:cotidiana|profissional)|Exemplo (?:guiado|resolvido(?: \d+)?|forense)|Defini[cç][aã]o t[eé]cnica(?:\s*[-–]\s*[^:]+)?|Objetivo central|N[ií]vel|Pr[eé]-requisitos|Regra de seguran[cç]a|Unidade de observa[cç][aã]o|Termos profissionais|Erro comum|Fonte|Metadado|Artefato digital)[:.])',caseSensitive:false);

  static String escape(String text) => text.replaceAll('&','&amp;')
    .replaceAll('<','&lt;').replaceAll('>','&gt;')
    .replaceAll('"','&quot;').replaceAll("'",'&#39;');

  static String role(String line) {
    if(section.hasMatch(line) || RegExp(r'^\d{1,3}\.\s+[A-Za-zÀ-ÿ]').hasMatch(line))return 'h2';
    if(caption.hasMatch(line))return 'figcaption';
    if(heading.hasMatch(line)||line=='Nota ao leitor'||line=='Mapa da coleção')return 'h3';
    if(callout.hasMatch(line))return 'aside';
    if(footer.hasMatch(line))return 'small';
    if(['Dos dados','às evidências','Estatística descritiva',
      'Computador, armazenamento e','ambiente de trabalho','Dos dados às evidências'].contains(line))return 'h1';
    if(RegExp(r'^[A-ZÁÉÍÓÚÃÕÊÔÇ\d\s·|–—-]{8,}$').hasMatch(line)&&line.length<100)return 'h4';
    return 'p';
  }

  static List<HtmlBlock> parse(String text) {
    final lines=text.replaceAll('\r\n','\n').split('\n');
    final blocks=<HtmlBlock>[];
    var paragraph='';
    void flush(){
      if(paragraph.trim().isEmpty){paragraph='';return;}
      blocks.add(HtmlBlock('b${blocks.length}','p',paragraph.trim()));
      paragraph='';
    }
    for(final raw in lines){
      final line=raw.trim();
      if(line.isEmpty){flush();continue;}
      final type=role(line);
      if(type!='p'){
        flush();
        blocks.add(HtmlBlock('b${blocks.length}',type,line));
        continue;
      }
      if(paragraph.isEmpty && blocks.isNotEmpty &&
          blocks.last.kind=='h2' && line.length<65 &&
          RegExp(r'^[a-zà-ÿ]').hasMatch(line) &&
          !RegExp(r'[.!?]$').hasMatch(blocks.last.text)){
        final prev=blocks.removeLast();
        blocks.add(HtmlBlock(prev.id,'h2',prev.text+' '+line));
        continue;
      }
      if(paragraph.isEmpty){paragraph=line;continue;}
      if(RegExp(r'[.!?]["”»]?$').hasMatch(paragraph) &&
         RegExp(r'^[A-ZÁÀÃÂÉÊÍÓÔÕÚÇ]').hasMatch(line) &&
         paragraph.length>75) {
        flush();paragraph=line;
      } else if(paragraph.endsWith('‐')||paragraph.endsWith('\u00ad')){
        paragraph=paragraph.substring(0,paragraph.length-1)+line;
      } else {
        paragraph='$paragraph $line';
      }
    }
    flush();
    return blocks;
  }

  // Only known editorial labels are normalized; source text and page IDs stay unchanged.
  static String compactEditorial(String raw) {
    final key=raw.toUpperCase().replaceAll(RegExp(r'\s+'),'');
    final cover=RegExp(r'^ENCICLOPÉDIADECIÊNCIASFORENSES[·•]VOLUME([IVXLCDM]+|\d+)$').firstMatch(key);
    if(cover!=null)return 'Enciclopédia de Ciências Forenses · Volume '+cover.group(1)!;
    final guide=RegExp(r'^GUIADEESTUDO/CAPÍTULO(\d+)$').firstMatch(key);
    if(guide!=null)return 'Guia de estudo · Capítulo '+guide.group(1)!;
    final part=RegExp(r'^CAPÍTULO(\d+)[·•](\d+)DE(\d+)$').firstMatch(key);
    if(part!=null)return 'Capítulo '+part.group(1)!+' · '+part.group(2)!+' de '+part.group(3)!;
    if(key=='NOTAAOLEITOR')return 'Nota ao leitor';
    if(key=='MAPADACOLEÇÃO')return 'Mapa da coleção';
    if(key=='APÊNDICEA')return 'Apêndice A';
    return raw;
  }

  static bool editorialLabel(String raw) {
    final key=raw.toUpperCase().replaceAll(RegExp(r'\s+'),'');
    return key.startsWith('ENCICLOPÉDIADECIÊNCIASFORENSES') ||
      key.startsWith('FORMAÇÃOTÉCNICO-CIENTÍFICA') ||
      key.startsWith('EDIÇÃOREVISADA') ||
      RegExp(r'^CAPÍTULO\d+[·•]\d+DE\d+$').hasMatch(key);
  }

  static String cleanLineBreaks(String raw) {
    return raw.replaceAll(RegExp(r'[\u00ad\u2010]\s*\n\s*'),'')
      .replaceAll('\u00ad','').replaceAll(RegExp(r'[ \t]+'),' ');
  }

  // Remove only known repeated printing furniture from the reading view.
  // The original page text and PDF remain unchanged for search and evidence.
  static String readingSource(String raw) {
    var s=cleanLineBreaks(raw);
    s=s.replaceAllMapped(RegExp(r'(EDIÇÃO REVISADA\s+\d+\s*·\s*[A-ZÀ-Ü]+\s+\d{4})(?=N\s*O\s*T\s*A\s*A\s*O\s*L\s*E\s*I\s*T\s*O\s*R)',caseSensitive:false),(m)=>m[1]!+'\n');
    s=s.replaceAll(RegExp(r'^\s*Capítulo\s+\d+\s*·\s*Edição inaugural[^\n]*(?:\n[ \t]*\d{1,2}\s+[a-zç]+\s+\d{4}[^\n]*)?PDF pesquisável\s*$',caseSensitive:false,multiLine:true),'');
    s=s.replaceAll(RegExp(r'^\s*EDIÇÃO REVISADA\s+\d+\s*·\s*[A-ZÀ-Ü]+\s+\d{4}\s*$',caseSensitive:false,multiLine:true),'');
    s=s.replaceAll(RegExp(r'^\s*ENCICLOPÉDIA DE CIÊNCIAS FORENSES\s+VOLUME\s+[IVXLCDM\d]+\s*·\s*CAPÍTULO\s+\d+[ \t]*$',caseSensitive:false,multiLine:true),'');
    s=s.replaceAll(RegExp(r'^[ \t]*FORMAÇÃO TÉCNICO-CIENTÍFICA\s*·\s*EDIÇÃO\s+\d{4}[ \t]+\d+',caseSensitive:false,multiLine:true),'\n');
    s=s.replaceAllMapped(RegExp(r'^[ \t]*N\s*O\s*T\s*A\s*A\s*O\s*L\s*E\s*I\s*T\s*O\s*R[ \t]*$',caseSensitive:false,multiLine:true),(_)=>'Nota ao leitor');
    s=s.replaceAllMapped(RegExp(r'^[ \t]*M\s*A\s*P\s*A\s*D\s*A\s*C\s*O\s*L\s*E\s*Ç\s*Ã\s*O[ \t]*$',caseSensitive:false,multiLine:true),(_)=>'Mapa da coleção');
    s=s.replaceAllMapped(RegExp(r'^Dos dados\s*\n\s*às evidências[ \t]*$',multiLine:true),(_)=>'Dos dados às evidências');
    return s;
  }

  static bool printingFurniture(String raw) {
    final t=raw.trim();
    return editorialLabel(t) ||
      RegExp(r'^Capítulo\s+\d+\s*·\s*Edição inaugural',caseSensitive:false).hasMatch(t) ||
      RegExp(r'^\d{1,2}\s+[a-zç]+\s+\d{4}\s*·\s*A4\s*·\s*PDF pesquisável$',caseSensitive:false).hasMatch(t) ||
      RegExp(r'^(?:Página\s+)?\d{1,4}$',caseSensitive:false).hasMatch(t);
  }

  static String narrationText(String source,{List<Map<String,dynamic>> layout=const []}) {
    final blocks=layout.isEmpty?parse(readingSource(source)):layout.map((b)=>HtmlBlock('',b['kind'].toString(),b['text'].toString())).toList();
    final parts=<String>[];
    for(var i=0;i<blocks.length;i++){
      final b=blocks[i];
      if(b.kind=='pre'){
        if(!printingFurniture(b.text))parts.add('Bloco de código ou dados técnicos disponível para consulta na página.');
        continue;
      }
      final cleaned=compactEditorial(readingSource(b.text)).replaceAll(RegExp(r'\s+'),' ').trim();
      if(cleaned.isEmpty||printingFurniture(cleaned))continue;
      parts.add(cleaned);
      if(b.kind=='figure'&&layout.isNotEmpty){
        final alt=(layout[i]['alt']??'').toString().trim();
        if(alt.isNotEmpty&&!cleaned.contains(alt))parts.add('Descrição do diagrama: '+alt);
      }
    }
    return parts.join('\n\n');
  }

  static String blockHtml(HtmlBlock block) {
    final raw=compactEditorial(readingSource(block.text)).trim();
    if(raw.isEmpty||RegExp(r'^Capítulo\s+\d+\s*·\s*Edição inaugural',caseSensitive:false).hasMatch(raw))return '';
    var formatted=escape(raw);
    if(block.kind=='p'){
      final match=lead.firstMatch(raw);
      if(match!=null) {
        formatted='<strong>${escape(raw.substring(0,match.end))}</strong>'
          +escape(raw.substring(match.end));
      }
    }
    final tag=editorialLabel(block.text)?'small':block.kind=='h1'?'h1':block.kind=='h2'?'h2':
      block.kind=='h3'?'h3':block.kind=='h4'?'h4':
      block.kind=='figcaption'?'figcaption':block.kind=='aside'?'aside':
      block.kind=='small'?'small':block.kind=='pre'?'pre':'p';
    return '<$tag id="${block.id}" data-pdf="true">$formatted</$tag>';
  }

  static String richBlockHtml(HtmlBlock block,Map<String,dynamic> data){
    final id=block.id;
    final t=escape(block.text);
    if(block.kind=='table' && data['rows'] is List){
      final rows=data['rows'] as List;
      final body=rows.asMap().entries.map((entry){
        final tag=entry.key==0?'th':'td';
        return '<tr>'+ (entry.value as List).map((cell)=>'<$tag>'+escape(cell.toString())+'</$tag>').join()+'</tr>';
      }).join();
      final caption=escape((data['caption']??'').toString());
      return '<div id="$id">'+(caption.isEmpty?'':'<p class="table-caption">$caption</p>')+'<div class="table-scroll"><table>$body</table></div></div>';
    }
    if(block.kind=='figure' && data['jpeg'] is String){
      final jpeg=data['jpeg'] as String;
      if(RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(jpeg)){
        final alt=escape((data['alt']??block.text).toString());
        return '<figure id="$id"><img alt="$alt" src="data:image/jpeg;base64,$jpeg"><figcaption>$t</figcaption></figure>';
      }
    }
    if(block.kind=='pre'){
      if(printingFurniture(block.text))return '';
      return '<div class="code-card"><div class="code-bar"><span>Código / dados técnicos</span><button type="button" data-copy="$id">Copiar</button></div><pre id="$id"><code>$t</code></pre></div>';
    }
    if(block.kind=='formula')return '<pre id="$id" class="formula">$t</pre>';
    if(block.kind=='exercise'||block.kind=='lab'||block.kind=='answer'||block.kind=='reference'){
      return '<aside id="$id" class="study-block">$t</aside>';
    }
    return blockHtml(block);
  }

  static String pageHtml(String source,{
    required double fontSize,
    required int chapter,
    required int screen,
    List<Map<String,dynamic>> highlights=const [],
    bool dark=false,
    List<Map<String,dynamic>> layout=const [],
  }) {
    final blocks=layout.isEmpty?parse(readingSource(source)):List.generate(layout.length,(i)=>HtmlBlock('b$i',(layout[i]['kind']??'p').toString(),(layout[i]['text']??'').toString()));
    final content=layout.isEmpty?blocks.map(blockHtml).join('\n'):List.generate(blocks.length,(i)=>richBlockHtml(blocks[i],layout[i])).join('\n');
    final marks=highlights.where((h)=>h['page']==screen && h['text'] is String)
      .map((h)=><String,dynamic>{
        'block':h['htmlBlock']??'',
        'start':h['htmlStart']??-1,
        'end':h['htmlEnd']??-1,
        'quote':h['text']??'',
      }).toList();
    final json=jsonEncode(marks).replaceAll('</','<\\/');
    final size=fontSize.clamp(12.0,36.0);
    return '''<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; img-src data:;">
<style>
body{margin:0;background:${dark?'#000000':'#ffffff'};color:${dark?'#ffffff':'#000000'};font-family:Georgia,'Noto Serif',serif;font-size:${size}px;line-height:1.58;-webkit-text-size-adjust:100%}
article{max-width:780px;margin:auto;padding:12px 16px 20px}
p{margin:0 0 .85em;text-align:justify;text-justify:inter-word;hyphens:auto;overflow-wrap:anywhere}
@media(max-width:480px){p{text-align:start}}
h1,h2,h3,h4{font-family:system-ui,Roboto,sans-serif;text-align:left;line-height:1.29;hyphens:none;break-after:avoid}
h1{font-size:1.48em;margin:.35em 0 .55em;color:inherit}
h2{font-size:1.22em;margin:.8em 0 .45em;color:inherit;border-bottom:1px solid #d2dcd4;padding-bottom:.35em}
h3{font-size:1.10em;margin:.7em 0 .4em;color:inherit}
h4{font-size:.9em;letter-spacing:normal;color:inherit;margin:.6em 0 .35em}
aside{display:block;margin:1.1em 0 1.35em;border-left:4px solid ${dark?'#aaaaaa':'#555555'};background:${dark?'#1c1c1c':'#f0f0f0'};padding:.85em 1em;border-radius:0 8px 8px 0;font-weight:600;line-height:1.55}
figcaption{display:block;font-size:.79em;line-height:1.55;font-style:italic;color:inherit;margin:.5em 0 1.2em}
small{display:block;margin:.25em 0 .6em;color:inherit;font-size:.70em;line-height:1.3;letter-spacing:normal;overflow-wrap:normal;word-break:normal}
strong{font-family:system-ui,Roboto,sans-serif}
figure{margin:1em 0}figure img{max-width:100%;height:auto;display:block;margin:auto;border:1px solid #aaa;border-radius:4px}.table-scroll{overflow-x:auto;margin:.65em 0 1.15em}table{border-collapse:collapse;min-width:100%;font-size:.85em}th{background:${dark?'#222222':'#eeeeee'}}td{min-width:92px}th,td{border:1px solid #888;padding:.5em;text-align:left;vertical-align:top}th{font-weight:700}.study-block{white-space:pre-wrap}.formula{font-family:serif;text-align:center}
pre{white-space:pre;overflow-x:auto;max-width:100%;padding:.8em;border:1px solid #888;border-radius:6px;font: .82em/1.5 monospace;color:inherit;hyphens:none}.code-card{margin:1em 0;border:1px solid #888;border-radius:8px;background:${dark?'#141414':'#f5f5f5'}}.code-card pre{margin:0;border:0;border-top:1px solid #888;border-radius:0;user-select:text}.code-bar{display:flex;justify-content:space-between;align-items:center;padding:.45em .7em;font:600 .75em system-ui}.code-bar button{font:inherit;border:1px solid #888;border-radius:4px;padding:.4em .7em;background:transparent;color:inherit}
mark.saved{background:#ffe08c;color:#000000;border-radius:2px}
::selection{background:#8cd4b0;color:#15362a}

/* Narrow display and maximum font size: horizontal scrolling is local to code/tables. */
*,*::before,*::after{box-sizing:border-box}article{min-width:0;overflow-wrap:anywhere}h1,h2,h3,h4,small,figcaption,aside{overflow-wrap:anywhere;word-break:normal}figure img{max-width:100%;box-sizing:border-box}.table-scroll,pre,.code-card{max-width:100%;min-width:0}.code-bar{flex-wrap:wrap;gap:.4em}.code-bar span{min-width:0;overflow-wrap:anywhere}
</style></head><body><article data-chapter="$chapter" data-screen="$screen">
$content
</article><script>
(function(){
"use strict";
const article=document.querySelector('article');
const marks=$json;
article.addEventListener('click',function(event){
 const btn=event.target.closest('[data-copy]');if(!btn)return;
 const el=document.getElementById(btn.dataset.copy);
 if(el&&window.BookBridge)window.BookBridge.postMessage(JSON.stringify({type:'copyCode',block:el.id}));
});
function locate(block,offset){
 let w=document.createTreeWalker(block,NodeFilter.SHOW_TEXT),node,left=offset;
 while((node=w.nextNode())){let n=node.textContent.length;
   if(left<=n)return {node:node,offset:left};left-=n;}
 return null;
}
function addMark(m){
 let el=document.getElementById(m.block),a=m.start,b=m.end;
 if(!el||a<0||b<=a){
   el=Array.from(article.children).find(x=>x.textContent.includes(m.quote));
   if(!el)return;a=el.textContent.indexOf(m.quote);b=a+m.quote.length;
 }
 if(el.textContent.slice(a,b).trim()!==m.quote.trim()) {
   a=el.textContent.indexOf(m.quote);if(a<0)return;b=a+m.quote.length;
 }
 const from=locate(el,a),to=locate(el,b);
 if(!from||!to)return;
 const range=document.createRange();
 range.setStart(from.node,from.offset);range.setEnd(to.node,to.offset);
 const fragment=range.extractContents();
 const mark=document.createElement('mark');mark.className='saved';
 mark.appendChild(fragment);range.insertNode(mark);
}
marks.sort((a,b)=>a.block===b.block ? b.start-a.start :
  a.block.localeCompare(b.block));
for(const mark of marks){try{addMark(mark);}catch(e){}}
let last='';
document.addEventListener('selectionchange',function(){
 const selection=window.getSelection();
 if(!selection||selection.isCollapsed||!selection.rangeCount)return;
 const quote=selection.toString().trim();
 if(quote.length<2||quote.length>2200)return;
 const range=selection.getRangeAt(0),a=range.commonAncestorContainer;
 const element=a.nodeType===1?a:a.parentElement;
 const el=element&&element.closest('article > *');
 let id='',start=-1,end=-1;
 if(el){
   id=el.id;
   const before=document.createRange();before.selectNodeContents(el);
   before.setEnd(range.startContainer,range.startOffset);
   start=before.toString().length;end=start+range.toString().length;
 }
 const message=JSON.stringify({type:'selection',quote:quote,
   block:id,start:start,end:end});
 if(message===last)return;last=message;
 if(window.BookBridge)window.BookBridge.postMessage(message);
});
})();
</script></body></html>''';
  }
}
class HtmlBlock {
  const HtmlBlock(this.id,this.kind,this.text);
  final String id;
  final String kind;
  final String text;
}
