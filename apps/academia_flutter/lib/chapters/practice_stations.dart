import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'lesson_depth_model.dart';

/// Distinct hands-on instruments for different forensic skills. All datasets
/// are explicitly synthetic and none of these labs assert judicial findings.
class PracticeStation extends StatefulWidget {
  const PracticeStation({super.key,required this.chapter,required this.plan,
    required this.onPerformed});
  final int chapter;
  final LessonDeepPlan plan;
  final VoidCallback onPerformed;
  @override
  State<PracticeStation> createState()=>_PracticeStationState();
}

class _PracticeStationState extends State<PracticeStation> {
  final _source=TextEditingController(text:'EXEMPLO-001: evento às 14:32');
  final _operator=TextEditingController();
  final _item=TextEditingController();
  final _procedure=TextEditingController();
  final _alternate=TextEditingController();
  int? _classification;
  int _copies=2;
  int _sources=3;
  bool _includeOutlier=true;
  int _trials=30;
  double _chance=0.25;
  double _prior=0.01;
  double _sensitivity=0.95;
  double _specificity=0.99;
  String _result='';
  @override
  void dispose(){
    for(final c in [_source,_operator,_item,_procedure,_alternate]){
      c.dispose();
    }
    super.dispose();
  }

  void _performed(String text) {
    if(!mounted)return;
    setState(()=>_result=text);
    widget.onPerformed();
  }

  @override
  Widget build(BuildContext context){
    if(widget.chapter==1) return _hash();
    if([2,9,10,23].contains(widget.chapter)) return _custodyForm();
    if([3,14,15].contains(widget.chapter)) return _bytesInspector();
    if([4,7].contains(widget.chapter)) return _clockExplanation();
    if([5,6,8,11,16].contains(widget.chapter)) return _evidenceReviewer();
    if([12,13,18,19].contains(widget.chapter)) return _codeTracer();
    if([20,21,22].contains(widget.chapter)) return _joinExplorer();
    if(widget.chapter==17) return _ratioLab();
    if(widget.chapter==24) return _descriptiveStats();
    if(widget.chapter==25) return _bayes();
    if(widget.chapter==26) return _distribution();
    return const Text('Este experimento ainda não está disponível para a unidade.');
  }

  Widget _intro(String heading,String narrative,Widget child,
      {IconData icon=Icons.science_outlined}) {
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[
        Icon(icon,color:const Color(0xFF245B43),size:28),
        const SizedBox(width:10),
        Expanded(child:Text(heading,
          style:Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight:FontWeight.w800))),
      ]),
      const SizedBox(height:11),
      Text(narrative,style:const TextStyle(fontSize:15.4,height:1.52)),
      const SizedBox(height:17),
      child,
      if(_result.isNotEmpty)Padding(
        padding:const EdgeInsets.only(top:15),
        child:Container(
          width:double.infinity,padding:const EdgeInsets.all(15),
          decoration:BoxDecoration(
            color:const Color(0xFFEAF2EB),
            border:Border.all(color:const Color(0xFF9FC0AD)),
            borderRadius:BorderRadius.circular(9)),
          child:SelectableText(_result,
            style:const TextStyle(fontSize:14,height:1.48)))),
    ]);
  }
  Widget _hash(){
    final digest=sha256.convert(utf8.encode(_source.text)).toString();
    const original='EXEMPLO-001: evento às 14:32';
    final originalDigest=sha256.convert(utf8.encode(original)).toString();
    return _intro('Oficina de integridade SHA-256',
      'Altere o conteúdo de um vestígio fictício. O resumo é recalculado '
      'a partir dos bytes UTF-8 presentes, sem aprovação por mera abertura.',
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        TextField(controller:_source,maxLines:3,
          decoration:const InputDecoration(border:OutlineInputBorder(),
            labelText:'Bytes representados em texto UTF-8'),
          onChanged:(_)=>setState((){})),
        const SizedBox(height:12),
        SelectableText('SHA-256: $digest',style:const TextStyle(
          fontFamily:'monospace',fontSize:12)),
        const SizedBox(height:8),
        Text(digest==originalDigest?
          'Os bytes conferem com o texto original.':
          'Os hashes diferentes indicam que os bytes mudaram.',
          style:const TextStyle(fontSize:14,fontWeight:FontWeight.w700)),
        const SizedBox(height:15),
        FilledButton(onPressed:()=>_performed(
          'Resumo calculado para ${utf8.encode(_source.text).length} bytes: '
          '$digest. Isso demonstra somente o conteúdo examinado, '
          'não a autoria nem a origem do arquivo.'),
          child:const Text('Registrar resultado calculado')),
      ]),icon:Icons.fingerprint);
  }
  Widget _custodyForm(){
    final chapter=widget.chapter;
    return _intro(chapter==9?'Diário técnico reproduzível':
        chapter==23?'Manifesto de projeto':chapter==10?
        'Caderno do caso integrador':'Recebimento de vestígio',
      'Produza um registro didático que contenha os dados indispensáveis. '
      'O relatório só é calculado depois de preencher e verificar campos.',
      Column(children:[
        TextField(controller:_item,
          decoration:const InputDecoration(labelText:'Identificador e origem do item',
            border:OutlineInputBorder())),
        const SizedBox(height:10),
        TextField(controller:_operator,
          decoration:const InputDecoration(labelText:'Responsável pelo registro',
            border:OutlineInputBorder())),
        const SizedBox(height:10),
        TextField(controller:_procedure,maxLines:3,
          decoration:const InputDecoration(
            labelText:'Método, ferramenta, versão e limitação conhecida',
            border:OutlineInputBorder())),
        const SizedBox(height:12),
        FilledButton.icon(
          icon:const Icon(Icons.fact_check),
          onPressed:(){
            if(_item.text.trim().length<3 ||
                _operator.text.trim().length<3 ||
                _procedure.text.trim().length<15) {
              setState(()=>_result='Registro incompleto. '
                'Identifique item, operador e procedimento com limitações.');
              return;
            }
            _performed('REGISTRO DIDÁTICO (não constitui cadeia de custódia real)\n'
              'Item: ${_item.text}\nOperador: ${_operator.text}\n'
              'Método declarado: ${_procedure.text}\n'
              'Data UTC: ${DateTime.now().toUtc().toIso8601String()}\n'
              'PENDENTE: conferência de proveniência e assinaturas.');
          },
          label:const Text('Validar e produzir registro')),
      ]),icon:Icons.assignment_outlined);
  }
  Widget _bytesInspector(){
    final data=utf8.encode(_source.text);
    final digest=sha256.convert(data).toString();
    final zeros=_source.text.startsWith('00');
    return _intro('Inspetor de bytes e identificadores',
      'Edite uma amostra. Observe a quantidade de caracteres, de bytes e '
      'o resumo do conteúdo. Em dados reais, primeiro preserve a codificação original.',
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        TextField(controller:_source,maxLines:3,
          onChanged:(_)=>setState((){}),
          decoration:const InputDecoration(
            labelText:'Texto de treino / ID / conteúdo',
            border:OutlineInputBorder())),
        const SizedBox(height:14),
        Wrap(spacing:12,runSpacing:8,children:[
          Chip(label:Text('${_source.text.runes.length} caracteres Unicode')),
          Chip(label:Text('${data.length} bytes UTF-8')),
          Chip(label:Text(zeros?'ID começa com zero':'Sem zero inicial')),
        ]),
        const SizedBox(height:8),
        SelectableText('SHA-256: $digest',style:const TextStyle(
          fontSize:11,fontFamily:'monospace')),
        const SizedBox(height:14),
        FilledButton(
          onPressed:()=>_performed('Foram inspecionados ${data.length} bytes. '
            'O texto visível não preserva automaticamente a origem do arquivo. '
            'Identificadores devem ser preservados como texto quando aplicável.'),
          child:const Text('Interpretar resultado da inspeção')),
      ]),icon:Icons.code);
  }
  Widget _clockExplanation(){
    return _intro('Laboratório de cronologia',
      'Uma câmera registra 14:32:18. O relógio pode estar adiantado, '
      'atrasado ou não aferido. Ajuste a incerteza na simulação temporal '
      'da unidade e explique quais inferências não são autorizadas.',
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('No cálculo temporal, a direção da correção depende '
          'do sinal do desvio. Registros próximos não demonstram autoria.'),
        const SizedBox(height:12),
        FilledButton(
          onPressed:()=>_performed('Regra de exame: normalizar fuso, '
            'subtrair o adiantamento do relógio, representar intervalo '
            'de incerteza e comparar sem atribuir identidade.'),
          child:const Text('Conferir procedimento de correção')),
      ]),icon:Icons.schedule);
  }
  Widget _evidenceReviewer(){
    final c=widget.chapter;
    final options=switch(c){
      5=>['Pedido: provar culpa','Pergunta: comparar declarações com fontes',
          'Conclusão: mentira comprovada'],
      6=>['Três publicações dependem da mesma fonte',
          'Três fontes independentes confirmadas',
          'Todo resumo equivale a original'],
      8=>['Critérios registrados antes da análise',
          'Selecionar eventos favoráveis após ler o caso',
          'Omitir os registros incompatíveis'],
      11=>['Log registra atividade da conta',
          'Titular da conta estava presente',
          'Endereço IP identifica pessoa'],
      _=>['A operadora registrou endereço e porta',
          'O titular esteve fisicamente no local',
          'A conexão confirma o conteúdo exibido'],
    };
    final right=switch(c){5=>1,6=>0,8=>0,11=>0,_=>0};
    return _intro('Bancada de crítica das evidências',
      widget.plan.challenge,
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Selecione a afirmação tecnicamente defensável. '
          'Depois identifique uma hipótese alternativa.'),
        const SizedBox(height:12),
        for(var i=0;i<options.length;i++)
          RadioListTile<int>(
            title:Text(options[i]),value:i,groupValue:_classification,
            onChanged:(n)=>setState(()=>_classification=n)),
        TextField(controller:_alternate,minLines:2,maxLines:4,
          decoration:const InputDecoration(
            border:OutlineInputBorder(),
            labelText:'Que outra explicação pode produzir o mesmo registro?')),
        const SizedBox(height:12),
        FilledButton(
          onPressed:(){
            if(_classification==null ||
                _alternate.text.trim().length<15){
              setState(()=>_result='Selecione uma afirmação e '
                'escreva uma hipótese alternativa com pelo menos 15 caracteres.');
              return;
            }
            if(_classification!=right){
              setState(()=>_result='A alternativa escolhida extrapola '
                'o que a fonte demonstra. Reexamine origem e limitações.');
              return;
            }
            _performed('Interpretação defensável: ${options[right]}.\n'
              'Hipótese alternativa formulada: ${_alternate.text}\n'
              'A validação de uma pessoa ou evento exige fontes adicionais.');
          },
          child:const Text('Verificar interpretação e alternativa')),
      ]),icon:Icons.account_tree_outlined);
  }
  Widget _codeTracer(){
    final c=widget.chapter;
    final question=switch(c){
      12=>'Duas cópias têm bytes iguais. Qual informação Get-FileHash pode demonstrar?',
      13=>'Um arquivo apresenta permissões 755. O que isso descreve?',
      18=>'Uma lista tem três linhas e dois IDs únicos. Qual contagem usar?',
      _=>'Uma função recebe ID duplicado, mas o contrato os proíbe. O que deve acontecer?',
    };
    final options=switch(c){
      12=>['Autoria humana','Correspondência de resumos do conteúdo','Validade jurídica'],
      13=>['Quem executou o arquivo','Permissões clássicas de acesso','Quando houve a execução'],
      18=>['3 eventos e 2 IDs, conforme a pergunta','3 pessoas com certeza','2 eventos sem olhar origem'],
      _=>['Descartar duplicata sem registrar','Rejeitar entrada e documentar o erro','Manter resultado sem aviso'],
    };
    final right=switch(c){18=>0,_=>1};
    return _intro('Depuração: preveja o comportamento',
      'Aponte a interpretação correta do procedimento. '
      'Nenhum script é executado sobre arquivos do usuário nesta atividade.',
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(question,style:const TextStyle(
          fontWeight:FontWeight.bold,fontSize:16)),
        const SizedBox(height:10),
        for(var i=0;i<options.length;i++) RadioListTile<int>(
          title:Text(options[i]),value:i,groupValue:_classification,
          onChanged:(v)=>setState(()=>_classification=v)),
        FilledButton(
          onPressed:_classification==null?null:(){
            if(_classification!=right) {
              setState(()=>_result='A interpretação não corresponde à '
                'semântica do comando. Reveja as entradas e o que ele retorna.');
              return;
            }
            _performed('Interpretação correta: ${options[right]}. '
              'É preciso documentar entrada, versão e comando. '
              'O programa não faz inferências de autoria.');
          },child:const Text('Conferir execução mental')),
      ]),icon:Icons.terminal);
  }
  Widget _joinExplorer(){
    final joined=_copies*_sources;
    return _intro('Laboratório de cardinalidade de junção',
      'Uma chave fictícia aparece em quantidades diferentes em duas tabelas. '
      'Ajuste as repetições e veja quantos pares surgiriam num JOIN N:N.',
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Ocorrências do ID à esquerda: $_copies'),
        Slider(value:_copies.toDouble(),min:1,max:6,divisions:5,
          label:'$_copies',onChanged:(v)=>setState(()=>_copies=v.toInt())),
        Text('Ocorrências do ID à direita: $_sources'),
        Slider(value:_sources.toDouble(),min:1,max:6,divisions:5,
          label:'$_sources',onChanged:(v)=>setState(()=>_sources=v.toInt())),
        const SizedBox(height:12),
        Text('Linhas após JOIN: $joined',
          style:Theme.of(context).textTheme.headlineMedium?.
            copyWith(fontWeight:FontWeight.bold)),
        const SizedBox(height:6),
        Text('Cálculo: $_copies × $_sources = $joined combinações.'),
        const SizedBox(height:16),
        Container(
          padding:const EdgeInsets.all(12),
          color:const Color(0xFFF2F5F2),
          child:Text('Chaves repetidas podem multiplicar pares sem '
            'criar novos acontecimentos independentes. O domínio dos dados '
            'precisa justificar a cardinalidade.')),
        const SizedBox(height:14),
        FilledButton(
          onPressed:()=>_performed('Junção de treino: $_copies linhas × '
            '$_sources linhas para uma chave = $joined pares. '
            'Verifique duplicações e significado da relação antes '
            'de contar eventos.'),
          child:const Text('Registrar cálculo e interpretação')),
      ]),icon:Icons.table_chart_outlined);
  }
  Widget _ratioLab(){
    final total=_copies+_sources;
    final fraction=_copies/total;
    return _intro('Laboratório de proporções',
      'O denominador é o conjunto efetivamente analisado. '
      'Ajuste as categorias e explique por que a percentagem não pode '
      'ser automaticamente generalizada para registros ausentes.',
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Categoria A: $_copies registros'),
        Slider(value:_copies.toDouble(),min:1,max:6,divisions:5,
          onChanged:(v)=>setState(()=>_copies=v.toInt())),
        Text('Categoria B: $_sources registros'),
        Slider(value:_sources.toDouble(),min:1,max:6,divisions:5,
          onChanged:(v)=>setState(()=>_sources=v.toInt())),
        LinearProgressIndicator(value:fraction,minHeight:17),
        const SizedBox(height:10),
        Text('A: ${(100*fraction).toStringAsFixed(1)}% de $total registros'),
        const SizedBox(height:12),
        FilledButton(
          onPressed:()=>_performed('A amostra tem $total registros; '
            'categoria A ocupa ${(100*fraction).toStringAsFixed(1)}%. '
            'Não há base para inferir proporção do universo não observado.'),
          child:const Text('Interpretar denominador')),
      ]),icon:Icons.pie_chart_outline);
  }
  Widget _descriptiveStats(){
    final values=_includeOutlier?<double>[1,2,2,3,20]:<double>[1,2,2,3];
    final sum=values.reduce((a,b)=>a+b);
    final average=sum/values.length;
    final median=values.length.isOdd?values[values.length~/2]:
      (values[values.length~/2-1]+values[values.length~/2])/2;
    return _intro('Média x mediana: investigue o valor extremo',
      'Os valores são durações sintéticas em segundos. '
      'Mantenha ou remova o extremo e observe o que cada medida faz. '
      'Em dados reais, excluir um valor exige justificativa.',
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        SwitchListTile(
          title:const Text('Incluir tempo extremo de 20 segundos'),
          value:_includeOutlier,
          onChanged:(v)=>setState(()=>_includeOutlier=v)),
        const SizedBox(height:12),
        Wrap(spacing:8,runSpacing:8,children:[
          for(final x in values) Chip(label:Text('${x.toInt()} s')),
        ]),
        const SizedBox(height:12),
        Row(children:[
          Expanded(child:_statTile('Média','${average.toStringAsFixed(2)} s')),
          const SizedBox(width:8),
          Expanded(child:_statTile('Mediana','${median.toStringAsFixed(2)} s')),
        ]),
        const SizedBox(height:14),
        FilledButton(
          onPressed:()=>_performed('Conjunto sintético: n=${values.length}, '
            'média=${average.toStringAsFixed(2)}s, '
            'mediana=${median.toStringAsFixed(2)}s. '
            'Exclusão do extremo: ${_includeOutlier?'não':'sim'}; '
            'a seleção precisa ser justificada em análises reais.'),
          child:const Text('Registrar cálculo descritivo')),
      ]),icon:Icons.bar_chart);
  }
  Widget _statTile(String title,String value) {
    return Container(padding:const EdgeInsets.all(12),
      decoration:BoxDecoration(
        border:Border.all(color:const Color(0xFF9DBDA6)),
        borderRadius:BorderRadius.circular(10)),
      child:Column(children:[
        Text(title,style:const TextStyle(fontSize:12)),
        Text(value,style:const TextStyle(fontSize:19,
          fontWeight:FontWeight.bold)),
      ]));
  }
  Widget _bayes(){
    final tp=_prior*_sensitivity;
    final fp=(1-_prior)*(1-_specificity);
    final post=(tp+fp)==0?0.0:tp/(tp+fp);
    String percent(double v)=>'${(v*100).toStringAsFixed(1)}%';
    return _intro('Valor preditivo sob diferentes taxas de base',
      'Edite os três pressupostos. Um resultado positivo não significa '
      'a mesma coisa que a sensibilidade do teste.',
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Prevalência hipotética: ${percent(_prior)}'),
        Slider(value:_prior,min:0.001,max:0.20,
          onChanged:(v)=>setState(()=>_prior=v)),
        Text('Sensibilidade: ${percent(_sensitivity)}'),
        Slider(value:_sensitivity,min:0.70,max:1,
          onChanged:(v)=>setState(()=>_sensitivity=v)),
        Text('Especificidade: ${percent(_specificity)}'),
        Slider(value:_specificity,min:0.90,max:1,
          onChanged:(v)=>setState(()=>_specificity=v)),
        const Divider(),
        Text('P(H|+): ${percent(post)}',
          style:Theme.of(context).textTheme.titleLarge),
        const SizedBox(height:10),
        LinearProgressIndicator(value:post,minHeight:14),
        const SizedBox(height:14),
        FilledButton(
          onPressed:()=>_performed('Modelo hipotético: taxa de base '
            '${percent(_prior)}, sensibilidade ${percent(_sensitivity)}, '
            'especificidade ${percent(_specificity)}; '
            'P(H|+) = ${percent(post)}. Não constitui probabilidade de culpa.'),
          child:const Text('Registrar probabilidade condicional')),
      ]),icon:Icons.functions);
  }
  Widget _distribution(){
    final expected=_trials*_chance;
    final variance=_trials*_chance*(1-_chance);
    // Deliberately theoretical moments; no claim that events were observed.
    return _intro('Distribuição binomial: experimente parâmetros',
      'O modelo supõe tentativas com probabilidade constante e '
      'independência. Os números apresentados são valores esperados '
      'do modelo, não observações criminais.',
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Tentativas n: $_trials'),
        Slider(value:_trials.toDouble(),min:5,max:100,divisions:19,
          onChanged:(v)=>setState(()=>_trials=v.toInt())),
        Text('Probabilidade hipotética p: ${(_chance*100).toStringAsFixed(1)}%'),
        Slider(value:_chance,min:0.05,max:0.95,
          onChanged:(v)=>setState(()=>_chance=v)),
        const SizedBox(height:12),
        Row(children:[
          Expanded(child:_statTile('E[X]=np',expected.toStringAsFixed(2))),
          const SizedBox(width:8),
          Expanded(child:_statTile('Var[X]',variance.toStringAsFixed(2))),
        ]),
        const SizedBox(height:12),
        Text('Desvio-padrão: ${math.sqrt(variance).toStringAsFixed(2)}'),
        const SizedBox(height:16),
        FilledButton(
          onPressed:()=>_performed('Modelo binomial hipotético '
            'n=$_trials e p=${_chance.toStringAsFixed(3)}. '
            'Esperança ${expected.toStringAsFixed(2)}, '
            'variância ${variance.toStringAsFixed(2)}. '
            'A escolha do modelo precisa ser validada contra os dados.'),
          child:const Text('Interpretar parâmetros do modelo')),
      ]),icon:Icons.stacked_line_chart);
  }
}
