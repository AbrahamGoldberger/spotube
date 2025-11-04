import 'dart:typed_data';

class Metadata {
  const Metadata({
    this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.year,
    this.durationMs,
    this.fileSize,
    this.picture,
  });

  final String? title;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final int? year;
  final double? durationMs;
  final BigInt? fileSize;
  final Picture? picture;
}

class Picture {
  const Picture({required this.data, required this.mimeType});

  final Uint8List data;
  final String mimeType;
}

class MetadataGod {
  static Future<void> initialize() async {}

  static Future<Metadata> readMetadata({required String file}) async {
    return const Metadata();
  }

  static Future<void> writeMetadata({
    required String file,
    required Metadata metadata,
  }) async {}
}

class FrbException implements Exception {
  const FrbException([this.message]);

  final String? message;

  @override
  String toString() => 'FrbException: ${message ?? ''}'.trim();
}
