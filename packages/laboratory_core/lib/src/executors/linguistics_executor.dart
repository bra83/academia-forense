import 'dart:convert';

/// Single speaker utterance in a transcript.
class TranscriptUtterance {
  final int turnIndex;
  final String speaker;
  final DateTime? timestamp;
  final String text;

  const TranscriptUtterance({
    required this.turnIndex,
    required this.speaker,
    this.timestamp,
    required this.text,
  });

  Map<String, dynamic> toMap() => {
    'turnIndex': turnIndex,
    'speaker': speaker,
    'timestamp': timestamp?.toIso8601String(),
    'text': text,
  };
}

/// Marked forensic lexical feature.
class LexicalMarker {
  final String category; // 'hesitation', 'hedging', 'certainty', 'negation'
  final String token;
  final int index;
  final int length;

  const LexicalMarker({
    required this.category,
    required this.token,
    required this.index,
    required this.length,
  });

  Map<String, dynamic> toMap() => {
    'category': category,
    'token': token,
    'index': index,
    'length': length,
  };
}

/// Contradiction detected in testimony or text.
class StatementContradiction {
  final int utteranceIndexA;
  final int utteranceIndexB;
  final String speakerA;
  final String speakerB;
  final String topic;
  final String description;

  const StatementContradiction({
    required this.utteranceIndexA,
    required this.utteranceIndexB,
    required this.speakerA,
    required this.speakerB,
    required this.topic,
    required this.description,
  });
}

/// Word frequency and vocabulary statistics.
class CorpusFrequencyStats {
  final int totalTokens;
  final int uniqueVocabularyCount;
  final Map<String, int> frequencies;
  final List<MapEntry<String, int>> topTokens;

  const CorpusFrequencyStats({
    required this.totalTokens,
    required this.uniqueVocabularyCount,
    required this.frequencies,
    required this.topTokens,
  });
}

/// Executor for Linguística Forense practical tasks (§14.1).
class LinguisticsExecutor {
  /// Known Portuguese lexical markers for forensic discourse analysis.
  static const Map<String, List<String>> markerLexicon = {
    'hesitation': ['é...', 'hum...', 'ahn...', 'tipo assim', 'quer dizer'],
    'hedging': ['acho que', 'se não me engano', 'provavelmente', 'talvez', 'posso estar enganado', 'parece que'],
    'certainty': ['com certeza', 'absoluta certeza', 'sem dúvida', 'afirmo categoricamente', 'garanto'],
    'negation': ['nunca', 'jamais', 'de forma alguma', 'não estive', 'não vi'],
  };

  /// Parses transcript text formatted as "[HH:MM:SS] SPEAKER: text" or "SPEAKER: text".
  static List<TranscriptUtterance> parseTranscript(String transcriptText) {
    final lines = const LineSplitter().convert(transcriptText)
        .where((l) => l.trim().isNotEmpty)
        .toList();
    final utterances = <TranscriptUtterance>[];

    final timestampSpeakerRegex = RegExp(r'^(?:\[([^\]]+)\]\s*)?([A-Za-z0-9_ -]+):\s*(.*)$');

    var turnCounter = 0;
    for (final line in lines) {
      final match = timestampSpeakerRegex.firstMatch(line.trim());
      if (match != null) {
        final timeRaw = match.group(1);
        final speaker = match.group(2)!.trim();
        final text = match.group(3)!.trim();
        DateTime? parsedTime;
        if (timeRaw != null) {
          // If ISO format or time
          if (timeRaw.contains('T')) {
            parsedTime = DateTime.tryParse(timeRaw);
          } else {
            // Assume today with HH:mm:ss
            final parts = timeRaw.split(':').map((p) => int.tryParse(p) ?? 0).toList();
            final now = DateTime.now();
            if (parts.length >= 2) {
              parsedTime = DateTime(
                now.year,
                now.month,
                now.day,
                parts[0],
                parts[1],
                parts.length > 2 ? parts[2] : 0,
              );
            }
          }
        }

        utterances.add(
          TranscriptUtterance(
            turnIndex: turnCounter++,
            speaker: speaker,
            timestamp: parsedTime,
            text: text,
          ),
        );
      } else {
        // Line continuation or unattributed text
        if (utterances.isNotEmpty) {
          final last = utterances.removeLast();
          utterances.add(
            TranscriptUtterance(
              turnIndex: last.turnIndex,
              speaker: last.speaker,
              timestamp: last.timestamp,
              text: '${last.text} ${line.trim()}',
            ),
          );
        } else {
          utterances.add(
            TranscriptUtterance(
              turnIndex: turnCounter++,
              speaker: 'UNKNOWN',
              text: line.trim(),
            ),
          );
        }
      }
    }

    return utterances;
  }

  /// Identifies lexical markers (hesitation, hedging, certainty, negation) in text.
  static List<LexicalMarker> analyzeLexicalMarkers(String text) {
    final lower = text.toLowerCase();
    final markers = <LexicalMarker>[];

    markerLexicon.forEach((category, tokens) {
      for (final tok in tokens) {
        var start = 0;
        while (true) {
          final found = lower.indexOf(tok, start);
          if (found == -1) break;
          markers.add(
            LexicalMarker(
              category: category,
              token: text.substring(found, found + tok.length),
              index: found,
              length: tok.length,
            ),
          );
          start = found + tok.length;
        }
      }
    });

    markers.sort((a, b) => a.index.compareTo(b.index));
    return markers;
  }

  /// Calculates word frequency corpus statistics.
  static CorpusFrequencyStats calculateCorpusFrequencies(String text) {
    // Tokenize word characters
    final wordRegex = RegExp(r'[a-zA-ZáàâãéèêíïóôõöúçñÁÀÂÃÉÈÊÍÏÓÔÕÖÚÇÑ0-9]+');
    final matches = wordRegex.allMatches(text.toLowerCase());
    final freqMap = <String, int>{};
    var totalCount = 0;

    for (final m in matches) {
      final token = m.group(0)!;
      totalCount++;
      freqMap[token] = (freqMap[token] ?? 0) + 1;
    }

    final sortedEntries = freqMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return CorpusFrequencyStats(
      totalTokens: totalCount,
      uniqueVocabularyCount: freqMap.length,
      frequencies: freqMap,
      topTokens: sortedEntries.take(20).toList(),
    );
  }

  /// Detects direct logical or affirmative vs negative contradictions on defined topics.
  static List<StatementContradiction> findContradictions(List<TranscriptUtterance> utterances) {
    final contradictions = <StatementContradiction>[];

    // Look for statements from same or different speakers asserting presence vs denying presence
    for (var i = 0; i < utterances.length; i++) {
      for (var j = i + 1; j < utterances.length; j++) {
        final a = utterances[i];
        final b = utterances[j];
        final aText = a.text.toLowerCase();
        final bText = b.text.toLowerCase();

        // Pattern 1: Present vs Absent
        final aAssertsPresence = aText.contains('estive no local') || aText.contains('fui até lá') || aText.contains('estava presente');
        final bDeniesPresence = bText.contains('nunca estive no local') || bText.contains('jamais fui até lá') || bText.contains('não estava presente');

        if (aAssertsPresence && bDeniesPresence) {
          contradictions.add(
            StatementContradiction(
              utteranceIndexA: a.turnIndex,
              utteranceIndexB: b.turnIndex,
              speakerA: a.speaker,
              speakerB: b.speaker,
              topic: 'Presença no Local dos Fatos',
              description: 'Declaração ${a.speaker} afirma presença ("${a.text}"), enquanto ${b.speaker} nega peremptoriamente ("${b.text}").',
            ),
          );
        }

        // Pattern 2: Possession of key evidence / phone
        final aHasPhone = aText.contains('estava com o celular') || aText.contains('portava o aparelho');
        final bLostPhone = bText.contains('havia perdido o celular') || bText.contains('não estava com o aparelho');

        if (aHasPhone && bLostPhone) {
          contradictions.add(
            StatementContradiction(
              utteranceIndexA: a.turnIndex,
              utteranceIndexB: b.turnIndex,
              speakerA: a.speaker,
              speakerB: b.speaker,
              topic: 'Posse do Dispositivo Telefônico',
              description: 'Contradição sobre posse do dispositivo no horário dos eventos investigados.',
            ),
          );
        }
      }
    }

    return contradictions;
  }
}
