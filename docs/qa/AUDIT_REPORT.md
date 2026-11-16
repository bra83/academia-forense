# Relatório de Qualidade e Auditoria Automatizada — Academia Forense

**Data:** 16/11/2026  
**Status Global:** 100% Aprovado (Zero Falhas, Zero Erros, Zero Avisos do Analyzer)

---

## 1. Resumo Consolidado da Execução de Testes

| Camada de Teste | Escopo | Total de Testes | Aprovados | Falhas / Erros | Tempo de Execução |
|---|---|---:|---:|---:|---:|
| **E2E Tiers 1 a 5 (Python Harness)** | `tests/test_runner.py --all` (Features F1–F28, Fronteiras, Pairwise, Cenários e Auditoria Adversarial) | **386** | **386** | 0 | `0.582s` |
| **Flutter / Dart Unit & Adversarial (`packages/*`)** | 11 pacotes de domínio + `native/android_tts_bridge` | **336** | **336** | 0 | `~10.5s` |
| **Flutter Widget & Integration (`apps/academia_flutter`)** | Navegação responsiva Mobile/Desktop, Avaliação 80%, Kokoro TTS, Tutor RAG, Biblioteca/Erratas, Laboratórios e PDF Assinado | **6** | **6** | 0 | `~2.4s` |
| **TOTAL GERAL VERIFICADO** | **Suíte Completa Automatizada** | **728** | **728** | **0** | **`~13.5s`** |

---

## 2. Detalhamento por Pacote Dart / Flutter

1. **`packages/design_system` (18 testes)**: Paleta obrigatória `#F5F6F3` / `#20533F` / `#163D2E`, cálculo exato de luminância relativa WCAG 2.1, alvos mínimos `48x48 dp`, escalonamento de fonte `1.6x` no viewport do Samsung Galaxy A57 (`412x915 dp`) e alternância entre `NavigationBar` (mobile) e `NavigationRail` (desktop).
2. **`packages/persistence_core` (15 testes)**: Criação das 24 tabelas SQLite + índice virtual FTS5, migrações não-destrutivas, backup/restauração JSON em ordem topológica, e cofre `SecureVaultContract` com mascaramento `maskKey`.
3. **`packages/content_core` (39 testes)**: Validação do JSON Schema da Seção 19, leitor dual (`ReaderMode.markdownStudy` / `ReaderMode.pdfVerbatim`), preservação das 133 páginas impressas do Volume I (`REV2` Cap. 1–4 e `REV1` Cap. 5–10), erratas digitais `A1–A4` e proteção de anotações órfãs (`isOrphaned = true`).
4. **`packages/drive_sync` (22 testes)**: Provedores `GoogleDriveContentProvider`, `LocalDirectoryContentProvider` e `FixtureContentProvider`, deduplicação por hash SHA-256, bloqueio de `99_Arquivo_Antigo_NAO_IMPRIMIR` e tratamento de `00_PDFs_Reunidos_Para_Imprimir`.
5. **`packages/learning_core` (28 testes)**: Motor de aula interativa em 10 etapas canônicas e planejador adaptativo para meta semanal de 13 horas.
6. **`packages/assessment_core` (25 testes)**: Nota de corte estrita de **80,00%** (testes de fronteira em `79.99%` reprovado vs `80.00%` aprovado), rubricas discursivas e fila de repetição espaçada.
7. **`packages/ai_gateway` (38 testes)**: Descoberta dinâmica de modelos Gemini, separação estrita entre modelos de texto e modelos de voz, 7 modos pedagógicos, taxonomia de erros HTTP (`400`, `401`, `403`, `404`, `429`, `500/503`), fila offline e bloqueio de prompt injection / jailbreak.
8. **`packages/rag_core` (25 testes)**: Citações obrigatórias `[FONTE: ...]`, `[INFERÊNCIA DO TUTOR]`, `[CONHECIMENTO COMPLEMENTAR]` e `[EXERCÍCIO HIPOTÉTICO]`, e bloqueio estrito de capítulos com status `Planejado`, `Importado`, `Em revisão`, `Substituído` ou `Arquivado`.
9. **`packages/audio_core` (61 testes) + `native/android_tts_bridge` (7 testes)**: Segmentador de sentenças Braseiro (`min: 250`, `target: 450`, `max: 650` caracteres), encadeamento `onDone`, parâmetros Sherpa-ONNX Kokoro (`maxNumSentences: 2`, `silenceScale: 0.06`, `numThreads: 4`), geração de cabeçalho WAV RIFF de 44 bytes para PCM 24kHz 16-bit mono da voz `Charon`, e proibição de fallback silencioso entre Kokoro Local e Gemini Online.
10. **`packages/laboratory_core` (31 testes)**: 7 domínios laboratoriais (Informática, Matemática/Bayes, Python/SQL, Perícia Digital SHA-256/MD5, Telefonia CDR/ERB, Linguística Forense e Multimídia EXIF) e trava de orçamento de memória de **32 MB** para o Samsung Galaxy A57.
11. **`packages/case_study_core` (27 testes)**: Ontologia tripartite (Fato Documentado, Inferência Investigativa, Hipótese Alternativa), linha do tempo UTC e exportador de relatórios de portfólio em binário `%PDF-1.4` com assinatura criptográfica SHA-256 e declaração de uso educacional interno.
