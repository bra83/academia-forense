import 'package:flutter/material.dart';
import 'lesson_depth_model.dart';
import 'lesson_depth_vol1.dart';
import 'lesson_depth_vol2.dart';
import 'lesson_depth_vol3.dart';

final Map<int,LessonDeepPlan> deepLessons={
  ...deepLessonsVolumeOne,
  ...deepLessonsVolumeTwo,
  ...deepLessonsVolumeThree,
};

LessonDeepPlan extendedLessonForChapter(int number) {
  final data=deepLessons[number];
  if(data==null) throw ArgumentError.value(number,'chapter',
    'Não existe material revisado para o capítulo solicitado');
  return data;
}

/// Explanations have multiple substantive sections and worked examples.
/// Visually structured editorial layouts, rather than repeating identical cards.
class DeepLessonArticle extends StatefulWidget {
  const DeepLessonArticle({super.key,required this.plan,required this.chapterNumber});
  final LessonDeepPlan plan;
  final int chapterNumber;
  @override
  State<DeepLessonArticle> createState()=>_DeepLessonArticleState();
}
class _DeepLessonArticleState extends State<DeepLessonArticle> {
  final Set<int> _openExplanations={};
  static const Color green=Color(0xFF245941);
  static const Color ink=Color(0xFF172C25);
  static const Color paper=Color(0xFFF1F5F1);
  @override
  Widget build(BuildContext context){
    final content=widget.plan;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Container(
        width:double.infinity,padding:const EdgeInsets.all(20),
        decoration:BoxDecoration(
          color:ink,borderRadius:BorderRadius.circular(18)),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('QUESTÃO QUE VAMOS RESOLVER',
            style:TextStyle(letterSpacing:1.1,fontSize:11,
              color:Color(0xFFA3D5BE),fontWeight:FontWeight.w700)),
          const SizedBox(height:12),
          Text(content.challenge,
            style:const TextStyle(fontSize:19,height:1.32,
              fontWeight:FontWeight.w600,color:Colors.white)),
        ])),
      const SizedBox(height:22),
      for(var i=0;i<content.sections.length;i++)
        _section(context,content.sections[i],i),
      const SizedBox(height:8),
      Container(width:double.infinity,padding:const EdgeInsets.all(18),
        decoration:BoxDecoration(
          color:paper,borderRadius:BorderRadius.circular(14)),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('PARA LEVAR AO LABORATÓRIO',
            style:TextStyle(fontWeight:FontWeight.bold,
              color:green,fontSize:11,letterSpacing:1)),
          const SizedBox(height:8),
          Text(content.nextInvestigation,
            style:const TextStyle(height:1.52,fontSize:15)),
          const SizedBox(height:8),
          const Text('Os exemplos didáticos são sintéticos. Confira as '
            'explicações com o capítulo original e suas fontes.',
            style:TextStyle(fontSize:12,height:1.4)),
        ])),
    ]);
  }
  Widget _section(BuildContext context,LessonDeepSection section,int index) {
    final type=index%3;
    final isOpen=_openExplanations.contains(index);
    return Padding(
      padding:const EdgeInsets.only(bottom:26),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Container(width:38,height:38,
            alignment:Alignment.center,
            decoration:BoxDecoration(
              color:type==1?const Color(0xFFEAF0FF):const Color(0xFFE0F0E8),
              borderRadius:BorderRadius.circular(11)),
            child:Text('0${index+1}',
              style:TextStyle(fontWeight:FontWeight.bold,
                color:type==1?const Color(0xFF304B79):green))),
          const SizedBox(width:12),
          Expanded(child:Padding(
            padding:const EdgeInsets.only(top:3),
            child:Text(section.title,
              style:Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight:FontWeight.w800,fontSize:20,height:1.25)))),
        ]),
        const SizedBox(height:14),
        Text(section.explanation,
          style:const TextStyle(fontSize:16.4,height:1.60,color:ink)),
        const SizedBox(height:14),
        if(type==0) _fieldNote('EXEMPLO DE CAMPO',section.demonstration)
        else if(type==1) _workedPanel(section.demonstration)
        else _investigationQuote(section.demonstration),
        const SizedBox(height:12),
        InkWell(
          borderRadius:BorderRadius.circular(8),
          onTap:()=>setState((){
            if(isOpen) _openExplanations.remove(index);
            else _openExplanations.add(index);
          }),
          child:Padding(
            padding:const EdgeInsets.symmetric(vertical:10),
            child:Row(children:[
              Icon(isOpen?Icons.keyboard_arrow_up:Icons.help_outline,
                size:21,color:green),
              const SizedBox(width:7),
              Expanded(child:Text(isOpen?'Recolher pergunta de revisão':
                'Questão para você responder antes de avançar',
                style:const TextStyle(color:green,fontWeight:FontWeight.w700))),
            ])),
        ),
        if(isOpen) Container(
          width:double.infinity,
          padding:const EdgeInsets.all(14),
          decoration:BoxDecoration(
            border:Border(left:BorderSide(width:3,color:green)),
            color:const Color(0xFFF5F8F5)),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(section.practicalQuestion,style:const TextStyle(
              fontSize:15.5,height:1.42)),
            const SizedBox(height:10),
            const Text('Formule sua resposta antes de seguir. '
              'A questão é de reflexão, sem aprovação automática.',
              style:TextStyle(fontSize:12)),
          ])),
        const SizedBox(height:12),
        const Divider(height:18),
      ]),
    );
  }
  Widget _fieldNote(String label,String text){
    return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Container(width:4,height:95,decoration:BoxDecoration(
        color:green,borderRadius:BorderRadius.circular(2))),
      const SizedBox(width:12),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(label,style:const TextStyle(fontSize:11,
          letterSpacing:1,color:green,fontWeight:FontWeight.bold)),
        const SizedBox(height:7),
        Text(text,style:const TextStyle(fontSize:15,height:1.5)),
      ])),
    ]);
  }
  Widget _workedPanel(String text){
    return Container(
      width:double.infinity,padding:const EdgeInsets.all(16),
      decoration:BoxDecoration(
        color:const Color(0xFF142B31),
        borderRadius:BorderRadius.circular(12)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Row(children:[
          Icon(Icons.science_outlined,color:Color(0xFFA6DBC4),size:17),
          SizedBox(width:8),
          Text('EXEMPLO RESOLVIDO',style:TextStyle(
            color:Color(0xFFA6DBC4),fontWeight:FontWeight.w700,
            letterSpacing:0.8,fontSize:11)),
        ]),
        const SizedBox(height:10),
        Text(text,style:const TextStyle(color:Colors.white,fontSize:15,
          height:1.5)),
      ]),
    );
  }
  Widget _investigationQuote(String text){
    return Padding(
      padding:const EdgeInsets.symmetric(horizontal:6),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('APLICAÇÃO À INVESTIGAÇÃO',style:TextStyle(
          letterSpacing:1,color:Color(0xFF5C6470),
          fontSize:11,fontWeight:FontWeight.w800)),
        const SizedBox(height:7),
        Text(text,style:const TextStyle(fontSize:15.2,
          fontStyle:FontStyle.italic,height:1.55)),
      ]),
    );
  }
}

/// Seven diagram families, selected by the discipline rather than the
/// chapter number alone. No repeated 5 identical "card" illustrations.
class TopicDiagram extends StatefulWidget {
  const TopicDiagram({super.key,required this.plan,required this.chapter});
  final LessonDeepPlan plan;
  final int chapter;
  @override
  State<TopicDiagram> createState()=>_TopicDiagramState();
}
class _TopicDiagramState extends State<TopicDiagram>{
  static const dark=Color(0xFF173C2E);
  int _focus=0;
  bool _showLimit=false;
  @override
  Widget build(BuildContext context){
    final plan=widget.plan;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(switch(plan.kind) {
        LessonSceneKind.process => 'Mapa de um procedimento auditável',
        LessonSceneKind.comparison => 'Camadas e diferenças que importam',
        LessonSceneKind.timeline => 'Régua de tempo e incerteza',
        LessonSceneKind.evidence => 'Quadro de hipóteses e fontes',
        LessonSceneKind.code => 'Bancada de código comentado',
        LessonSceneKind.data => 'Anatomia de uma tabela',
        LessonSceneKind.statistics => 'Números, distribuições e limites',
      },style:Theme.of(context).textTheme.titleLarge?.
        copyWith(fontWeight:FontWeight.w800)),
      const SizedBox(height:12),
      switch(plan.kind){
        LessonSceneKind.process => _process(plan),
        LessonSceneKind.comparison => _contrast(plan),
        LessonSceneKind.timeline => _timeline(plan),
        LessonSceneKind.evidence => _evidence(plan),
        LessonSceneKind.code => _code(plan),
        LessonSceneKind.data => _dataset(plan),
        LessonSceneKind.statistics => _statistical(plan),
      },
      const SizedBox(height:18),
      Text('Experimente explorar cada etapa. A visualização é uma '
        'explicação didática, não um achado de um caso real.',
        style:Theme.of(context).textTheme.bodySmall),
    ]);
  }
  Widget _process(LessonDeepPlan plan){
    return Column(children:[
      for(var i=0;i<plan.visualLabels.length;i++)
        InkWell(
          onTap:()=>setState(()=>_focus=i),
          child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Column(children:[
              CircleAvatar(radius:18,
                backgroundColor:_focus==i?dark:const Color(0xFFCADDD3),
                child:Text('${i+1}',style:TextStyle(
                  fontWeight:FontWeight.bold,
                  color:_focus==i?Colors.white:dark))),
              if(i+1<plan.visualLabels.length)
                Container(width:2,height:39,color:const Color(0xFFC1D5CB)),
            ]),
            const SizedBox(width:13),
            Expanded(child:Padding(
              padding:const EdgeInsets.only(top:4,bottom:14),
              child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(plan.visualLabels[i],style:TextStyle(
                  fontWeight:_focus==i?FontWeight.w800:FontWeight.w600,
                  fontSize:16)),
                if(_focus==i)Padding(
                  padding:const EdgeInsets.only(top:7),
                  child:Text(plan.visualDetails[i],style:const TextStyle(
                    fontSize:14,height:1.4,color:dark))),
              ]))),
          ])),
    ]);
  }
  Widget _contrast(LessonDeepPlan plan){
    return Column(children:[
      const Row(children:[
        Expanded(flex:2,child:Text('ELEMENTO',style:TextStyle(
          fontSize:11,fontWeight:FontWeight.bold,letterSpacing:1))),
        Expanded(flex:3,child:Text('O QUE DESCREVE',style:TextStyle(
          fontSize:11,fontWeight:FontWeight.bold,letterSpacing:1))),
      ]),
      const SizedBox(height:8),
      for(var i=0;i<plan.visualLabels.length;i++) Container(
        decoration:BoxDecoration(
          color:i.isEven?const Color(0xFFEAF1EB):Colors.white,
          borderRadius:BorderRadius.circular(6)),
        padding:const EdgeInsets.symmetric(horizontal:12,vertical:14),
        child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Expanded(flex:2,child:Text(plan.visualLabels[i],
            style:const TextStyle(fontSize:14,fontWeight:FontWeight.w800))),
          const SizedBox(width:8),
          Expanded(flex:3,child:Text(plan.visualDetails[i],
            style:const TextStyle(fontSize:14,height:1.4))),
        ])),
    ]);
  }
  Widget _timeline(LessonDeepPlan plan){
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Toque em cada marco para examinar o ajuste.',
        style:TextStyle(fontSize:14)),
      const SizedBox(height:12),
      SingleChildScrollView(scrollDirection:Axis.horizontal,
        child:Row(children:[
          for(var i=0;i<plan.visualLabels.length;i++) ...[
            GestureDetector(
              onTap:()=>setState(()=>_focus=i),
              child:Container(
                width:132,padding:const EdgeInsets.all(11),
                decoration:BoxDecoration(
                  borderRadius:BorderRadius.circular(9),
                  border:Border.all(color:_focus==i?dark:
                    const Color(0xFFCBD6D0),width:_focus==i?2:1),
                  color:_focus==i?const Color(0xFFE0F3E8):Colors.white),
                child:Column(children:[
                  Icon(i==0?Icons.access_time:Icons.watch_later_outlined,
                    color:dark),
                  const SizedBox(height:8),
                  Text(plan.visualLabels[i],textAlign:TextAlign.center,
                    style:const TextStyle(fontSize:12,fontWeight:FontWeight.bold)),
                ]))),
            if(i<plan.visualLabels.length-1)
              const Icon(Icons.arrow_forward,size:17,color:dark),
          ],
        ])),
      const SizedBox(height:14),
      Text(plan.visualDetails[_focus],style:const TextStyle(
        fontSize:16,fontWeight:FontWeight.w600)),
      const SizedBox(height:8),
      const Text('Não confunda proximidade no gráfico com identidade ou causalidade.'),
    ]);
  }
  Widget _evidence(LessonDeepPlan plan){
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Wrap(spacing:10,runSpacing:10,children:[
        for(var i=0;i<plan.visualLabels.length;i++)
          ActionChip(
            avatar:CircleAvatar(radius:14,backgroundColor:dark,
              child:Text('${i+1}',style:const TextStyle(
                fontSize:10,color:Colors.white))),
            label:Text(plan.visualLabels[i]),
            backgroundColor:_focus==i?const Color(0xFFCEE9D8):
              const Color(0xFFF4F6F4),
            onPressed:()=>setState(()=>_focus=i)),
      ]),
      const SizedBox(height:15),
      Container(width:double.infinity,
        padding:const EdgeInsets.all(18),
        decoration:BoxDecoration(
          color:const Color(0xFF173B35),
          borderRadius:BorderRadius.circular(13)),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(plan.visualLabels[_focus],
            style:const TextStyle(color:Colors.white,
              fontSize:18,fontWeight:FontWeight.bold)),
          const SizedBox(height:10),
          Text(plan.visualDetails[_focus],
            style:const TextStyle(color:Color(0xFFE4F4EA),
              fontSize:15,height:1.5)),
        ])),
      const SizedBox(height:12),
      SwitchListTile(
        value:_showLimit,
        contentPadding:EdgeInsets.zero,
        title:const Text('Mostrar alerta de inferência'),
        onChanged:(v)=>setState(()=>_showLimit=v)),
      if(_showLimit) const Text('Conexões no quadro organizam hipóteses. '
        'Elas não demonstram, sem fontes independentes, que uma pessoa '
        'praticou uma ação ou que um evento causou outro.',
        style:TextStyle(color:Color(0xFF795B15))),
    ]);
  }
  Widget _code(LessonDeepPlan plan){
    final code=switch(widget.chapter){
      12=>r'$PSVersionTable.PSVersion.ToString()'+'\n'+
        r'Get-ChildItem -LiteralPath $HOME'+'\n'+
        r'Get-FileHash -Algorithm SHA256 -LiteralPath ".\\treino.txt"',
      13=>'pwd\nls -la\nsha256sum treino.txt',
      18=>'linhas = ["A01", "A02", "A02"]\n'+
        'print(len(linhas))      # 3 registros\n'+
        'print(len(set(linhas))) # 2 IDs únicos',
      19=>'def validar_ids(ids):\n'+
        '    if len(ids) != len(set(ids)):\n'+
        '        raise ValueError("ID repetido")\n'+
        '    return len(ids)',
      _=>'# Procedimento de treinamento\n# Verifique entradas e saídas',
    };
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Container(width:double.infinity,
        padding:const EdgeInsets.all(16),
        decoration:BoxDecoration(color:const Color(0xFF17232B),
          borderRadius:BorderRadius.circular(12)),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Row(children:[
            Icon(Icons.terminal,color:Color(0xFF94D7B5),size:18),
            SizedBox(width:7),
            Text('EXEMPLO PARA ENTENDER',style:TextStyle(
              color:Color(0xFF94D7B5),fontSize:11,
              letterSpacing:0.8,fontWeight:FontWeight.bold)),
          ]),
          const SizedBox(height:13),
          SelectableText(code,style:const TextStyle(
            color:Colors.white,fontFamily:'monospace',
            fontSize:12.6,height:1.55)),
        ])),
      const SizedBox(height:13),
      Text('O código é ilustrativo: não é executado automaticamente '
        'nem usado sobre dados de terceiros.',
        style:const TextStyle(fontSize:13)),
      const SizedBox(height:10),
      for(var i=0;i<plan.visualLabels.length;i++)
        ListTile(
          dense:true,
          leading:Text('${i+1}.',style:const TextStyle(
            fontWeight:FontWeight.bold)),
          title:Text(plan.visualLabels[i]),
          subtitle:Text(plan.visualDetails[i])),
    ]);
  }
  Widget _dataset(LessonDeepPlan plan){
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Da origem à tabela que você pode conferir',
        style:TextStyle(fontSize:15,fontWeight:FontWeight.w700)),
      const SizedBox(height:12),
      SingleChildScrollView(scrollDirection:Axis.horizontal,
        child:DataTable(
          columns:const [
            DataColumn(label:Text('Etapa')),
            DataColumn(label:Text('Elemento')),
            DataColumn(label:Text('Controle')),
          ],
          rows:[
            for(var i=0;i<plan.visualLabels.length;i++)
              DataRow(cells:[
                DataCell(Text('${i+1}')),
                DataCell(Text(plan.visualLabels[i])),
                DataCell(SizedBox(width:220,
                  child:Text(plan.visualDetails[i],
                    overflow:TextOverflow.visible))),
              ]),
          ],
        )),
      const SizedBox(height:12),
      const Text('A relação entre tabelas é uma operação matemática '
        'sobre registros, não a descoberta automática de novas pessoas.'),
    ]);
  }
  Widget _statistical(LessonDeepPlan plan){
    final values=widget.chapter==24?
      <double>[1,2,2,3,20]:
      widget.chapter==26?
      <double>[0.75,0.25]:
      widget.chapter==17?
      <double>[7,21]:
      <double>[95,99,194];
    final labels=widget.chapter==24?
      <String>['1s','2s','2s','3s','20s']:
      widget.chapter==26?
      <String>['Não','Sim']:
      widget.chapter==17?
      <String>['Vídeo','Outros']:
      <String>['VP','FP','Pos.'];
    final peak=values.reduce((a,b)=>a>b?a:b);
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('DADOS SINTÉTICOS • SIMULAÇÃO DIDÁTICA',
        style:TextStyle(letterSpacing:0.8,
          color:dark,fontSize:11,fontWeight:FontWeight.bold)),
      const SizedBox(height:14),
      SizedBox(height:200,
        child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:[
          for(var i=0;i<values.length;i++)
            Expanded(child:Padding(
              padding:const EdgeInsets.symmetric(horizontal:5),
              child:Column(mainAxisAlignment:MainAxisAlignment.end,children:[
                Text(values[i].toStringAsFixed(
                  values[i]<1?2:0),style:const TextStyle(fontSize:12)),
                const SizedBox(height:5),
                AnimatedContainer(
                  duration:const Duration(milliseconds:250),
                  height:145*values[i]/peak+3,
                  width:double.infinity,
                  decoration:BoxDecoration(
                    color:i.isEven?const Color(0xFF286746):
                      const Color(0xFF789AB5),
                    borderRadius:const BorderRadius.vertical(top:Radius.circular(5)))),
                const SizedBox(height:8),
                Text(labels[i],style:const TextStyle(
                  fontSize:12,fontWeight:FontWeight.w600)),
              ])),
            ),
        ])),
      const SizedBox(height:12),
      Text(switch(widget.chapter){
        17=>'7 de 28 eventos: a parte é 25% do conjunto de registros examinados.',
        24=>'Cinco tempos de treino: média 5,6 s e mediana 2 s. O valor 20 é extremo.',
        26=>'Modelo Bernoulli com p=0,25: a frequência é um pressuposto hipotético.',
        _=>'Dados hipotéticos: sensibilidade e taxas de falso positivo não '
          'determinam sozinhas o valor preditivo. Compare as taxas de base.',
      },style:const TextStyle(fontSize:14,height:1.5)),
      const SizedBox(height:9),
      const Text('O gráfico serve para entender o conceito. '
        'Não foi gerado de um caso criminal real.',
        style:TextStyle(fontSize:12)),
    ]);
  }
}
