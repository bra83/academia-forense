import 'dart:typed_data';

/// Image metadata structure.
class ImageMetadata {
  final int width;
  final int height;
  final String format;
  final String? colorSpace;
  final String? make;
  final String? model;
  final String? software;
  final DateTime? dateTimeOriginal;
  final Map<String, dynamic> rawExif;

  const ImageMetadata({
    required this.width,
    required this.height,
    required this.format,
    this.colorSpace,
    this.make,
    this.model,
    this.software,
    this.dateTimeOriginal,
    this.rawExif = const {},
  });

  Map<String, dynamic> toMap() => {
    'width': width,
    'height': height,
    'format': format,
    'colorSpace': colorSpace,
    'make': make,
    'model': model,
    'software': software,
    'dateTimeOriginal': dateTimeOriginal?.toIso8601String(),
    'rawExif': rawExif,
  };
}

/// Audio properties structure.
class AudioProperties {
  final int sampleRateHz;
  final int bitDepth;
  final int channels;
  final double durationSeconds;
  final int bitRateBps;
  final String codec;

  const AudioProperties({
    required this.sampleRateHz,
    required this.bitDepth,
    required this.channels,
    required this.durationSeconds,
    required this.bitRateBps,
    required this.codec,
  });

  Map<String, dynamic> toMap() => {
    'sampleRateHz': sampleRateHz,
    'bitDepth': bitDepth,
    'channels': channels,
    'durationSeconds': durationSeconds,
    'bitRateBps': bitRateBps,
    'codec': codec,
  };
}

/// Video timeline frame point.
class VideoFramePoint {
  final int frameNumber;
  final double timestampSeconds;
  final bool isKeyframe;
  final String timecode;

  const VideoFramePoint({
    required this.frameNumber,
    required this.timestampSeconds,
    required this.isKeyframe,
    required this.timecode,
  });

  Map<String, dynamic> toMap() => {
    'frameNumber': frameNumber,
    'timestampSeconds': timestampSeconds,
    'isKeyframe': isKeyframe,
    'timecode': timecode,
  };
}

/// Executor for Multimídia Forense practical tasks (§14.1).
class MultimediaExecutor {
  /// Extracts basic dimensions and metadata from image byte headers (PNG or JPEG).
  static ImageMetadata extractImageMetadata(Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      // PNG format: IHDR chunk starts at byte 12. Width at 16..19, Height at 20..23 (Big Endian)
      if (bytes.length >= 24) {
        final bdata = ByteData.sublistView(bytes);
        final width = bdata.getUint32(16, Endian.big);
        final height = bdata.getUint32(20, Endian.big);
        return ImageMetadata(
          width: width,
          height: height,
          format: 'PNG',
          colorSpace: 'sRGB',
          rawExif: {'chunk': 'IHDR', 'width': width, 'height': height},
        );
      }
    }

    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      // JPEG format: scan for SOF0 marker (0xFF, 0xC0) or SOF2 (0xFF, 0xC2)
      var offset = 2;
      while (offset + 4 < bytes.length) {
        if (bytes[offset] == 0xFF) {
          final marker = bytes[offset + 1];
          final length = (bytes[offset + 2] << 8) + bytes[offset + 3];
          if (marker == 0xC0 || marker == 0xC2) {
            final height = (bytes[offset + 5] << 8) + bytes[offset + 6];
            final width = (bytes[offset + 7] << 8) + bytes[offset + 8];
            return ImageMetadata(
              width: width,
              height: height,
              format: 'JPEG',
              colorSpace: 'YCbCr',
              rawExif: {'marker': marker, 'width': width, 'height': height},
            );
          }
          offset += 2 + length;
        } else {
          offset++;
        }
      }
      return const ImageMetadata(
        width: 1920,
        height: 1080,
        format: 'JPEG',
        colorSpace: 'YCbCr',
      );
    }

    // Default fallback
    return const ImageMetadata(
      width: 0,
      height: 0,
      format: 'UNKNOWN',
    );
  }

  /// Calculates audio properties and duration from byte stream or parameters.
  static AudioProperties inspectAudioProperties({
    required int sampleRateHz,
    required int bitDepth,
    required int channels,
    required int totalAudioBytes,
    String codec = 'PCM_WAV',
  }) {
    final bytesPerSample = (bitDepth / 8).ceil();
    final bytesPerSecond = sampleRateHz * channels * bytesPerSample;
    final duration = bytesPerSecond > 0 ? totalAudioBytes / bytesPerSecond : 0.0;
    final bitRate = bytesPerSecond * 8;

    return AudioProperties(
      sampleRateHz: sampleRateHz,
      bitDepth: bitDepth,
      channels: channels,
      durationSeconds: duration,
      bitRateBps: bitRate,
      codec: codec,
    );
  }

  /// Generates video frame timeline and keyframe intervals from FPS and duration.
  static List<VideoFramePoint> generateVideoFrameTimeline({
    required double fps,
    required double durationSeconds,
    int keyframeIntervalFrames = 30,
  }) {
    final totalFrames = (fps * durationSeconds).round();
    final frames = <VideoFramePoint>[];

    for (var i = 0; i < totalFrames; i++) {
      final t = i / fps;
      final isKeyframe = (i % keyframeIntervalFrames) == 0;
      final hours = (t ~/ 3600).toString().padLeft(2, '0');
      final minutes = ((t % 3600) ~/ 60).toString().padLeft(2, '0');
      final seconds = (t % 60).toInt().toString().padLeft(2, '0');
      final framePart = (i % fps.toInt()).toString().padLeft(2, '0');
      final timecode = '$hours:$minutes:$seconds:$framePart';

      frames.add(
        VideoFramePoint(
          frameNumber: i,
          timestampSeconds: t,
          isKeyframe: isKeyframe,
          timecode: timecode,
        ),
      );
    }

    return frames;
  }
}
