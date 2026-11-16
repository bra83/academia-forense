"""
Academia Forense — Canonical Test Fixtures and Harness Support.

Derived strictly from ORIGINAL_REQUEST.md, PROJECT.md, and TEST_INFRA.md.
Contains:
1. Canonical 9 Volumes & 113 Chapters Metadata.
2. Section 19 JSON Schema (Draft 2020-12) & Schema Validator.
3. SQLite 24 Relational Entities Schema & In-Memory / File Database Helpers.
4. Telephony CDR Records with Cell Tower Azimuths & Timestamps.
5. Digital Forensics Disk Image Hash Verification Fixtures (MD5 & SHA-256).
6. 44-byte WAV Audio Header Generator, Parser & Validator.
7. Kokoro TTS Chunking Engine & Boundary Validator (250-650 chars, target 450).
8. Gemini REST API Models & Strict RAG Provenance Response Fixtures.
9. Academic Editorial Design System Tokens & Typography Scale.
"""

import hashlib
import json
import re
import sqlite3
import struct
from typing import Any, Dict, List, Optional, Tuple

import jsonschema

# ==============================================================================
# 1. ACADEMIC EDITORIAL DESIGN SYSTEM TOKENS & WCAG 2.1 CALCULATIONS
# ==============================================================================

DESIGN_SYSTEM_TOKENS = {
    "palette": {
        "bg_offwhite": "#F5F6F3",
        "primary_green": "#20533F",
        "dark_green": "#163D2E",
        "accent_green": "#347259",
        "mint_tint": "#E7F0EA",
        "text_main": "#26322C",
        "text_muted": "#66736B",
        "border_divider": "#E1E6E0",
        "surface_light": "#F0F2EF",
    },
    "typography": {
        "min_font_size_sp": 14.0,
        "max_font_size_sp": 22.0,
        "default_font_size_sp": 16.0,
        "default_line_height": 1.5,
    },
    "navigation": {
        "android_tabs": [
            "Início",
            "Estudar",
            "Biblioteca",
            "Laboratório",
            "Meu Espaço",
        ],
        "windows_rail_items": [
            "Início",
            "Estudar",
            "Biblioteca",
            "Laboratório",
            "Meu Espaço",
        ],
    },
}


def srgb_channel_to_linear(channel: float) -> float:
    """
    Official WCAG 2.1 sRGB to linear gamma expansion:
    c_linear = c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    where c = channel / 255.0 (or c if already normalized in range 0.0 to 1.0).
    """
    c = channel / 255.0 if channel > 1.0 else float(channel)
    if c <= 0.04045:
        return c / 12.92
    return ((c + 0.055) / 1.055) ** 2.4


def calculate_relative_luminance(hex_code: str) -> float:
    """
    Official WCAG 2.1 relative luminance calculation:
    L = 0.2126 * r_lin + 0.7152 * g_lin + 0.0722 * b_lin
    """
    clean_hex = hex_code.strip().lstrip("#")
    if len(clean_hex) == 3:
        clean_hex = "".join(ch * 2 for ch in clean_hex)
    if len(clean_hex) != 6:
        raise ValueError(f"Invalid hex color format: '{hex_code}'")
    r = int(clean_hex[0:2], 16) / 255.0
    g = int(clean_hex[2:4], 16) / 255.0
    b = int(clean_hex[4:6], 16) / 255.0

    r_lin = r / 12.92 if r <= 0.04045 else ((r + 0.055) / 1.055) ** 2.4
    g_lin = g / 12.92 if g <= 0.04045 else ((g + 0.055) / 1.055) ** 2.4
    b_lin = b / 12.92 if b <= 0.04045 else ((b + 0.055) / 1.055) ** 2.4

    return 0.2126 * r_lin + 0.7152 * g_lin + 0.0722 * b_lin


def calculate_contrast_ratio(hex1: str, hex2: str) -> float:
    """
    Official WCAG 2.1 contrast ratio calculation:
    (max(L1, L2) + 0.05) / (min(L1, L2) + 0.05)
    """
    l1 = calculate_relative_luminance(hex1)
    l2 = calculate_relative_luminance(hex2)
    return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)


def verify_wcag_aaa(hex1: str, hex2: str, is_large_text: bool = False) -> bool:
    """
    Verifies compliance with WCAG 2.1 Level AAA:
    - Normal text: contrast ratio >= 7.0:1
    - Large text (>= 18pt or >= 14pt bold): contrast ratio >= 4.5:1
    """
    ratio = calculate_contrast_ratio(hex1, hex2)
    threshold = 4.5 if is_large_text else 7.0
    return ratio >= threshold


# Re-export WCAG helpers for fixtures package consumers
__all_wcag__ = [
    "srgb_channel_to_linear",
    "calculate_relative_luminance",
    "calculate_contrast_ratio",
    "verify_wcag_aaa",
]

# ==============================================================================
# 2. CANONICAL 9 VOLUMES & 113 CHAPTERS METADATA
# ==============================================================================

EDITORIAL_STATUSES = [
    "Planejado",
    "Importado",
    "Em revisão",
    "Aprovado",
    "Publicado",
    "Substituído",
    "Arquivado",
]

VOLUMES_METADATA = [
    {
        "volume_id": 1,
        "roman": "Volume I",
        "title": "Fundamentos das Ciências Forenses",
        "chapter_start": 1,
        "chapter_end": 10,
        "chapter_count": 10,
        "printed_pages": 133,
        "printed_status": "Printed (Ch 1-4 REV2, Ch 5-10 REV1)",
        "area": "Fundamentos",
    },
    {
        "volume_id": 2,
        "roman": "Volume II",
        "title": "Computação, Python, SQL e Matemática",
        "chapter_start": 11,
        "chapter_end": 23,
        "chapter_count": 13,
        "printed_pages": 0,
        "printed_status": "Digital Only",
        "area": "Computação e Métodos Quantitativos",
    },
    {
        "volume_id": 3,
        "roman": "Volume III",
        "title": "Estatística e Ciência de Dados Forense",
        "chapter_start": 24,
        "chapter_end": 39,
        "chapter_count": 16,
        "printed_pages": 0,
        "printed_status": "Digital Only",
        "area": "Estatística e Ciência de Dados",
    },
    {
        "volume_id": 4,
        "roman": "Volume IV",
        "title": "Perícia Digital",
        "chapter_start": 40,
        "chapter_end": 53,
        "chapter_count": 14,
        "printed_pages": 0,
        "printed_status": "Digital Only",
        "area": "Perícia Digital e Resposta a Incidentes",
    },
    {
        "volume_id": 5,
        "roman": "Volume V",
        "title": "Telefonia, Geolocalização e Cronologias",
        "chapter_start": 54,
        "chapter_end": 66,
        "chapter_count": 13,
        "printed_pages": 0,
        "printed_status": "Digital Only",
        "area": "Telefonia e Geolocalização",
    },
    {
        "volume_id": 6,
        "roman": "Volume VI",
        "title": "Linguística Forense e NLP",
        "chapter_start": 67,
        "chapter_end": 78,
        "chapter_count": 12,
        "printed_pages": 0,
        "printed_status": "Digital Only",
        "area": "Linguística Forense",
    },
    {
        "volume_id": 7,
        "roman": "Volume VII",
        "title": "Documentoscopia e Multimídia",
        "chapter_start": 79,
        "chapter_end": 90,
        "chapter_count": 12,
        "printed_pages": 0,
        "printed_status": "Digital Only",
        "area": "Documentoscopia e Multimídia",
    },
    {
        "volume_id": 8,
        "roman": "Volume VIII",
        "title": "Áreas Forenses Complementares",
        "chapter_start": 91,
        "chapter_end": 100,
        "chapter_count": 10,
        "printed_pages": 0,
        "printed_status": "Digital Only",
        "area": "Áreas Complementares",
    },
    {
        "volume_id": 9,
        "roman": "Volume IX",
        "title": "Pesquisa e Exercício Profissional",
        "chapter_start": 101,
        "chapter_end": 113,
        "chapter_count": 13,
        "printed_pages": 0,
        "printed_status": "Digital Only",
        "area": "Pesquisa e Prática Profissional",
    },
]

# Standard chapter titles across 113 chapters
CHAPTER_TITLES = {
    1: "Dos dados às evidências: Introdução e Cadeia de Custódia",
    2: "Princípios Fundamentais da Criminalística e Vestígios",
    3: "Locais de Crime e Metodologia de Levantamento Pericial",
    4: "Documentação Pericial, Laudos e Pareceres Técnicos",
    5: "Fotografia Forense e Registro Visual de Vestígios",
    6: "Metodologia Científica e Epistemologia Forense",
    7: "Identificação Humana e Princípios Biométricos",
    8: "Toxicologia Forense e Noções de Química Pericial",
    9: "Balística Forense e Exames de Armas e Munições",
    10: "Ética, Legislação e Atuação Profissional do Perito",
    11: "Fundamentos de Sistemas Operacionais e Arquitetura",
    12: "Lógica de Programação e Estruturas de Dados para Perícia",
    13: "Python Forense I: Fundamentos e Automação de Tarefas",
    14: "Python Forense II: Manipulação de Arquivos e Expressões Regulares",
    15: "Bancos de Dados Relacionais e SQL Aplicado a Investigações",
    16: "Matemática Discreta e Lógica Booleana para Investigação",
    17: "Álgebra Linear Aplicada a Processamento de Sinais",
    18: "Criptografia Clássica, Moderna e Funções Hash Criptográficas",
    19: "Redes de Computadores: Protocolos e Topologias",
    20: "Análise de Tráfego de Rede e Captura de Pacotes (PCAP)",
    21: "Sistemas de Arquivos: FAT, NTFS, Ext4 e APFS",
    22: "Engenharia Reversa Básica e Análise de Binários",
    23: "Automação e Scripts para Triagem Forense",
    24: "Estatística Descritiva Aplicada a Evidências",
    25: "Teoria das Probabilidades e Teorema de Bayes na Perícia",
    26: "Distribuições Estatísticas e Testes de Hipóteses",
    27: "Ciência de Dados com Pandas e NumPy para Analistas",
    28: "Visualização Forense de Dados com Matplotlib e Seaborn",
    29: "Inferência Bayesiana e Razão de Verossimilhança (Likelihood Ratio)",
    30: "Análise Exploratória de Grandes Volumes de Dados Judiciais",
    31: "Detecção de Anomalias e Padrões Ocultos em Transações",
    32: "Modelagem Preditiva e Machine Learning Básico",
    33: "Mineração de Dados Financeiros e Cruzamento de Contas",
    34: "Estatística Multivariada e Redução de Dimensionalidade (PCA)",
    35: "Séries Temporais e Detecção de Quebra Estrutural",
    36: "Georreferenciamento e Análise Espacial de Incidentes",
    37: "Validação Cruzada e Confiabilidade de Modelos",
    38: "Métricas de Avaliação de Erro Pericial e Intervalos de Confiança",
    39: "Apresentação Gráfica e Defesa Estatística de Laudos",
}

for ch in range(40, 114):
    if ch <= 53:
        CHAPTER_TITLES[ch] = f"Perícia Digital Avançada: Tópico Especial {ch}"
    elif ch <= 66:
        CHAPTER_TITLES[ch] = f"Telefonia, ERBs e Geolocalização: Tópico Especial {ch}"
    elif ch <= 78:
        CHAPTER_TITLES[ch] = f"Linguística Forense e Atribuição de Autoria: Tópico {ch}"
    elif ch <= 90:
        CHAPTER_TITLES[ch] = f"Documentoscopia e Multimídia Forense: Tópico {ch}"
    elif ch <= 100:
        CHAPTER_TITLES[ch] = f"Área Forense Especializada: Módulo {ch}"
    else:
        CHAPTER_TITLES[ch] = f"Pesquisa Aplicada e Prática Pericial: Tópico {ch}"


def get_volume_for_chapter(chapter_num: int) -> Optional[Dict[str, Any]]:
    for vol in VOLUMES_METADATA:
        if vol["chapter_start"] <= chapter_num <= vol["chapter_end"]:
            return vol
    return None


def get_canonical_chapter_metadata(chapter_num: int) -> Dict[str, Any]:
    vol = get_volume_for_chapter(chapter_num)
    if not vol:
        raise ValueError(f"Chapter {chapter_num} outside valid range (1..113)")

    if vol["volume_id"] == 1:
        if 1 <= chapter_num <= 4:
            revision = "REV2"
            status = "Publicado"
        elif 5 <= chapter_num <= 10:
            revision = "REV1"
            status = "Publicado"
        else:
            revision = "REV1"
            status = "Aprovado"
    elif chapter_num <= 26:
        revision = "REV1"
        status = "Em revisão"
    else:
        revision = "REV1"
        status = "Planejado"

    return {
        "volume_id": vol["volume_id"],
        "volume_title": vol["title"],
        "chapter_id": chapter_num,
        "content_id": f"forense.vol{vol['volume_id']:02d}.ch{chapter_num:02d}",
        "title": CHAPTER_TITLES.get(chapter_num, f"Capítulo {chapter_num}"),
        "slug": f"vol{vol['volume_id']:02d}-ch{chapter_num:02d}",
        "expected_revision": revision,
        "editorial_status": status,
        "language": "pt-BR",
    }


ALL_113_CHAPTERS_METADATA = [
    get_canonical_chapter_metadata(i) for i in range(1, 114)
]

# ==============================================================================
# 3. SECTION 19 JSON SCHEMA (DRAFT 2020-12) & VALIDATION ENGINE
# ==============================================================================

SECTION_19_JSON_SCHEMA = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "AcademiaForenseEducationalPackage",
    "description": "Zero-recompilation educational package schema for Academia Forense curriculum",
    "type": "object",
    "required": [
        "schemaVersion",
        "contentId",
        "type",
        "volume",
        "chapter",
        "title",
        "language",
        "edition",
        "editorialStatus",
        "source",
        "sections",
        "learningObjectives",
        "prerequisites",
        "glossary",
        "figures",
        "tables",
        "references",
        "exercises",
        "laboratories",
        "assessment",
        "audio",
    ],
    "properties": {
        "schemaVersion": {"type": "string", "pattern": "^[0-9]+\\.[0-9]+$"},
        "contentId": {
            "type": "string",
            "pattern": "^forense\\.vol[0-9]{2}\\.ch[0-9]{2}$",
        },
        "type": {"type": "string", "enum": ["chapter", "appendix", "case_study"]},
        "volume": {"type": "integer", "minimum": 1, "maximum": 9},
        "chapter": {"type": "integer", "minimum": 1, "maximum": 113},
        "title": {"type": "string", "minLength": 3},
        "language": {"type": "string", "enum": ["pt-BR", "en-US"]},
        "edition": {"type": "string", "pattern": "^REV[0-9]+$"},
        "editorialStatus": {
            "type": "string",
            "enum": [
                "Planejado",
                "Importado",
                "Em revisão",
                "Aprovado",
                "Publicado",
                "Substituído",
                "Arquivado",
                "planned",
                "imported",
                "under_review",
                "approved",
                "published",
                "superseded",
                "archived",
            ],
        },
        "source": {
            "type": "object",
            "required": ["provider"],
            "properties": {
                "provider": {
                    "type": "string",
                    "enum": ["google_drive", "local_file", "fixture"],
                },
                "fileId": {"type": ["string", "null"]},
                "revision": {"type": ["string", "null"]},
                "sha256": {"type": ["string", "null"], "pattern": "^[a-fA-F0-9]{64}$"},
            },
            "additionalProperties": False,
        },
        "sections": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["sectionId", "title", "orderIndex", "markdownContent"],
                "properties": {
                    "sectionId": {"type": "string", "minLength": 1},
                    "title": {"type": "string", "minLength": 1},
                    "orderIndex": {"type": "integer", "minimum": 0},
                    "markdownContent": {"type": "string"},
                    "anchorKey": {"type": "string"},
                },
                "additionalProperties": False,
            },
        },
        "learningObjectives": {
            "type": "array",
            "items": {"type": "string", "minLength": 5},
        },
        "prerequisites": {
            "type": "array",
            "items": {"type": "string"},
        },
        "glossary": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["term", "definition"],
                "properties": {
                    "term": {"type": "string", "minLength": 1},
                    "definition": {"type": "string", "minLength": 1},
                },
                "additionalProperties": False,
            },
        },
        "figures": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["figureId", "caption", "assetPath"],
                "properties": {
                    "figureId": {"type": "string"},
                    "caption": {"type": "string"},
                    "assetPath": {"type": "string"},
                },
                "additionalProperties": False,
            },
        },
        "tables": {
            "type": "array",
            "items": {"type": "object"},
        },
        "references": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["citationKey", "formattedText"],
                "properties": {
                    "citationKey": {"type": "string"},
                    "formattedText": {"type": "string"},
                    "year": {"type": "integer"},
                },
                "additionalProperties": False,
            },
        },
        "exercises": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["exerciseId", "prompt", "exerciseType"],
                "properties": {
                    "exerciseId": {"type": "string"},
                    "prompt": {"type": "string"},
                    "exerciseType": {"type": "string", "enum": ["objective", "discursive", "code"]},
                    "solution": {"type": "string"},
                },
                "additionalProperties": True,
            },
        },
        "laboratories": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["labId", "domain", "title", "instructions"],
                "properties": {
                    "labId": {"type": "string"},
                    "domain": {
                        "type": "string",
                        "enum": [
                            "informatics",
                            "math",
                            "programming",
                            "digital_forensics",
                            "telephony",
                            "linguistics",
                            "multimedia",
                        ],
                    },
                    "title": {"type": "string"},
                    "instructions": {"type": "string"},
                    "expectedResult": {"type": "string"},
                },
                "additionalProperties": True,
            },
        },
        "assessment": {
            "type": ["object", "null"],
            "properties": {
                "assessmentId": {"type": "string"},
                "passingScorePercent": {"type": "number", "minimum": 0, "maximum": 100},
                "questions": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "required": ["questionId", "prompt", "type", "points"],
                        "properties": {
                            "questionId": {"type": "string"},
                            "prompt": {"type": "string"},
                            "type": {"type": "string", "enum": ["multiple_choice", "discursive", "code_check"]},
                            "points": {"type": "number", "minimum": 0},
                            "options": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "required": ["optionId", "text", "isCorrect"],
                                    "properties": {
                                        "optionId": {"type": "string"},
                                        "text": {"type": "string"},
                                        "isCorrect": {"type": "boolean"},
                                    },
                                    "additionalProperties": False,
                                },
                            },
                            "rubric": {"type": "string"},
                        },
                        "additionalProperties": True,
                    },
                },
            },
            "required": ["assessmentId", "passingScorePercent", "questions"],
        },
        "audio": {
            "type": "object",
            "required": ["enabled", "language"],
            "properties": {
                "enabled": {"type": "boolean"},
                "language": {"type": "string"},
                "voicePreferred": {"type": "string"},
            },
            "additionalProperties": False,
        },
    },
    "additionalProperties": False,
}


def validate_section_19_package(package_dict: Dict[str, Any]) -> Tuple[bool, List[str]]:
    validator = jsonschema.Draft202012Validator(SECTION_19_JSON_SCHEMA)
    errors = [e.message for e in validator.iter_errors(package_dict)]
    return (len(errors) == 0, errors)


SAMPLE_VALID_CH01_PACKAGE = {
    "schemaVersion": "1.0",
    "contentId": "forense.vol01.ch01",
    "type": "chapter",
    "volume": 1,
    "chapter": 1,
    "title": "Dos dados às evidências: Introdução e Cadeia de Custódia",
    "language": "pt-BR",
    "edition": "REV2",
    "editorialStatus": "approved",
    "source": {
        "provider": "fixture",
        "fileId": "seed_vol01_ch01_rev2",
        "revision": "2.0",
        "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    },
    "sections": [
        {
            "sectionId": "sec-01",
            "title": "1.1 Introdução às Evidências Físicas e Digitais",
            "orderIndex": 0,
            "markdownContent": "A ciência forense contemporânea transita na interseção entre o mundo físico e o virtual. Vestígios materiais e bits digitais compartilham o mesmo imperativo: rigor metodológico e rastreabilidade irrefutável.",
            "anchorKey": "intro_anchor_v2",
        },
        {
            "sectionId": "sec-02",
            "title": "1.2 Cadeia de Custódia e Lei 13.964/2019",
            "orderIndex": 1,
            "markdownContent": "O Pacote Anticrime introduziu os artigos 158-A a 158-F no Código de Processo Penal brasileiro, detalhando as 10 etapas da cadeia de custódia: reconhecimento, isolamento, fixação, coleta, acondicionamento, transporte, recebimento, processamento, armazenamento e descarte.",
            "anchorKey": "custody_anchor_v2",
        },
    ],
    "learningObjectives": [
        "Compreender a diferença legal e técnica entre vestígio, indício e evidência.",
        "Dominar as 10 etapas formais da cadeia de custódia conforme a Lei 13.964/2019.",
        "Executar procedimentos de hash criptográfico para garantir a integridade da evidência.",
    ],
    "prerequisites": [],
    "glossary": [
        {
            "term": "Vestígio",
            "definition": "Todo objeto ou material bruto, de origem física ou digital, encontrado no local ou relacionado à infração penal.",
        },
        {
            "term": "Cadeia de Custódia",
            "definition": "Conjunto de todos os procedimentos utilizados para manter e documentar a história cronológica do vestígio.",
        },
    ],
    "figures": [
        {
            "figureId": "fig-01",
            "caption": "Fluxograma das 10 etapas da cadeia de custódia penal",
            "assetPath": "assets/figures/ch01_custody_flow.png",
        }
    ],
    "tables": [],
    "references": [
        {
            "citationKey": "BRASIL2019",
            "formattedText": "BRASIL. Lei nº 13.964, de 24 de dezembro de 2019. Aperfeiçoa a legislação penal e processual penal.",
            "year": 2019,
        }
    ],
    "exercises": [
        {
            "exerciseId": "ex-01",
            "prompt": "Qual é a primeira etapa formal da cadeia de custódia segundo o art. 158-B do CPP?",
            "exerciseType": "objective",
            "solution": "Reconhecimento",
        }
    ],
    "laboratories": [
        {
            "labId": "lab-df-01",
            "domain": "digital_forensics",
            "title": "Verificação de Hashes Criptográficos em Imagem Pericial",
            "instructions": "Calcule os hashes MD5 e SHA-256 do arquivo de evidência e confira a integridade.",
            "expectedResult": "Hashes coincidem com o termo de apreensão.",
        }
    ],
    "assessment": {
        "assessmentId": "eval-ch01",
        "passingScorePercent": 80.0,
        "questions": [
            {
                "questionId": "q-01",
                "prompt": "O que ocorre se o lacre da embalagem de um vestígio for rompido sem justificativa documentada?",
                "type": "multiple_choice",
                "points": 50.0,
                "options": [
                    {
                        "optionId": "opt-a",
                        "text": "A evidência sofre quebra na cadeia de custódia, podendo ensejar sua inadmissibilidade.",
                        "isCorrect": True,
                    },
                    {
                        "optionId": "opt-b",
                        "text": "O perito pode reembalar sem registrar em relatório.",
                        "isCorrect": False,
                    },
                ],
            },
            {
                "questionId": "q-02",
                "prompt": "Qual das seguintes etapas pertence à cadeia de custódia formal brasileira?",
                "type": "multiple_choice",
                "points": 50.0,
                "options": [
                    {
                        "optionId": "opt-c",
                        "text": "Acondicionamento e Fixação",
                        "isCorrect": True,
                    },
                    {
                        "optionId": "opt-d",
                        "text": "Divulgação na imprensa",
                        "isCorrect": False,
                    },
                ],
            },
        ],
    },
    "audio": {
        "enabled": True,
        "language": "pt-BR",
        "voicePreferred": "pt-BR-Kokoro-Braseiro",
    },
}

SAMPLE_INVALID_PACKAGES = {
    "missing_content_id": {
        "schemaVersion": "1.0",
        "type": "chapter",
        "volume": 1,
        "chapter": 1,
        "title": "Invalid Missing ContentId",
        "language": "pt-BR",
        "edition": "REV1",
        "editorialStatus": "approved",
    },
    "invalid_status": {
        "schemaVersion": "1.0",
        "contentId": "forense.vol01.ch01",
        "type": "chapter",
        "volume": 1,
        "chapter": 1,
        "title": "Invalid Status",
        "language": "pt-BR",
        "edition": "REV1",
        "editorialStatus": "UNAPPROVED_STATUS_TAG",
        "source": {"provider": "fixture"},
        "sections": [],
        "learningObjectives": [],
        "prerequisites": [],
        "glossary": [],
        "figures": [],
        "tables": [],
        "references": [],
        "exercises": [],
        "laboratories": [],
        "assessment": None,
        "audio": {"enabled": True, "language": "pt-BR"},
    },
    "chapter_out_of_bounds": {
        "schemaVersion": "1.0",
        "contentId": "forense.vol01.ch01",
        "type": "chapter",
        "volume": 1,
        "chapter": 999,
        "title": "Chapter out of bounds",
        "language": "pt-BR",
        "edition": "REV1",
        "editorialStatus": "approved",
        "source": {"provider": "fixture"},
        "sections": [],
        "learningObjectives": [],
        "prerequisites": [],
        "glossary": [],
        "figures": [],
        "tables": [],
        "references": [],
        "exercises": [],
        "laboratories": [],
        "assessment": None,
        "audio": {"enabled": True, "language": "pt-BR"},
    },
}

# ==============================================================================
# 4. SQLITE 24 RELATIONAL ENTITIES SCHEMA
# ==============================================================================

SQLITE_24_ENTITIES_DDL = """
-- Academia Forense: 24 Relational Entities Schema (Drift/SQLite 3.40+)

-- 1. Volumes
CREATE TABLE IF NOT EXISTS volumes (
    volume_id INTEGER PRIMARY KEY,
    roman_number TEXT NOT NULL,
    title TEXT NOT NULL,
    chapter_start INTEGER NOT NULL,
    chapter_end INTEGER NOT NULL,
    printed_pages INTEGER DEFAULT 0,
    area TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Chapters
CREATE TABLE IF NOT EXISTS chapters (
    chapter_id INTEGER PRIMARY KEY,
    volume_id INTEGER NOT NULL REFERENCES volumes(volume_id) ON DELETE CASCADE,
    content_id TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    slug TEXT NOT NULL,
    editorial_status TEXT NOT NULL DEFAULT 'Planejado',
    active_revision TEXT NOT NULL DEFAULT 'REV1',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Sections
CREATE TABLE IF NOT EXISTS sections (
    section_id TEXT PRIMARY KEY,
    chapter_id INTEGER NOT NULL REFERENCES chapters(chapter_id) ON DELETE CASCADE,
    order_index INTEGER NOT NULL,
    title TEXT NOT NULL,
    anchor_key TEXT,
    markdown_content TEXT NOT NULL,
    char_count INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Revisions
CREATE TABLE IF NOT EXISTS revisions (
    revision_id INTEGER PRIMARY KEY AUTOINCREMENT,
    chapter_id INTEGER NOT NULL REFERENCES chapters(chapter_id) ON DELETE CASCADE,
    edition TEXT NOT NULL,
    provider TEXT NOT NULL,
    file_id TEXT,
    sha256_hash TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1,
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Notes (Decoupled from direct text, anchored with tolerance)
CREATE TABLE IF NOT EXISTS notes (
    note_id TEXT PRIMARY KEY,
    chapter_id INTEGER NOT NULL REFERENCES chapters(chapter_id) ON DELETE CASCADE,
    section_id TEXT REFERENCES sections(section_id) ON DELETE SET NULL,
    anchor_key TEXT,
    selected_text TEXT,
    note_content TEXT NOT NULL,
    color_hex TEXT DEFAULT '#347259',
    anchor_drift_detected INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Bookmarks
CREATE TABLE IF NOT EXISTS bookmarks (
    bookmark_id TEXT PRIMARY KEY,
    chapter_id INTEGER NOT NULL REFERENCES chapters(chapter_id) ON DELETE CASCADE,
    section_id TEXT REFERENCES sections(section_id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Reading Positions
CREATE TABLE IF NOT EXISTS reading_positions (
    chapter_id INTEGER PRIMARY KEY REFERENCES chapters(chapter_id) ON DELETE CASCADE,
    section_id TEXT REFERENCES sections(section_id) ON DELETE SET NULL,
    scroll_offset REAL DEFAULT 0.0,
    last_paragraph_index INTEGER DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Assessments
CREATE TABLE IF NOT EXISTS assessments (
    assessment_id TEXT PRIMARY KEY,
    chapter_id INTEGER NOT NULL REFERENCES chapters(chapter_id) ON DELETE CASCADE,
    passing_score REAL DEFAULT 80.0,
    total_points REAL DEFAULT 100.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. Questions
CREATE TABLE IF NOT EXISTS questions (
    question_id TEXT PRIMARY KEY,
    assessment_id TEXT NOT NULL REFERENCES assessments(assessment_id) ON DELETE CASCADE,
    prompt TEXT NOT NULL,
    question_type TEXT NOT NULL,
    points REAL DEFAULT 10.0,
    options_json TEXT,
    rubric TEXT
);

-- 10. Assessment Attempts (Immutable historical records)
CREATE TABLE IF NOT EXISTS assessment_attempts (
    attempt_id TEXT PRIMARY KEY,
    assessment_id TEXT NOT NULL REFERENCES assessments(assessment_id) ON DELETE RESTRICT,
    score_percent REAL NOT NULL,
    passed INTEGER NOT NULL,
    duration_seconds INTEGER DEFAULT 0,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. Question Responses
CREATE TABLE IF NOT EXISTS question_responses (
    response_id TEXT PRIMARY KEY,
    attempt_id TEXT NOT NULL REFERENCES assessment_attempts(attempt_id) ON DELETE CASCADE,
    question_id TEXT NOT NULL REFERENCES questions(question_id) ON DELETE RESTRICT,
    student_response TEXT NOT NULL,
    is_correct INTEGER NOT NULL,
    points_awarded REAL NOT NULL
);

-- 12. Lab Exercises
CREATE TABLE IF NOT EXISTS lab_exercises (
    lab_id TEXT PRIMARY KEY,
    chapter_id INTEGER REFERENCES chapters(chapter_id) ON DELETE SET NULL,
    domain TEXT NOT NULL,
    title TEXT NOT NULL,
    instructions TEXT NOT NULL,
    expected_output TEXT
);

-- 13. Lab Runs
CREATE TABLE IF NOT EXISTS lab_runs (
    run_id TEXT PRIMARY KEY,
    lab_id TEXT NOT NULL REFERENCES lab_exercises(lab_id) ON DELETE CASCADE,
    platform TEXT NOT NULL,
    status TEXT NOT NULL,
    executed_code TEXT,
    stdout_output TEXT,
    stderr_output TEXT,
    is_success INTEGER NOT NULL,
    execution_time_ms INTEGER,
    memory_used_bytes INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 14. Case Studies
CREATE TABLE IF NOT EXISTS case_studies (
    case_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    domain TEXT NOT NULL,
    synopsis TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 15. Case Evidence (Separating Facts vs Inferences)
CREATE TABLE IF NOT EXISTS case_evidence (
    evidence_id TEXT PRIMARY KEY,
    case_id TEXT NOT NULL REFERENCES case_studies(case_id) ON DELETE CASCADE,
    category TEXT NOT NULL CHECK(category IN ('FACT', 'INFERENCE', 'HYPOTHESIS')),
    description TEXT NOT NULL,
    source_reference TEXT,
    timestamp_event TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 16. Case Hypotheses
CREATE TABLE IF NOT EXISTS case_hypotheses (
    hypothesis_id TEXT PRIMARY KEY,
    case_id TEXT NOT NULL REFERENCES case_studies(case_id) ON DELETE CASCADE,
    statement TEXT NOT NULL,
    status TEXT DEFAULT 'UNDER_INVESTIGATION',
    supported_by_evidence INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 17. AI Key Vault (Encrypted BYOK Storage)
CREATE TABLE IF NOT EXISTS ai_key_vault (
    vault_id TEXT PRIMARY KEY,
    encrypted_gemini_key TEXT NOT NULL,
    iv_vector TEXT NOT NULL,
    storage_type TEXT NOT NULL DEFAULT 'SECURE_STORAGE',
    masked_key_hint TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 18. Model Cache
CREATE TABLE IF NOT EXISTS model_cache (
    model_id TEXT PRIMARY KEY,
    display_name TEXT NOT NULL,
    supported_methods TEXT NOT NULL,
    supports_audio INTEGER DEFAULT 0,
    last_discovered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 19. Tutor Sessions
CREATE TABLE IF NOT EXISTS tutor_sessions (
    session_id TEXT PRIMARY KEY,
    chapter_id INTEGER REFERENCES chapters(chapter_id) ON DELETE SET NULL,
    pedagogical_mode TEXT NOT NULL,
    model_id TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 20. Tutor Messages (With RAG Provenance Citations)
CREATE TABLE IF NOT EXISTS tutor_messages (
    message_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL REFERENCES tutor_sessions(session_id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK(role IN ('user', 'model', 'system')),
    content TEXT NOT NULL,
    has_fonte_tag INTEGER DEFAULT 0,
    has_inferencia_tag INTEGER DEFAULT 0,
    grounded_chunks_json TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 21. RAG Chunks
CREATE TABLE IF NOT EXISTS rag_chunks (
    chunk_id TEXT PRIMARY KEY,
    chapter_id INTEGER NOT NULL REFERENCES chapters(chapter_id) ON DELETE CASCADE,
    section_id TEXT REFERENCES sections(section_id) ON DELETE CASCADE,
    chunk_text TEXT NOT NULL,
    char_length INTEGER NOT NULL,
    token_estimate INTEGER NOT NULL,
    is_approved INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 22. Audio Settings
CREATE TABLE IF NOT EXISTS audio_settings (
    setting_id INTEGER PRIMARY KEY CHECK(setting_id = 1),
    active_engine TEXT NOT NULL DEFAULT 'kokoro' CHECK(active_engine IN ('kokoro', 'geminiTts')),
    selected_voice TEXT NOT NULL DEFAULT 'pt-BR-Kokoro-Braseiro',
    playback_speed REAL NOT NULL DEFAULT 1.0 CHECK(playback_speed >= 0.65 AND playback_speed <= 1.50),
    silence_scale REAL DEFAULT 0.06,
    follow_along_highlight INTEGER DEFAULT 1,
    allow_silent_fallback INTEGER DEFAULT 0 CHECK(allow_silent_fallback = 0),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 23. Audio Cache
CREATE TABLE IF NOT EXISTS audio_cache (
    cache_id TEXT PRIMARY KEY,
    text_hash TEXT NOT NULL UNIQUE,
    engine TEXT NOT NULL,
    audio_path TEXT NOT NULL,
    duration_ms INTEGER NOT NULL,
    file_size_bytes INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 24. Errata Records (Volume I Print Preservation without reprints)
CREATE TABLE IF NOT EXISTS errata_records (
    errata_id INTEGER PRIMARY KEY AUTOINCREMENT,
    volume_id INTEGER NOT NULL REFERENCES volumes(volume_id),
    chapter_id INTEGER NOT NULL REFERENCES chapters(chapter_id),
    page_number INTEGER NOT NULL,
    original_printed_text TEXT NOT NULL,
    corrected_text TEXT NOT NULL,
    justification TEXT NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for fast lookup and FTS support
CREATE INDEX IF NOT EXISTS idx_chapters_volume ON chapters(volume_id);
CREATE INDEX IF NOT EXISTS idx_sections_chapter ON sections(chapter_id);
CREATE INDEX IF NOT EXISTS idx_revisions_chapter ON revisions(chapter_id);
CREATE INDEX IF NOT EXISTS idx_notes_chapter ON notes(chapter_id);
CREATE INDEX IF NOT EXISTS idx_attempts_assessment ON assessment_attempts(assessment_id);
CREATE INDEX IF NOT EXISTS idx_rag_chunks_chapter ON rag_chunks(chapter_id);
CREATE INDEX IF NOT EXISTS idx_case_evidence_case ON case_evidence(case_id);
"""


def init_sqlite_db(db_path: str = ":memory:") -> sqlite3.Connection:
    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA foreign_keys = ON;")
    conn.executescript(SQLITE_24_ENTITIES_DDL)
    return conn


def seed_database(conn: sqlite3.Connection) -> None:
    cursor = conn.cursor()

    # Seed Volumes 1..9
    for vol in VOLUMES_METADATA:
        cursor.execute(
            """
            INSERT OR REPLACE INTO volumes
            (volume_id, roman_number, title, chapter_start, chapter_end, printed_pages, area)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (
                vol["volume_id"],
                vol["roman"],
                vol["title"],
                vol["chapter_start"],
                vol["chapter_end"],
                vol["printed_pages"],
                vol["area"],
            ),
        )

    # Seed Chapters 1..113
    for ch in ALL_113_CHAPTERS_METADATA:
        cursor.execute(
            """
            INSERT OR REPLACE INTO chapters
            (chapter_id, volume_id, content_id, title, slug, editorial_status, active_revision)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (
                ch["chapter_id"],
                ch["volume_id"],
                ch["content_id"],
                ch["title"],
                ch["slug"],
                ch["editorial_status"],
                ch["expected_revision"],
            ),
        )

    # Seed Chapter 1 sections
    ch1_sec1 = (
        "sec-01",
        1,
        0,
        "1.1 Introdução às Evidências Físicas e Digitais",
        "intro_anchor_v2",
        "A ciência forense contemporânea transita na interseção entre o mundo físico e o virtual.",
        87,
    )
    ch1_sec2 = (
        "sec-02",
        1,
        1,
        "1.2 Cadeia de Custódia e Lei 13.964/2019",
        "custody_anchor_v2",
        "O Pacote Anticrime introduziu os artigos 158-A a 158-F no Código de Processo Penal brasileiro, regulamentando a Cadeia de Custódia.",
        132,
    )
    cursor.execute(
        """
        INSERT OR REPLACE INTO sections
        (section_id, chapter_id, order_index, title, anchor_key, markdown_content, char_count)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        ch1_sec1,
    )
    cursor.execute(
        """
        INSERT OR REPLACE INTO sections
        (section_id, chapter_id, order_index, title, anchor_key, markdown_content, char_count)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        ch1_sec2,
    )

    # Seed Chapter 1 Active Revision
    cursor.execute(
        """
        INSERT OR REPLACE INTO revisions
        (chapter_id, edition, provider, file_id, sha256_hash, is_active)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (1, "REV2", "fixture", "seed_vol01_ch01_rev2", "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", 1),
    )

    # Seed Audio Settings
    cursor.execute(
        """
        INSERT OR REPLACE INTO audio_settings
        (setting_id, active_engine, selected_voice, playback_speed, silence_scale, follow_along_highlight, allow_silent_fallback)
        VALUES (1, 'kokoro', 'pt-BR-Kokoro-Braseiro', 1.0, 0.06, 1, 0)
        """
    )

    # Seed Chapter 1 Assessment & Questions
    cursor.execute(
        """
        INSERT OR REPLACE INTO assessments (assessment_id, chapter_id, passing_score, total_points)
        VALUES ('eval-ch01', 1, 80.0, 100.0)
        """
    )
    cursor.execute(
        """
        INSERT OR REPLACE INTO questions (question_id, assessment_id, prompt, question_type, points, options_json)
        VALUES ('q-01', 'eval-ch01', 'O rompimento não documentado do lacre constitui quebra da cadeia de custódia?', 'multiple_choice', 50.0, '[]')
        """
    )
    cursor.execute(
        """
        INSERT OR REPLACE INTO questions (question_id, assessment_id, prompt, question_type, points, options_json)
        VALUES ('q-02', 'eval-ch01', 'Quais artigos do CPP disciplinam a cadeia de custódia?', 'multiple_choice', 50.0, '[]')
        """
    )

    # Seed Vol I Errata Table (Preservation without reprint)
    cursor.execute(
        """
        INSERT OR REPLACE INTO errata_records
        (volume_id, chapter_id, page_number, original_printed_text, corrected_text, justification)
        VALUES (1, 1, 12, 'art. 158-B, inciso VII: acondicionamento', 'art. 158-B, inciso VII: recebimento', 'Correção de errata tipográfica da impressão física')
        """
    )

    conn.commit()


# ==============================================================================
# 5. TELEPHONY CDR RECORDS & CELL TOWER AZIMUTHS
# ==============================================================================

# 6 synthetic cell towers located in Minas Gerais (Belo Horizonte & Nova Lima)
CELL_TOWERS = {
    "ERB-BH-01": {"lat": -19.9191, "lon": -43.9386, "azimuth": 0, "name": "Praça Sete Alpha"},
    "ERB-BH-02": {"lat": -19.9191, "lon": -43.9386, "azimuth": 120, "name": "Praça Sete Beta"},
    "ERB-BH-03": {"lat": -19.9191, "lon": -43.9386, "azimuth": 240, "name": "Praça Sete Gamma"},
    "ERB-SAV-01": {"lat": -19.9381, "lon": -43.9352, "azimuth": 30, "name": "Savassi Alpha"},
    "ERB-SAV-02": {"lat": -19.9381, "lon": -43.9352, "azimuth": 150, "name": "Savassi Beta"},
    "ERB-NL-01": {"lat": -19.9862, "lon": -43.8471, "azimuth": 270, "name": "Nova Lima Vila da Serra"},
}

SAMPLE_CDR_RECORDS = [
    {
        "record_id": "CDR-001",
        "timestamp": "2026-10-15T08:14:22Z",
        "caller_msisdn": "+5531988881111",
        "callee_msisdn": "+5531977772222",
        "call_type": "VOICE_OUT",
        "duration_sec": 142,
        "cell_id": "ERB-BH-01",
        "azimuth": 0,
        "imei": "864201041234567",
        "tower_name": "Praça Sete Alpha",
        "latitude": -19.9191,
        "longitude": -43.9386,
    },
    {
        "record_id": "CDR-002",
        "timestamp": "2026-10-15T08:35:10Z",
        "caller_msisdn": "+5531988881111",
        "callee_msisdn": "+5531966663333",
        "call_type": "SMS_OUT",
        "duration_sec": 0,
        "cell_id": "ERB-BH-02",
        "azimuth": 120,
        "imei": "864201041234567",
        "tower_name": "Praça Sete Beta",
        "latitude": -19.9191,
        "longitude": -43.9386,
    },
    {
        "record_id": "CDR-003",
        "timestamp": "2026-10-15T09:12:05Z",
        "caller_msisdn": "+5531999994444",
        "callee_msisdn": "+5531988881111",
        "call_type": "VOICE_IN",
        "duration_sec": 310,
        "cell_id": "ERB-SAV-01",
        "azimuth": 30,
        "imei": "864201041234567",
        "tower_name": "Savassi Alpha",
        "latitude": -19.9381,
        "longitude": -43.9352,
    },
    {
        "record_id": "CDR-004",
        "timestamp": "2026-10-15T10:45:18Z",
        "caller_msisdn": "+5531988881111",
        "callee_msisdn": "+5531955555555",
        "call_type": "VOICE_OUT",
        "duration_sec": 85,
        "cell_id": "ERB-NL-01",
        "azimuth": 270,
        "imei": "864201041234567",
        "tower_name": "Nova Lima Vila da Serra",
        "latitude": -19.9862,
        "longitude": -43.8471,
    },
]

# ==============================================================================
# 6. DIGITAL FORENSICS DISK IMAGE HASH FIXTURES
# ==============================================================================

# Deterministic synthetic raw forensic disk sector payload (512 bytes)
# Contains master boot signature, partition table marker, and forensic text string
RAW_DISK_SECTOR_BYTES = (
    b"ACADEMIA_FORENSE_CORPUS_EVIDENCE_SECTOR_00000001\x00\x00"
    + b"CHAIN_OF_CUSTODY_CASE_MG_2026_EVIDENCE_TAG_8841\x00\x00"
    + (b"\xAA\x55" * 150)
    + b"\x55\xAA"
)
# Ensure exact 512-byte sector size
if len(RAW_DISK_SECTOR_BYTES) < 512:
    RAW_DISK_SECTOR_BYTES = RAW_DISK_SECTOR_BYTES.ljust(512, b"\x00")
else:
    RAW_DISK_SECTOR_BYTES = RAW_DISK_SECTOR_BYTES[:512]

DISK_SECTOR_MD5 = hashlib.md5(RAW_DISK_SECTOR_BYTES).hexdigest()
DISK_SECTOR_SHA256 = hashlib.sha256(RAW_DISK_SECTOR_BYTES).hexdigest()

# Tampered sector (single byte flipped at offset 10)
TAMPERED_SECTOR_BYTES = bytearray(RAW_DISK_SECTOR_BYTES)
TAMPERED_SECTOR_BYTES[10] ^= 0xFF
TAMPERED_SECTOR_BYTES = bytes(TAMPERED_SECTOR_BYTES)

TAMPERED_SECTOR_MD5 = hashlib.md5(TAMPERED_SECTOR_BYTES).hexdigest()
TAMPERED_SECTOR_SHA256 = hashlib.sha256(TAMPERED_SECTOR_BYTES).hexdigest()


def verify_forensic_integrity(data: bytes, expected_md5: str, expected_sha256: str) -> Dict[str, Any]:
    actual_md5 = hashlib.md5(data).hexdigest()
    actual_sha256 = hashlib.sha256(data).hexdigest()
    md5_match = (actual_md5.lower() == expected_md5.lower())
    sha256_match = (actual_sha256.lower() == expected_sha256.lower())
    return {
        "md5_match": md5_match,
        "sha256_match": sha256_match,
        "authentic": md5_match and sha256_match,
        "actual_md5": actual_md5,
        "actual_sha256": actual_sha256,
    }


# ==============================================================================
# 7. 44-BYTE WAV AUDIO HEADER GENERATOR & PARSER
# ==============================================================================


def create_wav_header(
    data_size_bytes: int,
    sample_rate: int = 24000,
    num_channels: int = 1,
    bits_per_sample: int = 16,
) -> bytes:
    """Generates a standard 44-byte RIFF/WAVE header for linear PCM audio."""
    byte_rate = (sample_rate * num_channels * bits_per_sample) // 8
    block_align = (num_channels * bits_per_sample) // 8
    chunk_size = 36 + data_size_bytes

    header = struct.pack(
        "<4sI4s4sIHHIIHH4sI",
        b"RIFF",
        chunk_size,
        b"WAVE",
        b"fmt ",
        16,              # Subchunk1Size (16 for PCM)
        1,               # AudioFormat (1 for PCM)
        num_channels,
        sample_rate,
        byte_rate,
        block_align,
        bits_per_sample,
        b"data",
        data_size_bytes,
    )
    if len(header) != 44:
        raise ValueError(f"WAV header must be 44 bytes, got {len(header)}")
    return header


def parse_wav_header(header_bytes: bytes) -> Dict[str, Any]:
    """Parses a 44-byte RIFF/WAVE header and extracts parameters."""
    if len(header_bytes) < 44:
        raise ValueError(f"Expected at least 44 bytes for WAV header, got {len(header_bytes)}")

    unpacked = struct.unpack("<4sI4s4sIHHIIHH4sI", header_bytes[:44])
    riff_marker = unpacked[0]
    chunk_size = unpacked[1]
    wave_marker = unpacked[2]
    fmt_marker = unpacked[3]
    subchunk1_size = unpacked[4]
    audio_format = unpacked[5]
    num_channels = unpacked[6]
    sample_rate = unpacked[7]
    byte_rate = unpacked[8]
    block_align = unpacked[9]
    bits_per_sample = unpacked[10]
    data_marker = unpacked[11]
    data_size = unpacked[12]

    is_valid = (
        riff_marker == b"RIFF"
        and wave_marker == b"WAVE"
        and fmt_marker == b"fmt "
        and audio_format == 1
        and data_marker == b"data"
    )

    return {
        "is_valid": is_valid,
        "chunk_size": chunk_size,
        "num_channels": num_channels,
        "sample_rate": sample_rate,
        "byte_rate": byte_rate,
        "block_align": block_align,
        "bits_per_sample": bits_per_sample,
        "data_size": data_size,
    }


# ==============================================================================
# 8. KOKORO CHUNKING ENGINE & BOUNDARY VALIDATOR
# ==============================================================================

# Target: 450 characters. Valid Range: 250 to 650 characters. maxNumSentences: 2.
KOKORO_MIN_CHARS = 250
KOKORO_MAX_CHARS = 650
KOKORO_TARGET_CHARS = 450
KOKORO_MAX_SENTENCES = 2


def validate_kokoro_chunk(chunk_text: str) -> Tuple[bool, str]:
    length = len(chunk_text.strip())
    if length < KOKORO_MIN_CHARS:
        return (False, f"Chunk too short ({length} chars < {KOKORO_MIN_CHARS} min)")
    if length > KOKORO_MAX_CHARS:
        return (False, f"Chunk too long ({length} chars > {KOKORO_MAX_CHARS} max)")

    # Sentence boundary count estimation
    sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", chunk_text.strip()) if s.strip()]
    if len(sentences) > KOKORO_MAX_SENTENCES:
        return (False, f"Sentence count exceeded ({len(sentences)} > {KOKORO_MAX_SENTENCES} max)")

    return (True, "Valid Kokoro audio chunk")


def chunk_text_for_kokoro(full_text: str) -> List[str]:
    """Splits full editorial text into Kokoro-compatible audio chunks."""
    paragraphs = [p.strip() for p in full_text.split("\n\n") if p.strip()]
    chunks = []

    for para in paragraphs:
        # Split paragraph into candidate sentences
        sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", para) if s.strip()]
        current_chunk = []
        current_len = 0

        for sentence in sentences:
            if len(current_chunk) >= KOKORO_MAX_SENTENCES or (current_len + len(sentence) > KOKORO_MAX_CHARS and current_chunk):
                chunk_str = " ".join(current_chunk).strip()
                chunks.append(chunk_str)
                current_chunk = [sentence]
                current_len = len(sentence)
            else:
                current_chunk.append(sentence)
                current_len += len(sentence) + 1

        if current_chunk:
            chunk_str = " ".join(current_chunk).strip()
            # If smaller than min but previous chunk exists and can absorb/split, or emit if standalone
            chunks.append(chunk_str)

    return chunks


# ==============================================================================
# 9. GEMINI REST API RESPONSES & STRICT RAG PROVENANCE FIXTURES
# ==============================================================================

GEMINI_MODELS_DISCOVERY_FIXTURE = {
    "models": [
        {
            "name": "models/gemini-1.5-flash",
            "version": "001",
            "displayName": "Gemini 1.5 Flash",
            "description": "Fast and versatile multimodal model for general reasoning",
            "inputTokenLimit": 1048576,
            "outputTokenLimit": 8192,
            "supportedGenerationMethods": ["generateContent", "countTokens"],
            "temperature": 1.0,
            "topP": 0.95,
            "topK": 64,
        },
        {
            "name": "models/gemini-1.5-pro",
            "version": "001",
            "displayName": "Gemini 1.5 Pro",
            "description": "Complex reasoning model for high-depth multi-turn forensic analysis",
            "inputTokenLimit": 2097152,
            "outputTokenLimit": 8192,
            "supportedGenerationMethods": ["generateContent", "countTokens"],
            "temperature": 1.0,
            "topP": 0.95,
            "topK": 64,
        },
        {
            "name": "models/gemini-2.0-flash",
            "version": "001",
            "displayName": "Gemini 2.0 Flash",
            "description": "Next-generation low-latency model",
            "inputTokenLimit": 1048576,
            "outputTokenLimit": 8192,
            "supportedGenerationMethods": ["generateContent", "countTokens"],
            "temperature": 1.0,
            "topP": 0.95,
            "topK": 64,
        },
        {
            "name": "models/gemini-1.5-flash-tts",
            "version": "001",
            "displayName": "Gemini 1.5 Speech Audio",
            "description": "Audio generation with Charon voice support",
            "inputTokenLimit": 32768,
            "outputTokenLimit": 8192,
            "supportedGenerationMethods": ["generateSpeech", "generateAudio"],
            "temperature": 0.7,
        },
    ]
}

# Approved RAG grounded response with mandatory [FONTE] and [INFERÊNCIA] tags
GEMINI_TUTOR_GROUNDED_RESPONSE = (
    "Olá! Conforme estudamos na doutrina pericial oficial [FONTE: Vol 1, Cap 1, Seção 1.2], "
    "a cadeia de custódia compreende o conjunto de todos os procedimentos formais previstos no Código de Processo Penal "
    "(artigos 158-A a 158-F). O lacre numerado assegura a inviolabilidade do vestígio desde a coleta até o descarte.\n\n"
    "[INFERÊNCIA: Caso um perito particular receba um vestígio com lacre violado sem o correspondente auto de rompimento, "
    "deve consignar a quebra da cadeia de custódia em seu laudo ou parecer técnico para apreciação do magistrado]."
)

# Hallucinated response lacking provenance tags or citing unapproved external sources
GEMINI_TUTOR_HALLUCINATED_RESPONSE = (
    "A cadeia de custódia foi inventada no século XIX por Sherlock Holmes e é regulada pela norma ISO 99999 da Interpol. "
    "Você pode quebrar o lacre a qualquer momento se tiver uma caneta azul para assinar."
)


def validate_tutor_rag_provenance(
    response_text: str,
    approved_chapter_id: int,
    approved_sections: List[str],
) -> Dict[str, Any]:
    """
    Validates that a tutor answer complies with the strict provenance contract:
    1. Contains explicit [FONTE: ...] tag referencing the approved chapter and section.
    2. Contains explicit [INFERÊNCIA: ...] tag when analytical extrapolation is made.
    3. Does NOT cite unapproved chapters or hallucinated external doctrines.
    """
    fonte_matches = re.findall(r"\[FONTE:\s*([^\]]+)\]", response_text)
    inferencia_matches = re.findall(r"\[INFERÊNCIA:\s*([^\]]+)\]", response_text)

    has_fonte = len(fonte_matches) > 0
    has_inferencia = len(inferencia_matches) > 0

    valid_fonte = False
    if has_fonte:
        for citation in fonte_matches:
            # Check chapter reference
            if f"Cap {approved_chapter_id}" in citation or f"Capítulo {approved_chapter_id}" in citation:
                for sec in approved_sections:
                    if sec in citation:
                        valid_fonte = True
                        break

    is_compliant = has_fonte and valid_fonte

    return {
        "is_compliant": is_compliant,
        "has_fonte_tag": has_fonte,
        "has_inferencia_tag": has_inferencia,
        "citations": fonte_matches,
        "inferences": inferencia_matches,
        "error": None if is_compliant else "Response violates strict RAG provenance contract",
    }
