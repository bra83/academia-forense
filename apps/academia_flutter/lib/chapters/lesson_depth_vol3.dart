import 'lesson_depth_model.dart';

const deepLessonsVolumeThree=<int,LessonDeepPlan>{
24:LessonDeepPlan(
 kind:LessonSceneKind.statistics,
 challenge:'Os tempos de resposta são 1, 2, 2, 3 e 20 segundos. Por que média e mediana contam histórias diferentes?',
 visualLabels:['Unidade da observação','Dados completos','Média e mediana','Valores extremos','Limites da amostra'],
 visualDetails:['Uma ocorrência definida de antemão','Verificar duplicações e ausências','Média 5,6 s, mediana 2 s','20 s puxa a média para cima','Cinco registros não descrevem automaticamente a população'],
 nextInvestigation:'Calcule média, mediana, mínimo, máximo e amplitude dos cinco tempos de treino; remova o extremo para observar a sensibilidade de cada medida.',
 sections:[
 LessonDeepSection(
  title:'Defina a unidade de observação antes de somar',
  explanation:'Uma tabela contém linhas, mas nem toda linha corresponde a um evento independente. O identificador deve ter significado declarado e as colunas devem guardar tipos e unidades compatíveis. Duração pode significar tempo de sessão, duração faturada ou diferença entre timestamps; a estatística não decide essa semântica. Prepare dicionário de dados e verifique valores duplicados, ausências e seleções antes de calcular indicadores.',
  demonstration:'Uma tabela com evento_id, sistema, duracao_segundos e qualidade precisa esclarecer se «duracao_segundos» é medida direta, estimativa ou duração arredondada. Se a mesma chamada foi exportada duas vezes, contar duas linhas pode inflar uma frequência.',
  practicalQuestion:'Que dados você precisa para decidir se duas linhas são duplicatas ou eventos distintos?'),
 LessonDeepSection(
  title:'Média, mediana e dispersão descrevem aspectos diferentes',
  explanation:'A média soma valores válidos e divide pela quantidade correspondente. A mediana é o valor central depois da ordenação. Em 1, 2, 2, 3 e 20 segundos, a soma é 28 e a média é 5,6; a mediana é 2. O valor extremo mostra por que um único número pode esconder o comportamento típico. Informe também contagem de observações, mínimo, máximo e, quando útil, quartis ou variabilidade.',
  demonstration:'Se você excluir 20 segundos por motivo declarado, a média dos quatro restantes vira 2 segundos. Sem declarar a exclusão, dois analistas podem publicar médias diferentes para o mesmo conjunto.',
  practicalQuestion:'Em que situação uma mediana ajudaria mais que a média e que informação se perderia ao mostrar só ela?'),
 LessonDeepSection(
  title:'Uma visualização é também uma escolha metodológica',
  explanation:'Gráficos de barras comunicam categorias, histogramas representam distribuições numéricas agrupadas em classes, e gráficos temporais dependem de referência de tempo. A escolha de escala, bins e valores excluídos influencia a impressão visual. Não comece o eixo em valor enganoso nem misture categorias com unidades. Descreva se o conjunto é população, amostra ou apenas os registros disponíveis.',
  demonstration:'Um histograma de cinco valores possui pouca estabilidade; um gráfico de pontos com os valores individuais mostra melhor o extremo 20. A figura deve dizer «tempos sintéticos, n=5», com unidade de segundos.',
  practicalQuestion:'Qual gráfico ajuda a ver o valor extremo sem esconder os registros individuais?'),
 ]),
25:LessonDeepPlan(
 kind:LessonSceneKind.statistics,
 challenge:'Um teste hipotético tem 95% de sensibilidade. Um positivo significa que a hipótese tem 95% de chance de ser verdadeira?',
 visualLabels:['Prevalência inicial','Sensibilidade','Falso positivo','Resultado observado','Probabilidade posterior'],
 visualDetails:['Frequência antes do teste','P(+|H)','P(+|não H) = 1 − especificidade','A evidência precisa de modelo adequado','P(H|+) depende de todos os elementos'],
 nextInvestigation:'Use o simulador para variar prevalência, sensibilidade e especificidade. Explique por que um teste confiável pode produzir muitos falsos positivos em eventos raros.',
 sections:[
 LessonDeepSection(
  title:'Probabilidade de evento não é opinião sobre culpa',
  explanation:'Probabilidade matemática nasce de um espaço de resultados, um modelo e pressupostos claros. Uma frequência observada é uma proporção em dados concretos; uma probabilidade teórica descreve o modelo escolhido. Esses conceitos não autorizam concluir a probabilidade de culpa de uma pessoa. Em situações de coincidência temporal, por exemplo, é preciso justificar distribuição de horários, independência e oportunidades de ocorrência.',
  demonstration:'Se dois instantes inteiros variam uniformemente entre 0 e 59 e o segundo fixo é 30, uma janela de cinco valores favoráveis produz 5/60 de coincidência no modelo. Se os horários não forem uniformes, esse cálculo não se aplica.',
  practicalQuestion:'Que dados seriam necessários para justificar a hipótese de horários igualmente prováveis?'),
 LessonDeepSection(
  title:'Probabilidade condicional inverte a pergunta',
  explanation:'Sensibilidade é P(positivo dado que a hipótese é verdadeira), não P(hipótese verdadeira dado resultado positivo). A segunda quantidade exige considerar a prevalência e a frequência de falsos positivos. A regra de Bayes formaliza esse cruzamento. Não misture P(E|H) com P(H|E); elas respondem a perguntas diferentes e podem ter valores muito distintos.',
  demonstration:'Prevalência 1%, sensibilidade 95%, especificidade 99%: de 10.000 exemplos hipotéticos, cerca de 95 verdadeiros positivos e 99 falsos positivos. Entre os 194 positivos, aproximadamente 49% seriam casos da hipótese, sob essas condições inventadas para treino.',
  practicalQuestion:'Por que um valor de sensibilidade de 95% não é igual ao valor preditivo positivo nesse exemplo?'),
 LessonDeepSection(
  title:'Independência e escolha da janela são hipóteses auditáveis',
  explanation:'A regra de multiplicação simples entre eventos só funciona sob condições de independência adequadas. Em dados de rede, horários podem ser agrupados por rotinas, aplicativos e mecanismos de retry; não são necessariamente sorteios uniformes. Declarar uma coincidência «raríssima» exige conhecer o universo, o período observado e a regra de seleção, idealmente definida antes de encontrar o evento.',
  demonstration:'Se você procura centenas de pares até encontrar um encontro de horários, a chance de observar ao menos uma coincidência aumenta. Esse procedimento não pode ser avaliado como se houvesse uma única comparação planejada.',
  practicalQuestion:'O que muda se a janela de tolerância foi escolhida depois de observar as datas?'),
 ]),
26:LessonDeepPlan(
 kind:LessonSceneKind.statistics,
 challenge:'Uma contagem segue distribuição de Poisson? E se os eventos ocorrem em rajadas e não de modo independente?',
 visualLabels:['Variável de interesse','Modelo escolhido','Parâmetros','Simulação','Conferência com dados reais'],
 visualDetails:['Contagem, presença/ausência ou medida contínua','Bernoulli, binomial, Poisson, normal','p, n, λ, μ, σ precisam de justificativa','Amostras sintéticas sob o modelo','Verificar resíduos, dispersão e inadequações'],
 nextInvestigation:'Modele uma variável Bernoulli com p=0,25 e uma contagem de dez tentativas. Compare o número esperado 2,5 com possíveis resultados simulados.',
 sections:[
 LessonDeepSection(
  title:'Escolha um modelo que corresponda à variável',
  explanation:'Bernoulli descreve um único resultado binário; binomial conta sucessos sob pressupostos sobre número de tentativas, probabilidade e independência; Poisson modela certas contagens em intervalos; normal modela variáveis contínuas sob condições próprias. Distribuições são ferramentas para raciocinar, não etiquetas que automaticamente transformam registros em fenômenos conhecidos.',
  demonstration:'Um indicador de arquivo sinalizado (0 ou 1) pode ser representado por Bernoulli(p). A quantidade de sinalizações em dez tentativas pode ser comparada a um modelo binomial quando os pressupostos forem razoáveis.',
  practicalQuestion:'Por que o número de eventos registrados em um turno pode não seguir uma distribuição de Poisson simples?'),
 LessonDeepSection(
  title:'Parâmetros têm significado e precisam ser estimados',
  explanation:'Em Bernoulli(p), a esperança é p e a variância é p(1−p). Uma binomial usa n e p; uma Poisson costuma usar taxa λ; uma normal usa média e variância. Esses parâmetros podem ser estimados de dados, escolhidos como hipóteses para simulação ou obtidos de calibração. Não confunda valores escolhidos para exercício com medidas verificadas em uma população.',
  demonstration:'Para p=0,25, a esperança de uma Bernoulli é 0,25 e a variância é 0,1875. Em dez tentativas binomiais, a contagem média no modelo seria 2,5; nenhuma execução individual precisa resultar exatamente 2,5.',
  practicalQuestion:'Como distinguir parâmetro hipotético de estatística estimada numa amostra?'),
 LessonDeepSection(
  title:'Simulação é teste de um modelo, não fabricação de evidências',
  explanation:'Monte Carlo gera amostras artificiais segundo regras definidas. Compare resultados simulados com expectativas matemáticas e, separadamente, com dados de origem cuja qualidade tenha sido examinada. Use sementes quando precisar reproduzir uma execução pseudoaleatória e declare número de repetições. Se o modelo falha em reproduzir características essenciais como dependência temporal ou excesso de zeros, reporte a inadequação.',
  demonstration:'Uma simulação com milhares de lançamentos Bernoulli p=0,25 tende a aproximar proporção de 25% no conjunto longo. Ela não prova que uma ferramenta real apresenta essa taxa de sinalização.',
  practicalQuestion:'Qual observação indicaria que seu modelo não descreve adequadamente os dados coletados?'),
 ]),
};
