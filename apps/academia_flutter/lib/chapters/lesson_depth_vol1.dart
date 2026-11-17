/// Structured instructor-authored lessons, derived from the themes and
/// instructional progression of the user's forensic encyclopedia. Examples
/// are synthetic teaching extensions, never asserted as case evidence.
enum LessonSceneKind { process, comparison, timeline, evidence, code, data, statistics }

class LessonDeepSection {
  const LessonDeepSection({
    required this.title,
    required this.explanation,
    required this.demonstration,
    required this.practicalQuestion,
  });
  final String title;
  final String explanation;
  final String demonstration;
  final String practicalQuestion;
}

class LessonDeepPlan {
  const LessonDeepPlan({
    required this.kind,
    required this.challenge,
    required this.sections,
    required this.visualLabels,
    required this.visualDetails,
    required this.nextInvestigation,
  });
  final LessonSceneKind kind;
  final String challenge;
  final List<LessonDeepSection> sections;
  final List<String> visualLabels;
  final List<String> visualDetails;
  final String nextInvestigation;
}

const deepLessonsVolumeOne=<int,LessonDeepPlan>{
1:LessonDeepPlan(
  kind:LessonSceneKind.evidence,
  challenge:'Uma cópia apresenta o mesmo SHA-256 que o arquivo de referência. O que você sabe — e o que ainda precisa demonstrar?',
  visualLabels:['Arquivo recebido','Cópia de trabalho','Registro do exame','Conclusão limitada'],
  visualDetails:['Fonte e responsável identificados','Bytes comparados, sem modificar o original','Procedimento, versão e valores de hash','Integridade observada; autoria não demonstrada'],
  nextInvestigation:'Use o laboratório de hash da aula. Depois explique, com suas palavras, por que integridade não equivale a autoria.',
  sections:[
    LessonDeepSection(
      title:'De um byte observado a uma afirmação verificável',
      explanation:'O vestígio digital começa como algo observável e registrável: um arquivo, um registro de sistema ou uma imagem de disco. A transformação em informação pericial exige definir a questão, indicar como o objeto foi recebido e separar a descrição da inferência. Um documento pode ser tecnicamente legível e, ainda assim, ter proveniência desconhecida. O examinador não deve transformar a existência do arquivo numa afirmação sobre quem o produziu.',
      demonstration:'Suponha que um arquivo mensagem.txt contenha «Encontro às 14h». A constatação primária é que os bytes examinados representam esse texto na codificação considerada. Não é possível atribuir autoria, intenção ou contexto usando apenas o nome do arquivo e a mensagem.',
      practicalQuestion:'Que informação faltaria para vincular a mensagem a um dispositivo e a uma pessoa?'),
    LessonDeepSection(
      title:'O hash verifica correspondência, não todos os aspectos da origem',
      explanation:'SHA-256 calcula um resumo determinístico dos bytes. Você aplica a função à entrada e compara o resultado com um valor documentado. A igualdade de resumos oferece forte verificação de que os bytes coincidem; alterações no nome do arquivo, na pasta e em certos metadados externos não precisam alterar seu conteúdo. Portanto, mantenha registro separado de identificação, ambiente e procedimento. A ausência de erro na ferramenta não comprova que a coleta anterior foi adequada.',
      demonstration:'Dois arquivos com os mesmos bytes, guardados em pastas diferentes, produzem o mesmo SHA-256. Se um byte mudar, o resumo normalmente se altera drasticamente. O experimento demonstra uma propriedade criptográfica, não a veracidade do texto.',
      practicalQuestion:'Se duas cópias coincidem mas o original não foi documentado, qual limitação permanece?'),
    LessonDeepSection(
      title:'Construa uma trilha de auditoria antes de interpretar',
      explanation:'Identifique o item, o momento da aquisição, o agente responsável, a ferramenta e versão, o arquivo de entrada e as cópias derivadas. Para cada transformação, registre seus parâmetros e saídas. Organize os resultados de forma que uma segunda pessoa possa reproduzir as operações ou reconhecer exatamente por que não poderia reproduzi-las. Em conclusão técnica, use verbos proporcionais à observação: «foi encontrado», «é compatível», «não foi possível determinar».',
      demonstration:'Registro mínimo didático: item LAB-01; entrada mensagem.txt; operação SHA-256; hash obtido; cópia de trabalho; resultado comparativo; ressalva de que não se examinou a origem do dispositivo.',
      practicalQuestion:'Qual etapa precisa ocorrer antes de responder se o arquivo foi modificado?'),
  ]),
2:LessonDeepPlan(
  kind:LessonSceneKind.process,
  challenge:'Você recebeu um arquivo num pendrive sem protocolo de entrega. Por onde começa?',
  visualLabels:['Recebimento','Preservação','Aquisição controlada','Verificação','Guarda e histórico'],
  visualDetails:['Quem, quando, condição, identificador','Manter original e controlar acessos','Criar derivado sem sobrescrever','Comparar conteúdos e registrar hashes','Registrar transferências e lacres'],
  nextInvestigation:'Escreva um protocolo para receber dois arquivos e um dispositivo, indicando nomes únicos, horários, pessoas e cópias de análise.',
  sections:[
    LessonDeepSection(title:'Cadeia de custódia é uma história documentada',
      explanation:'Um objeto de exame muda de mãos, lugar e condição ao longo do tempo. O registro de custódia serve para reconstruir essas mudanças. Documente recebimento, origem declarada, estado, identificadores, movimentações e responsáveis. Se uma etapa é desconhecida, isso deve ser declarado; nenhum cálculo posterior preenche automaticamente a lacuna histórica. Em contexto brasileiro, observe as exigências aplicáveis do Código de Processo Penal e as condições concretas do trabalho.',
      demonstration:'Uma mídia recebida sem lacre não deve ganhar no relatório um «lacre de origem» imaginário. Registre que chegou sem lacre, quem a entregou e o método empregado dali em diante.',
      practicalQuestion:'É correto usar um hash calculado hoje para afirmar quem teve acesso ao arquivo ontem?'),
    LessonDeepSection(title:'Original, cópia e derivado não são sinônimos',
      explanation:'Um original recebido permanece distinguível de cópias produzidas para análise. Uma imagem bit a bit e uma extração lógica podem conter conjuntos diferentes de informação; o método depende do dispositivo, das permissões e da questão. Criar arquivo CSV tratado ou imagem redimensionada é gerar um derivado. Proteja os originais, atribua nomes próprios às saídas e documente todas as transformações.',
      demonstration:'O diretório origem/ contém arquivo sem edição; trabalho/ contém a cópia verificada; resultados/ reúne planilha, log e gráfico. Isso permite repetir a análise sem perder o arquivo recebido.',
      practicalQuestion:'Qual arquivo deve ser usado para testes que possam modificar conteúdo?'),
    LessonDeepSection(title:'Verifique o processo, não só o número',
      explanation:'Hashes ajudam a comparar entradas e cópias, mas não garantem que o dispositivo foi adquirido de modo adequado. Uma cópia pode estar íntegra em relação a uma referência já incompleta. Registre a ferramenta, a versão e possíveis erros durante a coleta. Ao final, descreva limitações como setores ilegíveis, arquivos indisponíveis e transferências não observadas; não as esconda em notas minúsculas.',
      demonstration:'Um manifesto pode listar nome, tamanho, SHA-256 e data de coleta de cada item. Uma segunda execução deve conferir esses valores e apontar diferenças.',
      practicalQuestion:'Por que duas cópias idênticas podem ainda ser insuficientes para responder à questão pericial?'),
  ]),
3:LessonDeepPlan(
  kind:LessonSceneKind.comparison,
  challenge:'Uma foto JPEG foi copiada para outro computador. O conteúdo, o nome, a data e o formato necessariamente mudam juntos?',
  visualLabels:['Nome e extensão','Assinatura interna','Hash do conteúdo','Metadados externos'],
  visualDetails:['Rótulos atribuídos em diretórios','Bytes que indicam formato','Resumo dos bytes específicos','Datas e propriedades dependentes do sistema'],
  nextInvestigation:'Altere o nome de um arquivo didático sem mudar seus bytes. Compare o que muda no inventário e no hash.',
  sections:[
    LessonDeepSection(title:'Bits, bytes, codificação e formatos',
      explanation:'Um byte representa oito bits; sua interpretação depende de uma convenção. O mesmo conjunto de bytes pode ser examinado como texto, imagem, instruções ou números conforme o formato. Uma extensão não constitui prova de formato: programas podem reconhecer estruturas internas por cabeçalhos e assinaturas. A finalidade do inventário é caracterizar o que existe antes de afirmar o que representa.',
      demonstration:'O nome foto.jpg pode apontar para bytes de um arquivo PNG. O conflito entre extensão e assinatura exige registro e investigação, não a conclusão automática de fraude.',
      practicalQuestion:'O que você verificaria primeiro: extensão, assinatura interna ou relato do remetente?'),
    LessonDeepSection(title:'Metadados pertencem a camadas diferentes',
      explanation:'Tamanho e carimbos do sistema de arquivos descrevem o objeto no volume examinado. EXIF e outros metadados internos podem acompanhar o conteúdo, mas também podem estar ausentes ou ter sido editados. A data de criação no Windows pode indicar quando uma cópia foi criada naquele volume. É indispensável distinguir o evento medido pelo campo da ocorrência investigada.',
      demonstration:'Um arquivo transferido pode conservar a data de modificação e receber nova data de criação. Isso não demonstra sozinho que sua fotografia foi tirada nas duas datas.',
      practicalQuestion:'Qual é a diferença entre «data de criação no volume» e «momento de captura»?'),
    LessonDeepSection(title:'Inventário que alguém consegue auditar',
      explanation:'Registre o caminho, tamanho, hash, formato inferido, propriedades internas e origem declarada em campos separados. Preserve identificadores como texto, inclusive zeros à esquerda. Qualquer exportação CSV deve informar encoding, fuso quando existirem datas e regra para nulos. A revisão deve procurar discrepâncias, não apagá-las automaticamente.',
      demonstration:'Um inventário didático compara caminho arquivo01.png, assinatura PNG, tamanho em bytes e SHA-256. Uma discrepância de extensão recebe uma observação específica.',
      practicalQuestion:'Que coluna adicional ajudaria a diferenciar a fonte original do arquivo inventariado?'),
  ]),
4:LessonDeepPlan(
  kind:LessonSceneKind.timeline,
  challenge:'Uma câmera marca 20:16:12, mas sua aferição revela 75 segundos de adiantamento. O vídeo confirma um evento de rede às 20:15?',
  visualLabels:['Câmera exibida','Correção conhecida','Intervalo aferido','Registro de rede','Compatibilidade, não autoria'],
  visualDetails:['20:16:12 no visor','Subtrair 75 segundos','Declarar incerteza da medição','Normalizar fuso e tipo de evento','Verificar se os intervalos realmente se cruzam'],
  nextInvestigation:'Na simulação, ajuste o desvio da câmera e amplie a incerteza. Observe como muda a janela de compatibilidade.',
  sections:[
    LessonDeepSection(title:'Uma cronologia não nasce com a ordenação de datas',
      explanation:'Comparar eventos exige saber a fonte e a semântica de cada horário. Uma operadora pode registrar início de sessão; um vídeo pode mostrar horário sobreposto pelo gravador; o sistema de arquivos pode marcar modificação do arquivo exportado. Essas três datas não descrevem necessariamente o mesmo evento. Construa uma tabela com valor bruto, sistema, fuso, precisão, possível desvio e contexto.',
      demonstration:'Câmera 20:16:12, desvio +75 s e incerteza ±10 s: referência corrigida 20:14:57, com intervalo aproximado 20:14:47 a 20:15:07.',
      practicalQuestion:'Por que a data de criação do MP4 não deve substituir o horário do acontecimento gravado?'),
    LessonDeepSection(title:'Normalize fusos e desvio antes de aproximar eventos',
      explanation:'Transforme horários numa referência comum, por exemplo UTC, mas registre também os originais e os deslocamentos usados. Horário corrigido = horário observado − adiantamento do instrumento. Para um relógio atrasado, o ajuste tem sinal negativo e a subtração equivale a somar seu atraso. Inclua incerteza: um único número pode dar impressão de exatidão que não existe.',
      demonstration:'Dois eventos distantes três segundos só são temporalmente compatíveis se as respectivas janelas de incerteza e a semântica dos registros permitirem a comparação.',
      practicalQuestion:'O que acontece com a conclusão se a incerteza da câmera é maior do que a diferença entre eventos?'),
    LessonDeepSection(title:'Conexão técnica não equivale a presença pessoal',
      explanation:'CDRs e informações sobre estações rádio-base podem documentar interações de rede, mas não dão, isoladamente, a localização exata de um usuário nem a identidade de quem operava o aparelho. Vídeos podem mostrar objetos e atividades sem identificar pessoas. O produto responsável de uma cronologia é uma tabela de compatibilidades, conflitos e lacunas, e não uma história fechada com base em proximidade de horários.',
      demonstration:'Um evento de rede e um movimento em vídeo podem ser compatíveis em tempo; ainda faltam vínculos independentes entre o aparelho, a pessoa, o local e a ação.',
      practicalQuestion:'Qual evidência adicional seria necessária para passar de compatibilidade temporal a atribuição de identidade?'),
  ]),
5:LessonDeepPlan(
  kind:LessonSceneKind.evidence,
  challenge:'O cliente pede «prove que o depoente mentiu». Como reformular sem presumir intenção?',
  visualLabels:['Pedido interessado','Pergunta observável','Hipótese A','Hipótese B','Critério de comparação'],
  visualDetails:['Conclusão solicitada sem teste','Quais afirmações podem ser comparadas?','Relato corresponde aos registros','Relato diverge por memória ou contexto','Definir fontes, precisão e critérios'],
  nextInvestigation:'Reformule três pedidos acusatórios em questões tecnicamente examináveis e registre o que não pode ser inferido.',
  sections:[
    LessonDeepSection(title:'Transforme uma narrativa numa pergunta testável',
      explanation:'Uma parte pode trazer uma tese pronta, mas o exame técnico começa pela questão que os dados podem responder. «Quem estava na rua?» pode exceder a capacidade de uma câmera que não mostra rostos. Reformule para algo como «que características visíveis, sequência de quadros e intervalo temporal foram registrados?». Isso protege a imparcialidade e permite dizer claramente quando a informação não é suficiente.',
      demonstration:'Pedido: «confirme que o aparelho estava na casa». Pergunta: «quais registros de rede, suas condições de cobertura e intervalos são documentados?».',
      practicalQuestion:'O que tornaria a pergunta falsificável ou sujeita a comparação independente?'),
    LessonDeepSection(title:'Hipóteses concorrentes evitam conclusão circular',
      explanation:'Para cada observação, enumere explicações plausíveis que produziriam o mesmo vestígio. Um login pode resultar de uso pelo titular, de credencial compartilhada ou de automação. As hipóteses devem implicar expectativas verificáveis e riscos de erro, não simplesmente narrativas vagas. Procure dados capazes de discriminar alternativas, incluindo observações contrárias à hipótese inicialmente preferida.',
      demonstration:'A mesma conta foi acessada de dois IPs. Antes de inferir duas pessoas, examine VPN, NAT, sessões simultâneas e artefatos do próprio serviço.',
      practicalQuestion:'Qual dado faria você reconsiderar sua primeira explicação?'),
    LessonDeepSection(title:'Escreva uma conclusão limitada e útil',
      explanation:'Uma boa resposta é proporcional às observações. Evite os extremos «impossível saber qualquer coisa» e «provado sem dúvida». Indique quais fatos foram documentados, quais processos de inferência foram aplicados e o que permanece fora da capacidade dos dados. Na defesa ou na acusação, a independência técnica depende de manter essa fronteira explícita.',
      demonstration:'Formulação adequada: «os registros fornecidos apresentam divergência de 43 segundos após a correção descrita; não determinam isoladamente a identidade do usuário».',
      practicalQuestion:'Como separaria em duas frases o resultado observável e a interpretação?'),
  ]),
6:LessonDeepPlan(
  kind:LessonSceneKind.comparison,
  challenge:'Três notícias repetem um único relatório. Você tem três confirmações independentes?',
  visualLabels:['Arquivo original','Extrato produzido','Reportagem A','Reportagem B'],
  visualDetails:['Objeto examinado diretamente','Documento que seleciona informações','Reproduz o mesmo extrato','Cita reportagem A, sem outra origem'],
  nextInvestigation:'Monte a genealogia de uma afirmação, ligando as publicações à sua fonte original e marcando cópias dependentes.',
  sections:[
    LessonDeepSection(title:'Fonte primária é relativa à pergunta',
      explanation:'Uma decisão judicial é fonte primária para o que o tribunal registrou ou decidiu. Não é automaticamente fonte primária dos bytes de um celular não anexados aos autos. Uma transcrição permite examinar as palavras transcritas, mas não sustenta conclusões sobre entonação sem áudio correspondente. Avalie a natureza do documento em relação à afirmação específica, e não por um rótulo fixo de confiabilidade.',
      demonstration:'Uma reportagem que cita um trecho de decisão pode sustentar o fato de que a decisão foi noticiada. Para confirmar o conteúdo jurídico, consulte o documento judicial; para verificar vestígio técnico, examine o arquivo de origem quando legalmente acessível.',
      practicalQuestion:'Qual é a fonte mais próxima do objeto da sua afirmação?'),
    LessonDeepSection(title:'Independência informacional precisa ser demonstrada',
      explanation:'Publicações e análises aparentemente diferentes podem compartilhar um mesmo conjunto de dados. Se três análises derivam do mesmo extrato parcial, elas não corrigem automaticamente as limitações desse extrato. Registre relações de dependência e identifique transformações: corte de imagem, exportação, transcrição, normalização de horários. Conte observações independentes somente quando a proveniência sustentar essa distinção.',
      demonstration:'Reportagem A cita um laudo. Reportagem B cita A. Um vídeo de rede social cita B. Há várias publicações, mas nenhuma nova inspeção independente do vestígio.',
      practicalQuestion:'O que precisaria mudar para surgir uma verificação independente?'),
    LessonDeepSection(title:'Matriz de fontes para preparar o exame',
      explanation:'Liste identificador, responsável, origem alegada, formato recebido, método de aquisição, data, possíveis lacunas e uso pretendido. Separe «o arquivo mostra» de «o autor da reportagem afirma». Quando houver conflito entre fontes, preserve a divergência e analise qual objeto cada uma de fato representa. Uma fonte de melhor reputação não substitui a documentação do vínculo com o vestígio.',
      demonstration:'Tabela: F01 vídeo exportado → permite examinar aquela exportação; F02 transcrição → permite examinar texto; F03 relato de terceiro → contextualiza uma versão, sem autenticar F01.',
      practicalQuestion:'Que coluna evita misturar afirmação de comentarista com observação sobre o arquivo?'),
  ]),
7:LessonDeepPlan(
  kind:LessonSceneKind.timeline,
  challenge:'Um relógio mostra segundos, mas está 45 segundos atrasado. Qual é a incerteza real do evento?',
  visualLabels:['Mensurando','Resolução','Correção do desvio','Incerteza','Relato técnico'],
  visualDetails:['Qual instante estamos tentando medir?','Passo mínimo exibido pelo sistema','Comparação com relógio de referência','Amplitude justificada, não inventada','Intervalo e pressupostos declarados'],
  nextInvestigation:'Use a régua temporal do capítulo 4 variando desvio e incerteza. Compare resolução de 1 s com erro de dezenas de segundos.',
  sections:[
    LessonDeepSection(title:'Descubra o mensurando antes da conta',
      explanation:'O mensurando é aquilo que você pretende medir: horário de início da transmissão, de gravação, de exibição em tela ou do fato físico. Uma ferramenta pode fornecer o valor de um campo que não corresponde a esse mensurando. Formalizar a grandeza evita comparar dados que parecem ter a mesma unidade, mas representam eventos distintos.',
      demonstration:'Um arquivo MP4 foi exportado às 16h e registra uma ação às 14h. «Horário do arquivo» e «horário do acontecimento» não devem ser fundidos numa coluna sem explicação.',
      practicalQuestion:'Qual campo mede o instante do acontecimento e qual mede o momento da exportação?'),
    LessonDeepSection(title:'Resolução, precisão, exatidão e viés',
      explanation:'Resolução é a granularidade da representação, como décimos de segundo. Precisão descreve dispersão quando o procedimento é repetido. Exatidão depende da proximidade de um valor de referência. Um relógio pode ser muito estável e consistentemente adiantado. O erro sistemático não desaparece porque as medições se repetem; a incerteza precisa refletir as condições reais de aferição.',
      demonstration:'Um relógio que marca 12:00:00 a cada observação pode ser preciso em repetição e pouco exato se a referência for 11:59:15.',
      practicalQuestion:'Que teste permitiria estimar o desvio sistemático?'),
    LessonDeepSection(title:'Propague limites sem falsa certeza',
      explanation:'Ao subtrair um desvio estimado, registre o intervalo de incerteza. Não trate limites como necessariamente gaussianos nem some margens de modo automático sem examinar seu significado. Quando duas janelas temporais se cruzam, o cruzamento indica compatibilidade sob os pressupostos utilizados; não identifica por si só pessoa ou causa.',
      demonstration:'Instante estimado 14:31:00 ±20 s e outro registro 14:31:15 ±10 s possuem intervalos sobrepostos. Isso não diz que descrevem o mesmo acontecimento.',
      practicalQuestion:'Como sua conclusão muda se você descobrir que um dos relógios não foi aferido?'),
  ]),
8:LessonDeepPlan(
  kind:LessonSceneKind.evidence,
  challenge:'O investigador lhe apresenta primeiro a narrativa acusatória. Isso pode alterar sua leitura técnica?',
  visualLabels:['Hipótese inicial','Dados antes da narrativa','Critérios definidos','Revisão independente','Relato de divergências'],
  visualDetails:['Risco de ancoragem','Separar contexto necessário do sugestivo','Pré-registro e controles negativos','Verificar classificação e omissões','Conservar erros e correções no histórico'],
  nextInvestigation:'Monte um protocolo cego para classificar registros antes de receber informações narrativas não necessárias.',
  sections:[
    LessonDeepSection(title:'Viés não é sinônimo de fraude',
      explanation:'Expectativas, ordem de informação e familiaridade com uma hipótese podem alterar o que uma pessoa nota e considera importante. Isso pode ocorrer sem intenção de enganar. Contexto técnico indispensável deve continuar disponível; o controle consiste em limitar informações irrelevantes, documentar decisões e proteger a análise da pressão pelo resultado desejado.',
      demonstration:'Se você já recebeu a hipótese «o telefone estava na casa», talvez destaque apenas horários compatíveis e ignore períodos sem registro. Um inventário prévio de todos os eventos reduz esse risco.',
      practicalQuestion:'Que contexto é necessário para examinar a rede e qual poderia ser retido inicialmente?'),
    LessonDeepSection(title:'O pré-registro protege contra critérios oportunistas',
      explanation:'Defina antes da análise os critérios de inclusão, exclusão, normalização, unidades, tratamento de valores ausentes e teste de hipóteses concorrentes. Se uma regra mudar depois de examinar os dados, registre o motivo. A revisão técnica precisa conferir não só o resultado, mas a cadeia de decisões que o produziu. Revisão administrativa de preenchimento não equivale a revisão técnica do método.',
      demonstration:'Antes de comparar horários, declare a tolerância temporal que será usada e o método de aferição; não ajuste a tolerância até que a narrativa preferida pareça coincidir.',
      practicalQuestion:'Como diferenciar uma correção justificada de uma escolha de critério pós-resultado?'),
    LessonDeepSection(title:'Erros encontrados são informação, não vergonha',
      explanation:'Controle de qualidade depende de registrar não conformidades, reexecutar procedimentos e verificar impactos em resultados já produzidos. Não apague silenciosamente uma planilha defeituosa: produza nova versão, explique o erro e documente as correções. Uma conclusão condicionada a procedimentos auditáveis é mais forte do que uma conclusão aparentemente definitiva construída sobre decisões ocultas.',
      demonstration:'Você descobre que a conversão de UTC foi aplicada duas vezes. Registre o conjunto afetado, corrija com script verificável e atualize a conclusão, mantendo histórico.',
      practicalQuestion:'Quais evidências de revisão mostrariam que a correção não introduziu outro erro?'),
  ]),
9:LessonDeepPlan(
  kind:LessonSceneKind.process,
  challenge:'Um gráfico está correto, mas ninguém consegue refazer o cálculo. O relatório é suficiente?',
  visualLabels:['Pergunta','Entradas preservadas','Procedimento','Verificações','Conclusão com limites'],
  visualDetails:['Definir escopo','Identificador, hash, fonte e data','Ferramenta, versão e parâmetros','Controle de contagens e reproduções','Distinguir resultado e inferência'],
  nextInvestigation:'Escreva uma entrada de diário com data, operador, arquivo de treino, comando, resultado, erro e correção.',
  sections:[
    LessonDeepSection(title:'O diário de laboratório faz parte do método',
      explanation:'Notas contemporâneas evitam reconstruir de memória a sequência do trabalho. Registre horário e fuso, operador, projeto, objetivo, arquivo de entrada, tamanho, hash, ferramenta, versão, parâmetros, saída, verificação e eventuais erros. Uma alteração posterior deve acrescentar informação rastreável, não sobrescrever sem histórico o que foi registrado anteriormente.',
      demonstration:'Entrada: LAB-27, 14:10 UTC−03; CSV de treino; objetivo validar formato da coluna de horário; script e versão; duas linhas aceitas; nenhuma conclusão sobre operadora real.',
      practicalQuestion:'Como provaria que um gráfico publicado corresponde à versão de dados declarada?'),
    LessonDeepSection(title:'Separe observação, resultado, interpretação e conclusão',
      explanation:'Uma observação descreve o que foi examinado. Um resultado reporta uma saída de procedimento. Uma interpretação discute seu significado sob certas premissas. Uma conclusão responde à questão no escopo possível, incluindo limitações. Colocar essas quatro categorias em campos separados torna o relatório contestável e compreensível para pessoas que não executaram a análise.',
      demonstration:'Observação: duas linhas com timestamp vazio. Resultado: 2/18 registros sem horário. Interpretação: há lacuna de dados. Conclusão: não é possível ordenar aqueles eventos com o método atual.',
      practicalQuestion:'Qual parte do exemplo é uma constatação e qual é uma inferência?'),
    LessonDeepSection(title:'Figuras e tabelas precisam apontar para as fontes',
      explanation:'Toda figura deve ter título, unidades, origem, versão de conjunto de dados e transformação que a produziu. Um gráfico de barras sem denominador pode ser visualmente convincente e metodologicamente enganoso. Cite o método de seleção e preserve a tabela subjacente. Em relatório final, não transforme limites em rodapés que ninguém encontra.',
      demonstration:'Figura: «Eventos por categoria no CSV sintético recebido, n=18, após exclusão justificada de duas linhas sem tipo; script vers. X».',
      practicalQuestion:'Que metadados faltam a um gráfico com título genérico «Incidentes por hora»?'),
  ]),
10:LessonDeepPlan(
  kind:LessonSceneKind.process,
  challenge:'Vídeo e evento de rede parecem coincidir. O que seria um relatório integrador reproduzível?',
  visualLabels:['Inventário de fontes','Hashes e origem','Régua de horários','Hipóteses concorrentes','Relatório condicional'],
  visualDetails:['Arquivos e documentação recebidos','Derivados separados dos originais','Fusos, desvio e incerteza','Compatibilidade não é identidade','Demonstrar passos e lacunas'],
  nextInvestigation:'Use dados sintéticos de duas câmeras e dois registros de rede para montar uma tabela de compatibilidade temporal sem identificar pessoas.',
  sections:[
    LessonDeepSection(title:'Primeiro faça inventário, não uma narrativa',
      explanation:'O laboratório integrador reúne princípios de integridade, custódia, metadados, horários, crítica de fontes e relato. Comece atribuindo identificadores a cada objeto recebido. Registre quais itens são originais, exportações, transcrições e outros derivados. Não presuma que materiais sobre o mesmo assunto sejam partes completas de uma coleção.',
      demonstration:'V01 vídeo exportado; V02 vídeo de outra câmera; R01 e R02 eventos em extrato CSV. Cada identificador tem origem, data, formato, hash quando aplicável e limitação.',
      practicalQuestion:'Como evidenciar em tabela que uma exportação de vídeo não equivale a acesso ao DVR completo?'),
    LessonDeepSection(title:'O cruzamento precisa ter uma régua de tempo auditável',
      explanation:'Normalize cada horário para uma referência comum, preservando a versão original. Diferencie relógio aferido de relógio desconhecido; não esconda a incerteza de uma câmera numa coluna de «horário corrigido». Compare intervalos em vez de escolher um instante que pareça conveniente. Documente quais eventos são observados e quais ligações surgiram apenas por associação.',
      demonstration:'Vídeo V01 20:14:10 e evento R01 20:16:12 são registros distintos. Mesmo que haja correção temporal, isso não identifica automaticamente uma pessoa.',
      practicalQuestion:'Que condição tornaria inadequado afirmar uma coincidência de dois segundos?'),
    LessonDeepSection(title:'Entregue uma conclusão falsificável e limitada',
      explanation:'O relatório integrador descreve fontes, método de preparação, tabelas derivadas, verificação dos cálculos, observações, hipóteses concorrentes e limitações. Não acrescente fatos sobre investigações reais a um conjunto sintético. Um bom relatório permite ao leitor seguir a origem de cada número e reconhecer lacunas sem precisar confiar na autoridade de quem assina.',
      demonstration:'Conclusão didática: «os eventos R01 e V02 são compatíveis sob a correção declarada; a correspondência não identifica usuário nem comprova relação causal».',
      practicalQuestion:'Que teste ou dado adicional poderia separar as hipóteses compatíveis?'),
  ]),
};
