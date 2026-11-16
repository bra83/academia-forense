/// Academia Forense Audio Core Package
///
/// Implements Milestone 4 (Lote E — Dual Voice System: Kokoro Braseiro + Gemini Charon).
///
/// Exports:
/// - Sentence segmenter and chunker (§12.2, §12.3)
/// - 44-byte RIFF/WAVE header synthesis (§13, §21)
/// - Motor A (Kokoro Braseiro Sherpa-ONNX local bridge) (§11, §12)
/// - Motor B (Gemini Charon online TTS REST client) (§11, §13)
/// - Unified AudioPlaybackController & Highlight Synchronization (§12.5, §12.6, §22)
library audio_core;

export 'package:android_tts_bridge/android_tts_bridge.dart'
    show
        AndroidTtsBridge,
        SherpaOnnxPackages,
        TtsVoiceInfo,
        TtsBridgeEvent,
        TtsStartEvent,
        TtsDoneEvent,
        TtsErrorEvent;

export 'src/chunker/sentence_segmenter.dart'
    show
        AudioChunk,
        SegmentedTextResult,
        SentenceSegmenter;

export 'src/wav/wav_header_builder.dart'
    show
        WavHeaderInfo,
        WavHeaderBuilder;

export 'src/engines/motor_a_kokoro.dart'
    show
        MotorPlaybackState,
        MotorProgressEvent,
        MotorAKokoroController;

export 'src/engines/motor_b_gemini.dart'
    show
        GeminiTtsException,
        GeminiAuthException,
        GeminiQuotaExceededException,
        GeminiModelNotFoundException,
        GeminiTtsPayloadBuilder,
        GeminiSpeechChunk,
        GeminiTtsClient,
        MotorBGeminiController;

export 'src/controller/audio_player_controller.dart'
    show
        AudioEngine,
        PlaybackStatus,
        HighlightState,
        AudioEngineFailure,
        AudioCoreContract,
        AudioPlaybackController;
