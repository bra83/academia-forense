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
    if(section.hasMatch(line))return 'h2';
    if(caption.hasMatch(line))return 'figcaption';
    if(heading.hasMatch(line))return 'h3';
    if(callout.hasMatch(line))return 'aside';
    if(footer.hasMatch(line))return 'small';
    if(['Dos dados','às evidências','Estatística descritiva',
      'Computador, armazenamento e','ambiente de trabalho'].contains(line))return 'h1';
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

  static String blockHtml(HtmlBlock block) {
    final raw=block.text;
    var formatted=escape(raw);
    if(block.kind=='p'){
      final match=lead.firstMatch(raw);
      if(match!=null) {
        formatted='<strong>${escape(raw.substring(0,match.end))}</strong>'
          +escape(raw.substring(match.end));
      }
    }
    final tag=block.kind=='h1'?'h1':block.kind=='h2'?'h2':
      block.kind=='h3'?'h3':block.kind=='h4'?'h4':
      block.kind=='figcaption'?'figcaption':block.kind=='aside'?'aside':
      block.kind=='small'?'small':'p';
    return '<$tag id="${block.id}" data-pdf="true">$formatted</$tag>';
  }

  static String pageHtml(String source,{
    required double fontSize,
    required int chapter,
    required int screen,
    List<Map<String,dynamic>> highlights=const [],
  }) {
    final content=parse(source).map(blockHtml).join('\n');
    final marks=highlights.where((h)=>h['page']==screen && h['text'] is String)
      .map((h)=><String,dynamic>{
        'block':h['htmlBlock']??'',
        'start':h['htmlStart']??-1,
        'end':h['htmlEnd']??-1,
        'quote':h['text']??'',
      }).toList();
    final json=jsonEncode(marks).replaceAll('</','<\\/');
    final size=fontSize.clamp(14.0,26.0);
    return '''<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; img-src data:;">
<style>
body{margin:0;background:#fffefb;color:#243129;font-family:Georgia,'Noto Serif',serif;font-size:${size}px;line-height:1.74;-webkit-text-size-adjust:100%}
article{max-width:780px;margin:auto;padding:20px 19px 64px}
p{margin:0 0 1.22em;text-align:justify;text-justify:inter-word;hyphens:auto;overflow-wrap:break-word}
h1,h2,h3,h4{font-family:system-ui,Roboto,sans-serif;text-align:left;line-height:1.29;hyphens:none;break-after:avoid}
h1{font-size:1.85em;margin:0.5em 0 0.8em;color:#194a37}
h2{font-size:1.33em;margin:1.4em 0 .75em;color:#18503a;border-bottom:1px solid #d2dcd4;padding-bottom:.35em}
h3{font-size:1.16em;margin:1.3em 0 .75em;color:#204a38}
h4{font-size:.82em;letter-spacing:.09em;color:#47755b;margin:1.2em 0}
aside{display:block;margin:1.1em 0 1.35em;border-left:4px solid #2f8057;background:#eef5ee;padding:.85em 1em;border-radius:0 8px 8px 0;font-weight:600;line-height:1.55}
figcaption{display:block;font-size:.79em;line-height:1.55;font-style:italic;color:#54645b;margin:.5em 0 1.2em}
small{display:block;margin:.8em 0;color:#8b948e;font-size:.67em}
strong{font-family:system-ui,Roboto,sans-serif}
mark.saved{background:#ffe08c;color:inherit;border-radius:2px}
::selection{background:#8cd4b0;color:#15362a}
</style></head><body><article data-chapter="$chapter" data-screen="$screen">
$content
</article><script>
(function(){
"use strict";
const article=document.querySelector('article');
const marks=$json;
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
