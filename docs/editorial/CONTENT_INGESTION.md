# Guia Editorial e Motor de Ingestão Incremental — Academia Forense

**Data:** 16/11/2026  
**Fonte Oficial Google Drive:** `19tpPVsKlmoXpRY9TwsNK8j-VpMfsLKys` (`https://drive.google.com/drive/folders/19tpPVsKlmoXpRY9TwsNK8j-VpMfsLKys`)

---

## 1. Inventário Real do Google Drive (§1 e §3)

A pasta oficial da **Enciclopédia de Ciências Forenses — Formação e Pesquisa** foi integralmente percorrida e inventariada (`content/drive_source_docs/drive_full_inventory.json`, totalizando **165 itens**, dos quais **103 arquivos canônicos** foram verificados byte a byte com hash SHA-256 em `content/drive_source_docs/canonical_files_verified.json`).

### Distribuição Oficial em 9 Volumes e 113 Capítulos (`INDICE_MESTRE_ENCICLOPEDIA_CIENCIAS_FORENSES_V1_2026.pdf`)

| Volume | Capítulos | Área Temática | Status Atual no Drive | Páginas / Artefatos Reais |
|---|---|---|---|---|
| **Volume I** | 1 a 10 | Fundamentos das Ciências Forenses | **Disponível / Publicado (10 cap.)** | **133 páginas impressas** (Cap. 1–4 em `REV2` = 68 pág.; Cap. 5–10 em `REV1` = 65 pág.) + lab `analise_farol27.py` e CSVs |
| **Volume II** | 11 a 23 | Computação, Python, SQL e Matemática | **Em revisão / Importado (13 cap. `ED1`)** | **131 páginas A4** (Cap. 11 a 23 completos em PDF + scripts `.py`, `.ps1`, `.sh`, `.sql` e CSVs sintéticos) |
| **Volume III** | 24 a 39 | Estatística e Ciência de Dados Forense | **3 Em revisão (Cap. 24–26 `ED1`) + 13 Previstos (Cap. 27–39)** | **28 páginas A4** (Cap. 24: 9p, Cap. 25: 9p, Cap. 26: 10p + fontes `.md`, figuras `.png` e scripts `.py`) |
| **Volume IV** | 40 a 53 | Perícia Digital em Sistemas, Dispositivos e Redes | **Previsto (14 cap.)** | Planejado no Índice Mestre |
| **Volume V** | 54 a 66 | Telefonia, Geolocalização e Análise de Vínculos | **Previsto (13 cap.)** | Planejado no Índice Mestre |
| **Volume VI** | 67 a 78 | Linguística Forense, Análise de Depoimentos e NLP | **Previsto (12 cap.)** | Planejado no Índice Mestre |
| **Volume VII** | 79 a 90 | Documentoscopia Digital, Áudio, Imagem, Vídeo e Autenticação | **Previsto (12 cap.)** | Planejado no Índice Mestre |
| **Volume VIII** | 91 a 100 | Áreas Forenses Complementares e Integração Multidisciplinar | **Previsto (10 cap.)** | Planejado no Índice Mestre |
| **Volume IX** | 101 a 113 | Pesquisa Aplicada, Estudos de Caso, Laudos e Exercício Profissional | **Previsto (13 cap.)** | Planejado no Índice Mestre |

### Regras Editoriais e Exclusões Canônicas Aplicadas (§1.3 e §24)
- **`99_Arquivo_Antigo_NAO_IMPRIMIR` (Ignorado para publicação)**: Contém 9 PDFs antigos (`REV1` ou rascunhos sem sufixo dos capítulos 1 a 4) e 1 cópia duplicada da auditoria. Nenhum arquivo desta pasta foi publicado.
- **`00_PDFs_Reunidos_Para_Imprimir` (Tratado como agregação)**: Contém 7 cadernos reunidos para impressão (`MIOLO_VOLUME_I_COMPLETO_133_PAGINAS.pdf`, blocos `C11_C13`, `C14_C16`, `C17_C19`, `C20_C23`, `VOLUME_II_COMPLETO_C11_A_C23_ED1.pdf` e `VOLUME_III_PARCIAL_C24_A_C26_ED1.pdf`). São registrados como agregações de impressão e não duplicam capítulos no catálogo.
- **Preservação do Volume I Impresso (133 páginas)**: Os capítulos 1 a 10 já foram impressos pelo proprietário. As observações da `AUDITORIA_TECNICA_CAPITULOS_1_A_4_2026.pdf` e do `Controle_Qualidade_Impresso_VolI_1a4_2026-11-12.pdf` (Achados **A1, A2, A3, A4 e V1**) estão vinculadas digitalmente em `content/fixtures/volume_01/vol01_errata.json`, sem exigir reimpressão física.

---

## 2. Pipeline de Sincronização Incremental em 10 Estágios (`packages/drive_sync`)

Quando novos capítulos (ex.: Capítulos 27 a 113 ou arquivos nas pastas `Caso_Hae_Min_Lee_1999` e `Caso_Watts_2018`) são adicionados ao Google Drive ou importados localmente:

1. **Detecção**: Identifica arquivos novos ou modificados via API Google Drive (`drive.readonly`) ou diretório local.
2. **Classificação de Caminho**: Determina volume, capítulo ou projeto de pesquisa e filtra pastas arquivadas (`99_Arquivo_Antigo_NAO_IMPRIMIR`) e agregações (`00_PDFs_Reunidos_Para_Imprimir`).
3. **Deduplicação Criptográfica**: Calcula o hash **SHA-256** do binário e evita reprocessamento de arquivos idênticos.
4. **Extração Estruturada**: Extrai texto, seções, tabelas, referências, scripts de laboratório e metadados.
5. **Associação Curricular**: Vincula ao identificador estável `forense.volXX.chYY` do manifesto de 113 capítulos.
6. **Classificação Editorial**: Atribui revisão (`REV1`, `REV2`, `ED1`) e status (`Planejado`, `Importado`, `Em revisão`, `Aprovado`, `Publicado`, `Substituído`, `Arquivado`).
7. **Validação de Schema (§19)**: Valida todos os campos obrigatórios contra `content/schemas/section_19_schema.json`.
8. **Prévia Editorial**: Gera resumo de pré-visualização antes da publicação.
9. **Barreira de Publicação**: Publica automaticamente apenas materiais aprovados; materiais sem auditoria concluída entram como `Em revisão`.
10. **Migração Não-Destrutiva (§2.2)**: Preserva anotações (migrando por `anchorKey` ou marcando `isOrphaned = true`), destaques, favoritos, posição de leitura, notas de avaliações e submissões de laboratório.
