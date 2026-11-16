import 'dart:convert';
import 'dart:typed_data';
import 'package:audio_core/audio_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WavHeaderBuilder Unit Tests (§13, §21)', () {
    test('generated header is exactly 44 bytes', () {
      final header = WavHeaderBuilder.createWavHeader(pcmDataLength: 1024, sampleRate: 24000);
      expect(header.length, 44);
    });

    test('header magic constants match RIFF, WAVE, fmt , and data', () {
      final header = WavHeaderBuilder.createWavHeader(pcmDataLength: 2048);
      expect(ascii.decode(header.sublist(0, 4)), 'RIFF');
      expect(ascii.decode(header.sublist(8, 12)), 'WAVE');
      expect(ascii.decode(header.sublist(12, 16)), 'fmt ');
      expect(ascii.decode(header.sublist(36, 40)), 'data');
    });

    test('mathematical rates and block alignments are strictly correct', () {
      const sampleRate = 24000;
      const channels = 1;
      const bits = 16;
      const expectedByteRate = sampleRate * channels * (bits ~/ 8); // 48000
      const expectedBlockAlign = channels * (bits ~/ 8); // 2

      final header = WavHeaderBuilder.createWavHeader(
        pcmDataLength: 5000,
        sampleRate: sampleRate,
        numChannels: channels,
        bitsPerSample: bits,
      );

      final byteData = ByteData.sublistView(header);
      final sampleRateFound = byteData.getUint32(24, Endian.little);
      final byteRateFound = byteData.getUint32(28, Endian.little);
      final blockAlignFound = byteData.getUint16(32, Endian.little);
      final bitsFound = byteData.getUint16(34, Endian.little);

      expect(sampleRateFound, sampleRate);
      expect(byteRateFound, expectedByteRate);
      expect(blockAlignFound, expectedBlockAlign);
      expect(bitsFound, bits);
    });

    test('packagePcmToWav produces valid 44-byte header + PCM payload', () {
      final pcm = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7]);
      final wav = WavHeaderBuilder.packagePcmToWav(pcm);

      expect(wav.length, 44 + pcm.length);
      final info = WavHeaderBuilder.parseAndValidateWav(wav);
      expect(info.sampleRate, 24000);
      expect(info.channels, 1);
      expect(info.dataSize, pcm.length);
      expect(info.totalSize, 44 + pcm.length);
    });

    test('base64PcmToWav converts base64 PCM into playable WAV', () {
      final pcm = Uint8List.fromList(
        List.generate(10, (_) => [0x00, 0x00, 0x10, 0x00, 0x20, 0x00]).expand((e) => e).toList(),
      );
      final b64 = base64Encode(pcm);

      final wav = WavHeaderBuilder.base64PcmToWav(b64, sampleRate: 24000);
      expect(wav.length, 44 + pcm.length);

      final info = WavHeaderBuilder.parseAndValidateWav(wav);
      expect(info.sampleRate, 24000);
      expect(info.channels, 1);
      expect(info.bitsPerSample, 16);
      expect(info.dataSize, pcm.length);
    });

    test('rejects truncated WAV buffer (< 44 bytes)', () {
      final truncated = Uint8List.fromList([0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0]); // only 8 bytes
      expect(
        () => WavHeaderBuilder.parseAndValidateWav(truncated),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Truncated WAV'))),
      );
    });

    test('rejects missing RIFF or WAVE magic constants', () {
      final zeros = Uint8List(44);
      expect(
        () => WavHeaderBuilder.parseAndValidateWav(zeros),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains("Missing 'RIFF'"))),
      );
    });

    test('rejects corrupted base64 audio payload', () {
      expect(
        () => WavHeaderBuilder.base64PcmToWav('NotValidBase64!!!@@@###'),
        throwsFormatException,
      );
      expect(
        () => WavHeaderBuilder.base64PcmToWav('==brokenPadding'),
        throwsFormatException,
      );
    });

    test('rejects empty or zero-byte audio payload', () {
      expect(
        () => WavHeaderBuilder.packagePcmToWav(Uint8List(0)),
        throwsArgumentError,
      );
      expect(
        () => WavHeaderBuilder.base64PcmToWav(''),
        throwsFormatException,
      );
    });
  });
}
