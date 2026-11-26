import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/offline_library.dart';

/// Bundled excerpts from the source ZIP. They are not full PDF transcriptions,
/// and their editorial accuracy has not been independently certified.
class StudySection {
  const StudySection({required this.title, required this.text});
  final String title;
  final String text;
}

class StudyChapter {
  const StudyChapter({
    required this.id,
    required this.volume,
    required this.number,
    required this.title,
    required this.edition,
    required this.editorialStatus,
    required this.pdfFileId,
    required this.sections,
  });

  final String id;
  final int volume;
  final int number;
  final String title;
  final String edition;
  final String editorialStatus;
  final String pdfFileId;
  final List<StudySection> sections;

  bool get isPublished => editorialStatus.toLowerCase() == 'publicado';
  String get originalPdfUrl => 'https://drive.google.com/file/d/' + pdfFileId + '/view';

  factory StudyChapter.fromMap(Map<String, dynamic> source) {
    final doc = source['source'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final sections = (source['sections'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map((s) => StudySection(
              title: (s['title'] ?? 'Seção').toString(),
              text: (s['markdownContent'] ?? '').toString(),
            ))
        .toList(growable: false);
    return StudyChapter(
      id: (source['contentId'] ?? '').toString(),
      volume: (source['volume'] as num).toInt(),
      number: (source['chapter'] as num).toInt(),
      title: (source['title'] ?? 'Sem título').toString(),
      edition: (source['edition'] ?? '').toString(),
      editorialStatus: (source['editorialStatus'] ?? 'Em revisão').toString(),
      pdfFileId: (doc['fileId'] ?? '').toString(),
      sections: sections,
    );
  }
}

class StudyCatalog {
  static const volumeTitles = <String>[
    'Fundamentos das Ciências Forenses',
    'Computação, Python, SQL e Matemática',
    'Estatística e Ciência de Dados Forense',
    'Perícia Digital',
    'Telefonia, Geolocalização e Cronologias',
    'Linguística Forense e NLP',
    'Documentoscopia e Multimídia',
    'Ciências Forenses Complementares',
    'Pesquisa Científica e Exercício Profissional',
  ];
  // Índice editorial; não implica disponibilidade ou aprovação científica.
  static const plannedTitles=<String>[
    'Dos dados às evidências',
    'Preservação, aquisição e cadeia de custódia',
    'Arquivos, sistemas e metadados',
    'Cronologias forenses: telefonia, vídeo e incerteza',
    'Perguntas periciais, proposições e hipóteses concorrentes',
    'Classificação, hierarquia e crítica das fontes',
    'Medição, precisão e incerteza em evidências',
    'Vieses cognitivos e controle de qualidade',
    'Documentação científica e redação de conclusões',
    'Laboratório integrador e avaliação do Volume I',
    'Computador, armazenamento e ambiente de trabalho',
    'Windows e PowerShell para iniciantes',
    'Linux e terminal aplicado',
    'Sistemas de arquivos e armazenamento',
    'Formatos, codificações e dados estruturados',
    'Redes de computadores desde o zero',
    'Matemática essencial para análise forense',
    'Python I: raciocínio algorítmico',
    'Python II: programas confiáveis',
    'NumPy e pandas para evidências tabulares',
    'Bancos de dados e SQL I',
    'SQL II: cruzamento e qualidade',
    'Ambientes reproduzíveis e segurança de projetos',
    'Estatística descritiva',
    'Probabilidade',
    'Distribuições e simulação',
    'Probabilidade condicional e raciocínio bayesiano',
    'Amostragem, representatividade e seleção',
    'Limpeza de dados sem destruir evidências',
    'Exploração e visualização científica',
    'Estimação e intervalos de confiança',
    'Testes de hipóteses e multiplicidade',
    'Regressão, confundimento e causalidade',
    'Séries temporais e dependência',
    'Grafos e análise de vínculos',
    'Aprendizado de máquina na análise forense',
    'Validação de modelos e vazamento de dados',
    'Taxas de erro, calibração e decisões',
    'Desenho de estudos e auditoria estatística',
    'Fluxo de trabalho de um exame digital',
    'Aquisição lógica, física e imagens forenses',
    'Discos, partições e recuperação de dados',
    'Windows: artefatos de uso e atividade',
    'Linux e macOS: artefatos e cronologias',
    'Navegadores, mensagens e aplicativos',
    'Forense de Android: fundamentos',
    'Forense de iOS: fundamentos',
    'Nuvem e serviços remotos',
    'Rede forense e análise de tráfego',
    'Memória e processos em execução',
    'Incidentes, malware e logs defensivos',
    'Ferramentas forenses: teste e validação',
    'Relatório e laboratório integrado de perícia digital',
    'Arquitetura das telecomunicações',
    'CDR, xDR e registros de chamadas',
    'Células, antenas e limites espaciais',
    'Registros de provedores, aplicativos e IP',
    'Relógios, UTC e cronologia avançada',
    'Vídeo de vigilância: origem e tempo',
    'Geolocalização GNSS, mapas e trilhas',
    'Cruzamento temporal entre fontes',
    'Reconstrução espacial e mapas forenses',
    'Identidades, aparelhos e resolução de entidades',
    'Estatística de coincidências e redes de contato',
    'Estudo aplicado: Hae Min Lee',
    'Estudo aplicado: Watts e relatório integrado',
    'Linguagem como evidência: fundamentos',
    'Discurso, pragmática e interação',
    'Depoimentos e documentação linguística',
    'Corpus, amostragem e representatividade',
    'Pré-processamento e métricas textuais',
    'Estilometria e comparação de autoria',
    'NLP clássico e aprendizado supervisionado',
    'Transformers, embeddings e modelos de linguagem',
    'Validação, taxas de erro e vieses',
    'Áudio, fala e transcrição para NLP',
    'Ameaças, fraudes e comunicações',
    'Laboratório integrado e relatório textual',
    'Documentoscopia: princípios e escopo',
    'Papel, tintas, impressão e alterações',
    'Escrita manual e assinaturas',
    'Documentos digitais: PDF, Office e assinaturas',
    'Imagens digitais: estrutura e metadados',
    'Autenticidade e manipulação de imagem',
    'Áudio forense: formato e integridade',
    'Comparação forense de voz: fundamentos',
    'Vídeo forense: codecs, quadros e continuidade',
    'Conteúdo sintético, deepfakes e proveniência',
    'Comparação multimídia entre fontes',
    'Estudos aplicados e relatório multimídia',
    'Ciências forenses integradas: o que uma área não resolve',
    'Toxicologia I: amostras e métodos',
    'Toxicologia II: interpretação estatística',
    'Vestígios biológicos e DNA: limites de interpretação',
    'Manchas de sangue I: física e documentação',
    'Manchas de sangue II: confiabilidade e controvérsias',
    'Vestígios materiais, balística e padrões',
    'Criminologia: teorias e aplicações limitadas',
    'Psicologia, memória e entrevista investigativa',
    'Integração multidisciplinar e decisão de encaminhamento',
    'Problema de pesquisa e originalidade científica',
    'Pesquisa bibliográfica e gerenciamento de referências',
    'Desenho de estudos e protocolo',
    'Ética, dados pessoais e proteção de terceiros',
    'Direito probatório e cadeia de custódia no Brasil',
    'Atuação profissional em Minas Gerais',
    'Estrutura de laudo, parecer e relatório técnico',
    'Escrita científica: introdução e método',
    'Escrita científica: resultados e discussão',
    'Escolha de periódico e submissão científica',
    'Caderno Watts: pesquisa longitudinal',
    'Caderno Hae Min Lee: pesquisa longitudinal',
    'Portfólio, avaliação final e desenvolvimento contínuo',
  ];
  static const volumeEnds = <int>[10,23,39,53,66,78,90,100,113];
  static int volumeFor(int number) {
    if(number<1 || number>volumeEnds.last)throw RangeError.range(number,1,volumeEnds.last);
    return volumeEnds.indexWhere((end)=>number<=end)+1;
  }
  static String chapterId(int number) =>
    'forense.vol' + volumeFor(number).toString().padLeft(2,'0') +
    '.ch' + number.toString().padLeft(2,'0');

  /// Keep bundled identifiers and expose only actual imported chapters.
  static Future<List<StudyChapter>> loadAvailable(OfflineLibrary library) async {
    final bundled=await loadBundledPreviews();
    final entries=<int,StudyChapter>{for(final c in bundled)c.number:c};
    for(final source in library.chapters) {
      final n=source.number;
      if(n<1 || n>volumeEnds.last || source.pageCount<=0)continue;
      final pages=await library.pages(n);
      if(pages.length!=source.pageCount || pages.every((p)=>p.text.trim().isEmpty))continue;
      entries[n]=StudyChapter(
        id:chapterId(n),volume:volumeFor(n),number:n,title:source.title,
        edition:'Importado · fonte original',editorialStatus:'Importado',
        pdfFileId:entries[n]?.pdfFileId??'',sections:entries[n]?.sections??const [],
      );
    }
    return entries.values.toList()..sort((a,b)=>a.number.compareTo(b.number));
  }

  /// Only chapters 01..26 were supplied. Do not fabricate chapters 27 em diante.
  static Future<List<StudyChapter>> loadBundledPreviews() async {
    final chapters = <StudyChapter>[];
    for (var n = 1; n <= 26; n++) {
      final v = n <= 10 ? 1 : (n <= 23 ? 2 : 3);
      final name = 'vol' + v.toString().padLeft(2, '0') +
          '_ch' + n.toString().padLeft(2, '0') + '.json';
      final raw = await rootBundle.loadString('assets/chapters/' + name);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final chapter = StudyChapter.fromMap(data);
      if (chapter.number != n || chapter.volume != v) {
        throw FormatException('Capítulo divergente no pacote: ' + name);
      }
      chapters.add(chapter);
    }
    return chapters;
  }
}
