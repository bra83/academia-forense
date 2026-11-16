import 'dart:convert';
import 'dart:typed_data';

/// Metadata extracted from a parsed RIFF/WAVE header.
class WavHeaderInfo {
  final int sampleRate;
  final int channels;
  final int bitsPerSample;
  final int byteRate;
  final int blockAlign;
  final int dataSize;
  final int totalSize;

  const WavHeaderInfo({
    required this.sampleRate,
    required this.channels,
    required this.bitsPerSample,
    required this.byteRate,
    required this.blockAlign,
    required this.dataSize,
    required this.totalSize,
  });

  @override
  String toString() =>
      'WavHeaderInfo(rate: ${sampleRate}Hz, ch: $channels, bits: $bitsPerSample, bytes: $dataSize)';
}

/// Constructs and validates strictly compliant 44-byte RIFF/WAVE headers (§13, §21).
class WavHeaderBuilder {
  static const int headerLength = 44;
  static const int defaultSampleRate = 24000;
  static const int defaultNumChannels = 1;
  static const int defaultBitsPerSample = 16;

  /// Creates a strictly compliant 44-byte RIFF/WAVE header for linear PCM audio.
  static Uint8List createWavHeader({
    required int pcmDataLength,
    int sampleRate = defaultSampleRate,
    int numChannels = defaultNumChannels,
    int bitsPerSample = defaultBitsPerSample,
  }) {
    if (pcmDataLength < 0) {
      throw ArgumentError.value(pcmDataLength, 'pcmDataLength', 'PCM data length cannot be negative');
    }
    if (sampleRate <= 0) {
      throw ArgumentError.value(sampleRate, 'sampleRate', 'Sample rate must be positive');
    }
    if (numChannels <= 0) {
      throw ArgumentError.value(numChannels, 'numChannels', 'Number of channels must be positive');
    }
    if (bitsPerSample <= 0 || bitsPerSample % 8 != 0) {
      throw ArgumentError.value(bitsPerSample, 'bitsPerSample', 'Bits per sample must be positive multiple of 8');
    }

    final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final blockAlign = numChannels * (bitsPerSample ~/ 8);
    final chunkSize = 36 + pcmDataLength;

    final header = ByteData(headerLength);

    // 0..3: "RIFF" chunk descriptor
    header.setUint8(0, 0x52); // 'R'
    header.setUint8(1, 0x49); // 'I'
    header.setUint8(2, 0x46); // 'F'
    header.setUint8(3, 0x46); // 'F'

    // 4..7: ChunkSize = 36 + SubChunk2Size
    header.setUint32(4, chunkSize, Endian.little);

    // 8..11: "WAVE" format
    header.setUint8(8, 0x57);  // 'W'
    header.setUint8(9, 0x41);  // 'A'
    header.setUint8(10, 0x56); // 'V'
    header.setUint8(11, 0x45); // 'E'

    // 12..15: "fmt " subchunk
    header.setUint8(12, 0x66); // 'f'
    header.setUint8(13, 0x6d); // 'm'
    header.setUint8(14, 0x74); // 't'
    header.setUint8(15, 0x20); // ' '

    // 16..19: Subchunk1Size = 16 for linear PCM
    header.setUint32(16, 16, Endian.little);

    // 20..21: AudioFormat = 1 (PCM uncompressed)
    header.setUint16(20, 1, Endian.little);

    // 22..23: NumChannels
    header.setUint16(22, numChannels, Endian.little);

    // 24..27: SampleRate (e.g. 24000)
    header.setUint32(24, sampleRate, Endian.little);

    // 28..31: ByteRate = SampleRate * NumChannels * BitsPerSample / 8 (e.g. 48000)
    header.setUint32(28, byteRate, Endian.little);

    // 32..33: BlockAlign = NumChannels * BitsPerSample / 8 (e.g. 2)
    header.setUint16(32, blockAlign, Endian.little);

    // 34..35: BitsPerSample (e.g. 16)
    header.setUint16(34, bitsPerSample, Endian.little);

    // 36..39: "data" subchunk identifier
    header.setUint8(36, 0x64); // 'd'
    header.setUint8(37, 0x61); // 'a'
    header.setUint8(38, 0x74); // 't'
    header.setUint8(39, 0x61); // 'a'

    // 40..43: Subchunk2Size = pcmDataLength
    header.setUint32(40, pcmDataLength, Endian.little);

    assert(header.lengthInBytes == headerLength, 'Header must be exactly 44 bytes');
    return header.buffer.asUint8List();
  }

  /// Packages raw PCM bytes into a valid, playable RIFF/WAVE byte buffer.
  static Uint8List packagePcmToWav(
    Uint8List pcmBytes, {
    int sampleRate = defaultSampleRate,
    int numChannels = defaultNumChannels,
    int bitsPerSample = defaultBitsPerSample,
  }) {
    if (pcmBytes.isEmpty) {
      throw ArgumentError('Empty audio payload received; cannot package zero-byte PCM');
    }
    final header = createWavHeader(
      pcmDataLength: pcmBytes.length,
      sampleRate: sampleRate,
      numChannels: numChannels,
      bitsPerSample: bitsPerSample,
    );

    final wavBuffer = Uint8List(headerLength + pcmBytes.length);
    wavBuffer.setRange(0, headerLength, header);
    wavBuffer.setRange(headerLength, wavBuffer.length, pcmBytes);
    return wavBuffer;
  }

  /// Decodes base64-encoded PCM and synthesizes a complete RIFF/WAVE audio file.
  static Uint8List base64PcmToWav(
    String base64String, {
    int sampleRate = defaultSampleRate,
    int numChannels = defaultNumChannels,
    int bitsPerSample = defaultBitsPerSample,
  }) {
    final cleanBase64 = base64String.trim();
    if (cleanBase64.isEmpty) {
      throw FormatException('Empty base64 audio payload received');
    }

    final Uint8List rawPcm;
    try {
      rawPcm = base64Decode(cleanBase64);
    } catch (e) {
      throw FormatException('Corrupted base64 audio payload: $e');
    }

    if (rawPcm.isEmpty) {
      throw ArgumentError('Decoded PCM buffer is zero bytes');
    }

    return packagePcmToWav(
      rawPcm,
      sampleRate: sampleRate,
      numChannels: numChannels,
      bitsPerSample: bitsPerSample,
    );
  }

  /// Parses and strictly validates a RIFF/WAVE header.
  static WavHeaderInfo parseAndValidateWav(Uint8List wavBytes) {
    if (wavBytes.length < headerLength) {
      throw const FormatException('Truncated WAV buffer: fewer than 44 bytes');
    }

    final byteData = ByteData.sublistView(wavBytes);

    // Validate RIFF magic
    final riff = ascii.decode(wavBytes.sublist(0, 4));
    if (riff != 'RIFF') {
      throw FormatException("Missing 'RIFF' chunk descriptor; got '$riff'");
    }

    // Validate WAVE magic
    final wave = ascii.decode(wavBytes.sublist(8, 12));
    if (wave != 'WAVE') {
      throw FormatException("Missing 'WAVE' format identifier; got '$wave'");
    }

    // Validate fmt magic
    final fmt = ascii.decode(wavBytes.sublist(12, 16));
    if (fmt != 'fmt ') {
      throw FormatException("Missing 'fmt ' subchunk; got '$fmt'");
    }

    final audioFormat = byteData.getUint16(20, Endian.little);
    if (audioFormat != 1) {
      throw FormatException('Unsupported audio format $audioFormat (expected 1 for linear PCM)');
    }

    final numChannels = byteData.getUint16(22, Endian.little);
    final sampleRate = byteData.getUint32(24, Endian.little);
    final byteRate = byteData.getUint32(28, Endian.little);
    final blockAlign = byteData.getUint16(32, Endian.little);
    final bitsPerSample = byteData.getUint16(34, Endian.little);

    // Validate data magic
    final dataMagic = ascii.decode(wavBytes.sublist(36, 40));
    if (dataMagic != 'data') {
      throw FormatException("Missing 'data' subchunk; got '$dataMagic'");
    }

    final dataSize = byteData.getUint32(40, Endian.little);

    return WavHeaderInfo(
      sampleRate: sampleRate,
      channels: numChannels,
      bitsPerSample: bitsPerSample,
      byteRate: byteRate,
      blockAlign: blockAlign,
      dataSize: dataSize,
      totalSize: wavBytes.length,
    );
  }
}
