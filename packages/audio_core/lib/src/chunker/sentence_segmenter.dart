import 'dart:async';

/// Represents a segmented audio chunk with paragraph and utterance metadata.
class AudioChunk {
  final String id;
  final int index;
  final int paragraphIndex;
  final String text;
  final int sentenceCount;

  const AudioChunk({
    required this.id,
    required this.index,
    required this.paragraphIndex,
    required this.text,
    required this.sentenceCount,
  });

  int get length => text.length;

  @override
  String toString() => 'AudioChunk($id, idx: $index, para: $paragraphIndex, len: $length)';
}

/// Result of segmenting text, providing immediate access to the first chunk (§12.4).
class SegmentedTextResult {
  final List<AudioChunk> chunks;
  final AudioChunk? firstChunk;
  final int totalCharacters;

  const SegmentedTextResult({
    required this.chunks,
    this.firstChunk,
    required this.totalCharacters,
  });

  bool get isEmpty => chunks.isEmpty;
  bool get isNotEmpty => chunks.isNotEmpty;
  int get length => chunks.length;

  List<String> get chunkTexts => chunks.map((c) => c.text).toList();
}

/// Sentence Segmenter and Chunk Manager for Kokoro Sherpa-ONNX & Gemini TTS (§12.2, §12.3).
class SentenceSegmenter {
  static const int minChars = 250;
  static const int targetChars = 450;
  static const int maxChars = 650;
  static const int maxNumSentences = 2;
  static const double silenceScale = 0.06;
  static const int numThreads = 4;

  /// Segments raw text into speech chunks respecting character bounds and sentence constraints.
  static SegmentedTextResult segment(
    String text, {
    int minLength = minChars,
    int maxLength = maxChars,
    int maxSentences = maxNumSentences,
    int paragraphIndex = 0,
    String idPrefix = 'chk',
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const SegmentedTextResult(chunks: [], firstChunk: null, totalCharacters: 0);
    }

    final rawSentences = _splitIntoSentences(trimmed);
    final normalizedSentences = <String>[];

    // Ensure no individual sentence exceeds maxLength by splitting on word boundaries
    for (final s in rawSentences) {
      if (s.length > maxLength) {
        normalizedSentences.addAll(_splitOversizedSentence(s, maxLength));
      } else {
        normalizedSentences.add(s);
      }
    }

    final chunks = <AudioChunk>[];
    var currentSentences = <String>[];
    var currentLength = 0;
    var chunkCounter = 0;

    for (final sentence in normalizedSentences) {
      final sentenceLen = sentence.length;
      final prospectiveLength = currentLength == 0 ? sentenceLen : currentLength + 1 + sentenceLen;

      final wouldExceedMaxChars = prospectiveLength > maxLength;
      final wouldExceedSentences = currentSentences.length >= maxSentences;

      if (currentSentences.isNotEmpty && (wouldExceedMaxChars || wouldExceedSentences)) {
        final chunkText = currentSentences.join(' ');
        final chunk = AudioChunk(
          id: '${idPrefix}_${chunkCounter.toString().padLeft(4, '0')}',
          index: chunkCounter,
          paragraphIndex: paragraphIndex,
          text: chunkText,
          sentenceCount: currentSentences.length,
        );
        chunks.add(chunk);
        chunkCounter++;

        currentSentences = [];
        currentLength = 0;
      }

      currentSentences.add(sentence);
      currentLength = currentLength == 0 ? sentenceLen : currentLength + 1 + sentenceLen;
    }

    if (currentSentences.isNotEmpty) {
      final chunkText = currentSentences.join(' ');
      final chunk = AudioChunk(
        id: '${idPrefix}_${chunkCounter.toString().padLeft(4, '0')}',
        index: chunkCounter,
        paragraphIndex: paragraphIndex,
        text: chunkText,
        sentenceCount: currentSentences.length,
      );
      chunks.add(chunk);
    }

    return SegmentedTextResult(
      chunks: chunks,
      firstChunk: chunks.isNotEmpty ? chunks.first : null,
      totalCharacters: trimmed.length,
    );
  }

  /// Convenience method returning list of string chunks.
  static List<String> segmentText(
    String text, {
    int minLength = minChars,
    int maxLength = maxChars,
    int maxSentences = maxNumSentences,
  }) {
    return segment(
      text,
      minLength: minLength,
      maxLength: maxLength,
      maxSentences: maxSentences,
    ).chunkTexts;
  }

  /// Emits chunks as an asynchronous stream for low-latency cold start playback (§12.4).
  static Stream<AudioChunk> segmentStream(
    String text, {
    int paragraphIndex = 0,
    String idPrefix = 'chk',
  }) async* {
    final result = segment(text, paragraphIndex: paragraphIndex, idPrefix: idPrefix);
    for (final chunk in result.chunks) {
      yield chunk;
    }
  }

  /// Splits text into individual sentences based on punctuation boundaries: . ! ? ; : and newlines.
  static List<String> _splitIntoSentences(String text) {
    // Regex matching sentence endings followed by whitespace
    final pattern = RegExp(r'(?<=[.!?;\n])\s+');
    final rawList = text.split(pattern);

    final result = <String>[];
    for (final raw in rawList) {
      final clean = raw.trim();
      if (clean.isNotEmpty) {
        result.add(clean);
      }
    }
    return result;
  }

  /// Splits an oversized sentence cleanly on word boundaries without truncating words.
  static List<String> _splitOversizedSentence(String sentence, int maxLength) {
    final words = sentence.split(RegExp(r'\s+'));
    final result = <String>[];
    var currentWords = <String>[];
    var currentLength = 0;

    for (final word in words) {
      if (word.isEmpty) continue;
      final prospective = currentLength == 0 ? word.length : currentLength + 1 + word.length;

      if (currentWords.isNotEmpty && prospective > maxLength) {
        result.add(currentWords.join(' '));
        currentWords = [];
        currentLength = 0;
      }

      currentWords.add(word);
      currentLength = currentLength == 0 ? word.length : currentLength + 1 + word.length;
    }

    if (currentWords.isNotEmpty) {
      result.add(currentWords.join(' '));
    }

    return result;
  }
}
