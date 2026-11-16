# Guia de Compilação, Implantação e Recuperação de Dados — Academia Forense

**Data:** 16/11/2026  
**Repositório Dedicado:** `https://github.com/bra83/academia-forense` (isolado de `bra83/braseirobuild`)

---

## 1. Compilação para Android (Samsung Galaxy A57)

### Pré-requisitos
- Flutter SDK `3.24.5+` (Dart `3.5.4+`)
- Android SDK (`compileSdk 34`, `minSdk 26`, JDK 17)
- Motor TTS Neural Local opcional instalado no aparelho: **Sherpa-ONNX / Kokoro (Braseiro)** (`com.k2fsa.sherpa.onnx.tts.engine` ou `com.k2fsa.sherpa.onnx.tts.engine.debug`)

### Comandos de Compilação Android
```bash
cd apps/academia_flutter
flutter pub get

# Gerar APK de Debug para instalação direta via USB/ADB no Galaxy A57
flutter build apk --debug

# Gerar APK de Release otimizado (arm64-v8a para Samsung Galaxy A57)
flutter build apk --release --target-platform android-arm64
```

---

## 2. Compilação para Windows Desktop (Notebook 16 GB RAM)

### Pré-requisitos no Windows 10/11 (64-bit)
- Flutter SDK `3.24.5+`
- Visual Studio 2022 com carga de trabalho **"Desenvolvimento para desktop com C++"**

### Comandos de Compilação Windows
```bash
cd apps/academia_flutter
flutter config --enable-windows-desktop
flutter pub get
flutter build windows --release
```
O executável nativo e as DLLs serão gerados em:
`apps\academia_flutter\build\windows\x64\runner\Release\academia_flutter.exe`

---

## 3. Compilação para Linux Desktop (Verificada Localmente)

```bash
source ./env-setup.sh
cd apps/academia_flutter
flutter build linux --release
```
Binário nativo compilado em:
`apps/academia_flutter/build/linux/x64/release/bundle/academia_flutter`

---

## 4. Configuração do Motor de Voz Local (Braseiro Kokoro) e Gemini TTS (`Charon`)

1. **No Android (Samsung Galaxy A57)**:
   - Instale o APK do serviço TTS `com.k2fsa.sherpa.onnx.tts.engine` (Braseiro / Kokoro pt-BR).
   - Na aba **Estudar** ou **Biblioteca** da Academia Forense, selecione o chip **`Braseiro Kokoro — Local`**.
   - O plugin nativo `AndroidTtsBridgePlugin.kt` detecta automaticamente o pacote, configura `maxNumSentences = 2`, `silenceScale = 0.06`, `numThreads = 4`, segmenta o texto em blocos de `250 a 650` caracteres (alvo `450`) e encadeia a reprodução pelo callback `UtteranceProgressListener.onDone`.
2. **No Windows ou Android Online (Gemini TTS — Voz `Charon`)**:
   - Na aba **Meu Espaço**, configure sua chave Gemini API (BYOK) no cofre seguro.
   - Selecione **`Gemini TTS — Online (Charon)`**. O motor sintetiza áudio via API Gemini com a voz oficial `Charon`, constrói o cabeçalho RIFF/WAVE canônico de 44 bytes (`24 kHz`, `16-bit`, `mono`) e armazena no cache local auditável.

---

## 5. Backup, Exportação e Recuperação de Progresso (§17 e §20)

- **Exportação de Portfólio Assinado (`%PDF-1.4` + SHA-256)**: Na aba **Meu Espaço**, clique em **`Exportar Relatório PDF`**. O aplicativo gera o documento PDF binário contendo o resumo de competências, a assinatura criptográfica SHA-256 verificável e a declaração obrigatória de documento educacional interno.
- **Backup Relacional Completo (JSON Topológico)**: O pacote `persistence_core` exporta e restaura todas as 24 tabelas SQLite respeitando a ordem topológica de chaves estrangeiras (`DatabaseBackupService.exportFullBackupJson()` / `restoreFromBackupJson()`), garantindo perda zero de anotações, destaques, avaliações e laboratórios ao trocar de dispositivo.
