# Academia Forense — contrato de acervo importável

O APK contém o motor de leitura e estudo. Os materiais privados não precisam ser incorporados ao repositório nem exigem recompilação. O currículo original tem 113 capítulos; capítulos de extensão, quando explicitamente importados, aparecem no grupo complementar. IDs de 1 a 999. Importação manual pelo seletor Android/Google Drive; não há sincronização OAuth automática.

## Pacote ZIP
Schema: academia-forense-offline-pack-v2. Um manifest.json e dois arquivos por capítulo: pdfs/cap_NN.pdf e pages/cap_NN.json. NN usa no mínimo dois dígitos. Limites: 100 MiB de ZIP, 250 MiB descompactados, 124 capítulos por pacote; lotes menores são recomendados. Não incluir caminhos relativos, entradas duplicadas ou arquivos executáveis.

Cada linha de chapters contém chapter, title, pdf, pages, pageCount, sha256 (PDF), pagesSha256 (JSON, obrigatório para layout >= 1), layoutVersion, revision (inteiro não negativo crescente), edition (texto). chapterCount, se presente, precisa coincidir. Importações antigas com REV1, REV2 ou nomes de arquivos continuam aceitas. Revisões menores são ignoradas; PDFs diferentes com revisão explícita igual e positiva são rejeitados. Reimportar layout inferior do mesmo PDF não remove layout superior.

JSON por capítulo: chapter, layoutVersion e pages, com números consecutivos iniciando em 1 e text (texto integral pesquisável). Layout 0: transcrição legada. Layout 1: blocos textuais e visualJpeg (JPEG base64 de página original). Layout 2: inclui os seguintes blocos dentro de layout (cada bloco tem kind e text; text deve representar o conteúdo textual sem perder informações):
- p, h2, h3, h4, small, pre, figcaption: texto e estrutura.
- table: rows, matriz retangular de strings, primeira linha cabeçalho.
- formula: expressão textual Unicode, não exige LaTeX.
- figure: jpeg base64 e text com legenda/descrição.
- exercise, answer, lab, reference: conteúdo didático do autor. Exercícios e gabaritos são recuperados pelo leitor; lab representa instruções, não código executável.
- visualJpeg preserva o original como referência ampliável.

Sempre gerar PDF e JSON a partir da mesma fonte editorial. A versão digital não autoriza resumir a fonte. Não declarar equivalência visual/semântica sem inspeção e testes. Referências e fórmulas de alta complexidade ainda podem exigir PDF. Os capítulos não são aprovados cientificamente pelo importador.

## Critérios de entrega
- Importar pacote antigo e estruturado; rejeitar arquivo adulterado.
- Ler offline e ajustar contraste e fonte; abrir figuras.
- Buscar texto dos capítulos e navegar à origem.
- Manter trechos e notas ao atualizar. Avisar quando trecho não puder ser reencontrado.
- Importar novo capítulo sem recompilar.
- Executar flutter analyze, flutter test e flutter build apk --release --target-platform android-arm64. Publicar APK somente após aprovação. Teste real no Galaxy A57 separado.
