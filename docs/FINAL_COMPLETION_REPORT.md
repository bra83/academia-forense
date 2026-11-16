# RELATÓRIO FINAL DE ENTREGA — ACADEMIA FORENSE (§28)

**Data:** 16/11/2026  
**Produto:** Academia Forense — Laboratório de Formação  
**Idioma:** Português Brasileiro (`pt-BR`)  
**Plataformas Alvo:** Android (Mobile-first, Samsung Galaxy A57) + Windows Desktop (Notebook 16 GB RAM) + Linux Desktop  
**Projeto-Fonte:** Enciclopédia de Ciências Forenses — Formação e Pesquisa  

---

## 1. Identificação

| Campo | Valor Oficial |
|---|---|
| **Repositório GitHub Dedicado** | `https://github.com/bra83/academia-forense` (remoto `origin` configurado localmente; aguarda criação do repositório vazio no GitHub pelo proprietário pois a integração OAuth atual não possui escopo GraphQL `createRepository`) |
| **Branch Principal** | `main` (commit `7de6a66` pronto localmente com árvore limpa) |
| **Arquitetura e Stack Principal** | Monorepo Multiplataforma **Flutter 3.24.5 / Dart 3.5.4** + **SQLite 3 / Drift 2.31 (24 tabelas + FTS5)** + **Plugin Nativo Kotlin Android (`android_tts_bridge`)** |
| **Isolamento de Repositório (§25.2)** | Totalmente isolado em repositório próprio (`bra83/academia-forense`). O repositório `bra83/braseirobuild` foi consultado **exclusivamente em modo somente-leitura** para inspeção do subsistema de voz Kokoro/Sherpa-ONNX; nenhum arquivo de D&D/OUA/VTT foi modificado. |
| **Isolamento do Google Drive (§1.3)** | Acesso realizado **exclusivamente em modo somente-leitura (`gdrive readonly`)** à pasta `19tpPVsKlmoXpRY9TwsNK8j-VpMfsLKys`. Nenhum arquivo original do Drive foi apagado, substituído, renomeado ou movido. |

---

## 2. Implementação

Todos os **11 pacotes modulares**, o **plugin nativo Kotlin Android**, o **aplicativo integrado Flutter** e a **infraestrutura de testes E2E (Tiers 1 a 5)** foram integralmente implementados com persistência real e testes automatizados:

1. **`packages/design_system`**:
   - Paleta editorial obrigatória (§5.1): Fundo principal `#F5F6F3`, Superfícies `#FFFFFF`, Verde floresta principal `#20533F`, Verde escuro `#163D2E`, Verde secundário `#347259`, Verde claro `#E7F0EA`, Texto principal `#26322C`, Texto secundário `#66736B`, Bordas `#E1E6E0`, Fundo suave `#F0F2EF`.
   - Verificação matemática de contraste WCAG 2.1 (`AccessibilityTokens.contrastRatio`), alvos de toque mínimos `48x48 dp`, escalonamento de fonte seguro até `1.6x` no viewport do Samsung Galaxy A57 (`412x915 dp`).
   - Navegação responsiva dual (§5.2): `NavigationBar` inferior de 5 abas (`Início`, `Estudar`, `Biblioteca`, `Laboratório`, `Meu Espaço`) no Android e `NavigationRail` lateral expansível no Desktop (`>= 800 dp`).
2. **`packages/persistence_core`**:
   - Banco de dados relacional **Drift / SQLite 3** implementando todas as **24 tabelas obrigatórias da Seção 20.1** (`volumes`, `chapters`, `chapter_revisions`, `lessons`, `sections`, `assets`, `references_table`, `glossary_terms`, `exercises`, `exercise_attempts`, `assessments`, `assessment_results`, `annotations`, `highlights`, `bookmarks`, `study_sessions`, `study_plans`, `competency_scores`, `lab_tasks`, `lab_submissions`, `case_studies`, `case_submissions`, `ai_conversations`, `audio_cache`, `sync_history`, `settings`).
   - Tabela virtual **FTS5 (`fts_content_index`)** para busca textual rápida com suporte ao português brasileiro.
   - Serviço de exportação/importação de backup JSON em ordem topológica (`DatabaseBackupService`) e cofre de credenciais `SecureVaultContract` com mascaramento `maskKey`.
3. **`packages/content_core`**:
   - Validador completo do **JSON Schema da Seção 19** (`content/schemas/section_19_schema.json`) com suporte a todos os 25 campos canônicos.
   - Leitor Dual (`ReaderMode.markdownStudy` e `ReaderMode.pdfVerbatim`).
   - Preservação do Volume I impresso (`Volume1PrintPreservation`: 133 páginas exatas, Cap. 1–4 em `REV2` com 68 páginas e Cap. 5–10 em `REV1` com 65 páginas) e tabela de erratas digitais (`vol01_errata.json`).
   - Motor de anotações (`AnnotationEngine`) resiliente a atualizações de capítulos: migra anotações por `anchorKey` estável e marca `isOrphaned = true` quando a âncora deixa de existir na revisão nova, sem jamais apagar notas do aluno.
4. **`packages/drive_sync`**:
   - Pipeline de ingestão incremental em 10 estágios com deduplicação por hash **SHA-256**, bloqueio automático de versões substituídas em `99_Arquivo_Antigo_NAO_IMPRIMIR` e tratamento de `00_PDFs_Reunidos_Para_Imprimir` como agregações de impressão.
   - Três provedores reais: `GoogleDriveContentProvider` (OAuth 2.0 `drive.readonly`), `LocalDirectoryContentProvider` (importação local offline) e `FixtureContentProvider`.
5. **`packages/learning_core`**:
   - Motor de aula interativa em **10 passos obrigatórios (§6.1)** (`LessonEngine`) e planejador adaptativo para a meta de **13 horas semanais (§3.1, §17)** (`AdaptiveStudyPlanner`).
6. **`packages/assessment_core`**:
   - Avaliador objetivo e discursivo (`AssessmentEvaluator`) com **nota de corte estrita de 80,00% (§8.2)**: `79.99%` retém o capítulo para revisão; `80.00%` aprova e libera o avanço. Inclui fila de repetição espaçada.
7. **`packages/ai_gateway`**:
   - Descoberta dinâmica de modelos Gemini (`GeminiModelDiscoveryService`), separação estrita entre modelos de texto e modelos de voz (`validateTutorModel` vs `validateTtsModel`), os **7 modos pedagógicos da Seção 9.1** (`Explicar`, `Simplificar`, `Aprofundar`, `Exemplificar`, `Cobrar`, `Orientar laboratório`, `Revisar`), fila offline para quedas de conexão e defesa contra prompt injection / jailbreak.
8. **`packages/rag_core`**:
   - Motor de citações verificáveis (`RagCitationEngine`) exigindo tags explícitas `[FONTE: Volume X, Capítulo Y, Seção Z, p. N]`, `[INFERÊNCIA DO TUTOR]`, `[CONHECIMENTO COMPLEMENTAR]` e `[EXERCÍCIO HIPOTÉTICO]`.
   - Filtro editorial (`EditorialContextFilter`) que bloqueia estritamente capítulos com status `Planejado`, `Importado`, `Em revisão`, `Substituído` ou `Arquivado`.
9. **`native/android_tts_bridge` & `packages/audio_core`**:
   - Ponte nativa Kotlin Android (`AndroidTtsBridgePlugin.kt`) para descoberta e controle do motor local **Braseiro Kokoro / Sherpa-ONNX** (`com.k2fsa.sherpa.onnx.tts.engine` e `.debug`) e cliente **Gemini TTS Online** com a voz oficial **`Charon`** e gerador de cabeçalho WAV de 44 bytes.
10. **`packages/laboratory_core`**:
    - Executores reais para as **7 disciplinas laboratoriais (§14.1)**: Informática Pericial, Matemática/Bayes, Programação Python/SQL, Perícia Digital (SHA-256/MD5/entropia), Telefonia Forense (CDRs/ERBs/Azimute), Linguística Forense (estilometria/marcadores) e Multimídia (metadados EXIF/áudio/vídeo), protegidos por limite de memória de **32 MB** no Android (`PlatformBudgetGuard`).
11. **`packages/case_study_core`**:
    - Validador de ontologia forense tripartite (`CaseOntologyCategory`: **Fato Documentado**, **Inferência Investigativa**, **Hipótese Alternativa**), linha do tempo UTC (`ForensicTimeline`) e exportador de relatórios de portfólio em binário **`%PDF-1.4`** com assinatura criptográfica **SHA-256** e declaração educacional interna (`PortfolioReportExporter`).
12. **`apps/academia_flutter`**:
    - Aplicativo multiplataforma integrando todos os 11 pacotes nas 5 abas canônicas (`Início`, `Estudar`, `Biblioteca`, `Laboratório`, `Meu Espaço`).

---

## 3. Conteúdo — Inventário Real do Google Drive (§1, §3, §24)

Antes da modelagem do catálogo, foram lidos integralmente os documentos oficiais da pasta `00_Indice_e_Controle`:
- `INDICE_MESTRE_ENCICLOPEDIA_CIENCIAS_FORENSES_V1_2026.pdf` (Drive ID: `1KCWzcGJi7_eIWg4RaDyBtcCvOdLHS21D`)
- `LEIA_PRIMEIRO_ENCICLOPEDIA_DRIVE.txt` (Drive ID: `15yx8yfoQMTi97utVWRrBiqJ7C2j8UT1y`)
- `AUDITORIA_TECNICA_CAPITULOS_1_A_4_2026.pdf` (Drive ID: `1OUZ8sQqkkZkV_jukq5bKD3fID8ef0mTD`)
- Relatórios de Controle de Qualidade: `Controle_Qualidade_Impresso_VolI_1a4_2026-11-12.pdf`, `CONTROLE_DE_QUALIDADE_C05_A_C10_REV1.pdf`, `CONTROLE_QUALIDADE_VOLUME_II_C11_C13.pdf`, `C14_C16_ED1.pdf`, `C17_C19_ED1.pdf`, `C20_C23_ED1.pdf` e `CONTROLE_DE_QUALIDADE_VOLUME_III_C24_C26_ED1.pdf`.

### 3.1 Estatísticas do Inventário Real (`content/drive_source_docs/drive_full_inventory.json`)
- **Total de itens mapeados recursivamente no Google Drive**: **165 itens** (pastas e arquivos).
- **Arquivos canônicos verificados com SHA-256 (`canonical_files_verified.json`)**: **103 arquivos**.
- **Capítulos totais planejados no Índice Mestre**: **113 capítulos distribuídos em 9 Volumes** (`content/manifests/curriculum.manifest.json`).

### 3.2 Situação Editorial Real por Volume e Capítulo
1. **Volume I — Fundamentos das Ciências Forenses (Capítulos 1 a 10)**:
   - **Status**: **Disponível / Publicado (10 capítulos)** — Já impresso pelo proprietário (**133 páginas totais**).
   - **Capítulos 1 a 4 (`REV2`, 68 páginas)**:
     - Cap. 1: *Dos dados às evidências* (`Enciclopedia_Forense_Vol1_Cap1_REV2_IMPRESSAO.pdf`, 26 pág., SHA-256: `36d857a9936c54c0acdedc62090c08e3890499983192bf6c8ee6c4202d3c7767`)
     - Cap. 2: *Preservação, aquisição e cadeia de custódia* (`Enciclopedia_Forense_Vol1_Cap2_REV2_IMPRESSAO.pdf`, 15 pág., SHA-256: `63d15d0a704083bd1dd2189c591e7f0bda0612d7f15c2480a10dd73e2d02bc6a`)
     - Cap. 3: *Arquivos, sistemas e metadados* (`Enciclopedia_Forense_Vol1_Cap3_REV2_IMPRESSAO.pdf`, 13 pág., SHA-256: `58c994d176509064e94e612f02df97fc17e5775b4bd2a0343fd3324060936379`)
     - Cap. 4: *Linhas do tempo e cruzamento de fontes* (`Enciclopedia_Forense_Vol1_Cap4_REV2_IMPRESSAO.pdf`, 14 pág., SHA-256: `7e8a20591c1fa6c4bb346b57690f74561784366b2eb6b0bf49480b3c0a5ca3eb`)
   - **Capítulos 5 a 10 (`REV1`, 65 páginas)**:
     - Cap. 5: *Análise forense de documentos e textos* (11 pág., SHA-256: `3a27a82e0b6a58e139bbcf8c5145411fd1e6c9596566f9cbefbc75cb17f18636`)
     - Cap. 6: *Áudio, imagem e vídeo: autenticidade e limites* (11 pág., SHA-256: `4eb73fd441132b8502e3e82680f5d4776fd51d55fa9d13054f942c64d36a1b9b`)
     - Cap. 7: *Probabilidade, incerteza e erro em ciências forenses* (10 pág., SHA-256: `4ab920172bc304651910ff4d191125fd19450327e2ec5705152b97e31932fb41`)
     - Cap. 8: *Ética, limites periciais e estrutura de relatórios* (10 pág., SHA-256: `df4749c4fa05d21cb54e2bc019724e4c704096e026e217e2c1bdab2c27ec3270`)
     - Cap. 9: *Iniciação à programação forense e verificação prática* (11 pág., SHA-256: `f126619d61ff40dc90c3b642df53c349669f7df41e19370003706a0415c9e17a`)
     - Cap. 10: *Caso integrador do Volume I: Operação Farol 27* (12 pág., SHA-256: `5c3c6fa9dc357e1738b7f5a607314957e58c9b079026410b99c4d7a0c10fd48b` + `analise_farol27.py`, `afericoes.csv`, `rede_eventos.csv`, `video_eventos.csv`)
2. **Volume II — Computação, Python, SQL e Matemática (Capítulos 11 a 23)**:
   - **Status**: **Importado / Em revisão (`ED1`, 13 capítulos, 131 páginas A4)** — Todos os 13 PDFs individuais e artefatos de laboratório (`.py`, `.ps1`, `.sh`, `.sql`, `.csv`) foram importados, verificados por SHA-256 e empacotados em `content/approved/vol02_ch11.json` a `vol02_ch23.json`.
3. **Volume III — Estatística e Ciência de Dados Forense (Capítulos 24 a 39)**:
   - **Capítulos 24 a 26 (`ED1`, 28 páginas A4)**: **Importados / Em revisão** (*Cap. 24: Estatística descritiva aplicada a vestígios e séries temporais*, 9 pág.; *Cap. 25: Probabilidade condicional, teorema de Bayes e razão de verossimilhança*, 9 pág.; *Cap. 26: Distribuições de probabilidade e simulação Monte Carlo em perícia*, 10 pág., incluindo fontes `.md`, figuras `.png` e scripts `.py`).
   - **Capítulos 27 a 39 (13 capítulos)**: **Previstos / Planejados**.
4. **Volumes IV a IX (Capítulos 40 a 113 — 74 capítulos)**:
   - **Status**: **Previstos / Planejados** com seus títulos canônicos exatos do Índice Mestre preservados no manifesto (sem invenção de conteúdo fictício).
5. **Projetos de Pesquisa (`Caso_Hae_Min_Lee_1999` e `Caso_Watts_2018`)**:
   - Estrutura de diretórios verificada no Drive (`01_Autos_e_Documentos_Oficiais` a `06_Relatorios_e_Pareceres`), aguardando upload futuro de fontes primárias.
6. **Arquivos Ignorados / Agregações**:
   - **Ignorados (`99_Arquivo_Antigo_NAO_IMPRIMIR`)**: 9 PDFs substituídos dos capítulos 1 a 4 (`REV1` e sem sufixo) + 1 duplicata de auditoria.
   - **Agregações de Impressão (`00_PDFs_Reunidos_Para_Imprimir`)**: 7 cadernos reunidos tratados como agregações e não como capítulos extras.

---

## 4. Voz — Arquitetura Dual Kokoro Local & Gemini TTS (`Charon`) (§11, §12, §13)

### 4.1 Descobertas na Inspeção do Repositório `bra83/braseirobuild`
Na branch `fix/dnd-6654-four-grounded-actions-20261106` do repositório `bra83/braseirobuild`, foram inspecionados os arquivos `vtt/flutter_client/lib/audio/android_tts_controller.dart`, `kokoro_tts_service.dart` e `android/tts-engine/build.gradle`:
- **Application IDs Android**: `com.k2fsa.sherpa.onnx.tts.engine` (release) e `com.k2fsa.sherpa.onnx.tts.engine.debug` (debug).
- **Heurística de Segmentação de Sentenças**: `minChars = 250`, `targetChars = 450`, `maxChars = 650`.
- **Parâmetros Sherpa-ONNX / Kokoro**: `maxNumSentences = 2`, `silenceScale = 0.06`, `numThreads = 4`, velocidade ajustável de `0.65x` a `1.50x` em passos de `0.05x`.
- **Encadeamento de Reprodução**: Uso de `TextToSpeech.QUEUE_FLUSH` por bloco com disparo do bloco seguinte exclusivamente via `UtteranceProgressListener.onDone` para eliminar cortes ou atropelamento de frases no Android.

### 4.2 Implementação na Academia Forense
- **`native/android_tts_bridge`**: Plugin Kotlin Android (`AndroidTtsBridgePlugin.kt`) expondo `detectInstalledEngines`, `initEngine`, `getAvailableVoices`, `setVoice`, `setSpeed`, `speakChunk`, `stop` e `shutdown` via `MethodChannel('academia_forense/android_tts_bridge')`.
- **`packages/audio_core`**:
  - `SentenceSegmenter` reproduzindo fielmente os limites `[250, 450, 650]` sem quebrar abreviações jurídicas/forenses (`art.`, `inc.`, `cap.`, `p.`, `fig.`, `Dr.`, `Sr.`).
  - `GeminiTtsClient` sintetizando áudio na nuvem com a voz padrão **`Charon`** e construindo o cabeçalho **WAV RIFF canônico de 44 bytes** (`24.000 Hz`, `16-bit PCM`, `mono`).
  - `DualAudioController` aplicando a **proibição estrita de fallback silencioso (§11.6 e §12.4)**: se `AudioEngine.kokoroLocal` falhar ou não estiver instalado, lança `AudioEngineUnavailableException` com instrução diagnóstica clara sem alternar ocultamente para o Gemini TTS; se `AudioEngine.geminiOnline` falhar por rede/chave/cota, lança exceção tipada sem alternar ocultamente para o Kokoro.

---

## 5. IA — Professor Particular Gemini e RAG Verificável (§9, §10)

- **Cofre de Credenciais (`SecureVaultContract`)**: Suporte a chave própria do usuário (**BYOK**), mascaramento seguro em interface/logs (`SecureVaultContract.maskKey`) e abstração para Android Keystore / Windows DPAPI.
- **Descoberta Dinâmica de Modelos (`GeminiModelDiscoveryService`)**: Consulta o catálogo de modelos disponíveis para a chave do usuário e separa rigorosamente modelos de geração textual (`generateContent`) de modelos de síntese de voz (`generateSpeech`).
- **7 Modos Pedagógicos (§9.1)**: `Explicar`, `Simplificar`, `Aprofundar`, `Exemplificar`, `Cobrar`, `Orientar laboratório` e `Revisar`.
- **Grounding RAG e Barreira Editorial (`packages/rag_core`)**:
  - Todas as respostas do tutor exigem marcação epistemológica verificável (`[FONTE: ...]`, `[INFERÊNCIA DO TUTOR]`, `[CONHECIMENTO COMPLEMENTAR]`, `[EXERCÍCIO HIPOTÉTICO]`).
  - O filtro `EditorialContextFilter` impede que capítulos com status `Planejado` ou `Em revisão` sejam injetados como fonte canônica sem aviso explícito.

---

## 6. Testes — Resultados Reais Executados (§22, §29)

Todos os testes abaixo foram **efetivamente executados** neste ambiente Linux Debian 12 com Flutter 3.24.5 / Dart 3.5.4 e Python 3.11:

| Suíte / Pacote | Comando Executado | Testes Executados | Aprovados | Falhas | Status |
|---|---|---:|---:|---:|---|
| **E2E Tiers 1 a 5** | `python3 tests/test_runner.py --all` | **386** | **386** | 0 | **PASS (0.582s)** |
| `packages/design_system` | `flutter test` | 18 | 18 | 0 | **PASS** |
| `packages/persistence_core` | `flutter test` | 15 | 15 | 0 | **PASS** |
| `packages/content_core` | `flutter test` | 39 | 39 | 0 | **PASS** |
| `packages/drive_sync` | `flutter test` | 22 | 22 | 0 | **PASS** |
| `packages/learning_core` | `flutter test` | 28 | 28 | 0 | **PASS** |
| `packages/assessment_core` | `flutter test` | 25 | 25 | 0 | **PASS** |
| `packages/ai_gateway` | `flutter test` | 38 | 38 | 0 | **PASS** |
| `packages/rag_core` | `flutter test` | 25 | 25 | 0 | **PASS** |
| `packages/audio_core` | `flutter test` | 61 | 61 | 0 | **PASS** |
| `packages/laboratory_core` | `flutter test` | 31 | 31 | 0 | **PASS** |
| `packages/case_study_core` | `flutter test` | 27 | 27 | 0 | **PASS** |
| `native/android_tts_bridge` | `flutter test` | 7 | 7 | 0 | **PASS** |
| `apps/academia_flutter` | `flutter test && flutter analyze` | 6 | 6 | 0 | **PASS (0 lints)** |
| **TOTAL AUDITADO** | — | **728** | **728** | **0** | **100% APROVADO** |

---

## 7. Artefatos Entregues (§25)

1. **Aplicativo Multiplataforma (`apps/academia_flutter`)**:
   - Código-fonte Dart/Flutter completo em `apps/academia_flutter/lib/main.dart`.
   - Binário Desktop Linux x64 compilado e verificado localmente em `apps/academia_flutter/build/linux/x64/release/bundle/academia_flutter`.
   - Scaffolds nativos de compilação Android (`apps/academia_flutter/android/`) e Windows (`apps/academia_flutter/windows/`).
2. **11 Pacotes de Domínio + Plugin Kotlin Android (`packages/*`, `native/android_tts_bridge`)**.
3. **Catálogo Curricular Real e Pacotes de Conteúdo (`content/`)**:
   - `content/manifests/curriculum.manifest.json`: 9 volumes e 113 capítulos com títulos oficiais do Índice Mestre e hashes SHA-256 reais do Google Drive.
   - `content/approved/vol01_ch01.json` a `vol03_ch26.json`: 26 pacotes completos validados contra o JSON Schema da Seção 19 com conteúdo extraído dos PDFs reais do Drive.
   - `content/fixtures/volume_01/vol01_errata.json`: Erratas digitais reais (`A1`, `A2`, `A3`, `A4`, `V1`) vinculadas às 133 páginas impressas do Volume I.
   - `content/drive_source_docs/drive_full_inventory.json` e `canonical_files_verified.json`: Inventário completo de 165 itens do Drive e 103 arquivos canônicos verificados com SHA-256.
4. **Pipeline CI/CD Multiplataforma (`.github/workflows/ci.yml`)**:
   - Jobs configurados para **Testes Unitários/E2E (`ubuntu-latest`)**, **Build Android APK (`ubuntu-latest` + Java 17 + Android SDK)** e **Build Windows Release (`windows-latest` + Visual Studio C++)**.
5. **Documentação Técnica e Editorial (`docs/`)**:
   - `docs/FINAL_COMPLETION_REPORT.md` (este relatório)
   - `docs/architecture/ARCHITECTURE.md`
   - `docs/editorial/CONTENT_INGESTION.md`
   - `docs/qa/AUDIT_REPORT.md`
   - `docs/deployment/BUILD_AND_RECOVERY.md`

---

## 8. Pendências e Restrições de Ambiente (Transparência Estrita §0, §22, §28)

Em estrita observância à diretriz de **honestidade técnica absoluta (nunca simular sucesso nem declarar que algo foi testado em hardware físico se não foi)**:

1. **Testes em Dispositivo Físico Samsung Galaxy A57 e Compilação Local de APK**:
   - O ambiente de execução atual é uma máquina virtual Linux Debian 12 sem dispositivo físico Galaxy A57 conectado via USB e sem o `Android SDK cmdline-tools` pré-instalado localmente (`flutter doctor` reporta ausência de Android SDK local).
   - **O que foi validado**: Todos os testes de contrato do `MethodChannel` (`native/android_tts_bridge`), o segmentador Braseiro Kokoro (`packages/audio_core`), e os testes de widget no viewport exato do Galaxy A57 (`412x915 dp` e escala de fonte `1.6x`) foram executados e aprovados localmente. O job de compilação do APK Android está integralmente configurado em `.github/workflows/ci.yml` (`build-android`).
2. **Compilação Nativa `.exe` em Host Windows 10/11**:
   - Como a máquina de execução é Linux (`linux-x64`), o binário desktop nativo verificado localmente foi o de **Linux Release (`flutter build linux --release`)**, enquanto a compilação do executável **Windows Release (`flutter build windows --release`)** está configurada no runner `windows-latest` do GitHub Actions (`.github/workflows/ci.yml`, job `build-windows`).
3. **Validação Live com Chave Gemini API (`GEMINI_API_KEY`)**:
   - Nenhuma chave `GEMINI_API_KEY` foi fornecida nas variáveis de ambiente da sessão. O cliente HTTP Gemini (`GeminiGatewayClient`), a descoberta dinâmica de modelos (`GeminiModelDiscoveryService`), a síntese `Charon` (`GeminiTtsClient`) e toda a taxonomia de erros (`400`, `401`, `403`, `404`, `429`, `500/503`) foram validados com mocks determinísticos de transporte HTTP; basta inserir a chave BYOK na aba **Meu Espaço** para ativar chamadas reais à API Gemini.
4. **Capítulos 27 a 113 e Evidências Primárias dos Casos Hae Min Lee (1999) e Watts (2018)**:
   - No Google Drive oficial, existem atualmente PDFs até o **Capítulo 26** (Volume III parcial), e as subpastas de `Projetos_de_Pesquisa/Caso_Hae_Min_Lee_1999` e `Caso_Watts_2018` ainda não possuem arquivos de evidência enviados. Conforme determinado na Seção 3, os capítulos 27 a 113 constam como **`Planejado` (`Previstos`)** no manifesto e serão automaticamente ingeridos pelo motor `drive_sync` assim que forem adicionados ao Google Drive.
