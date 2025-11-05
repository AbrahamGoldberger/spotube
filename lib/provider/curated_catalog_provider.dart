import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/config/app_config.dart';
import 'package:spotube/models/metadata/metadata.dart';
import 'package:spotube/services/logger/logger.dart';

class CuratedArtist {
  final SpotubeFullArtistObject artist;
  final List<SpotubeFullTrackObject> tracks;

  const CuratedArtist({required this.artist, required this.tracks});
}

class CuratedCatalog {
  final List<CuratedArtist> artists;

  const CuratedCatalog({required this.artists});

  List<SpotubeFullTrackObject> get tracks =>
      artists.expand((artist) => artist.tracks).toList(growable: false);

  SpotubeFullTrackObject? trackById(String id) {
    for (final artist in artists) {
      for (final track in artist.tracks) {
        if (track.id == id) return track;
      }
    }
    return null;
  }
}

List<SpotubeImageObject> _parseImages(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map<String, dynamic>>()
        .map((image) => SpotubeImageObject(
              url: image['url'] as String,
              width: (image['width'] as num?)?.toInt(),
              height: (image['height'] as num?)?.toInt(),
            ))
        .toList();
  }
  return const [];
}

SpotubeAlbumType _parseAlbumType(String? value) {
  return SpotubeAlbumType.values.firstWhere(
    (element) => element.name == value,
    orElse: () => SpotubeAlbumType.album,
  );
}

final curatedCatalogProvider = FutureProvider<CuratedCatalog>((ref) async {
  try {
    final raw = await rootBundle.loadString(kCuratedCatalogAssetPath);
    final dynamic decoded = json.decode(raw);
    if (decoded is! Map<String, dynamic>) {
      return const CuratedCatalog(artists: []);
    }

    final artists = (decoded['artists'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((artist) {
      final artistObject = SpotubeFullArtistObject(
        id: artist['id'] as String,
        name: artist['name'] as String,
        externalUri: artist['externalUri'] as String,
        images: _parseImages(artist['images']),
      );

      final tracks = (artist['tracks'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((track) {
        final album = track['album'] as Map<String, dynamic>?;
        final albumObject = SpotubeSimpleAlbumObject(
          id: album?['id'] as String? ?? track['id'] as String,
          name: album?['name'] as String? ?? track['name'] as String,
          externalUri:
              album?['externalUri'] as String? ?? track['externalUri'] as String,
          artists: [
            SpotubeSimpleArtistObject(
              id: artistObject.id,
              name: artistObject.name,
              externalUri: artistObject.externalUri,
              images: artistObject.images,
            ),
          ],
          images: _parseImages(album?['images']),
          albumType: _parseAlbumType(album?['albumType'] as String?),
          releaseDate: album?['releaseDate'] as String?,
        );

        return SpotubeFullTrackObject(
          id: track['id'] as String,
          name: track['name'] as String,
          externalUri: track['externalUri'] as String,
          artists: [
            SpotubeSimpleArtistObject(
              id: artistObject.id,
              name: artistObject.name,
              externalUri: artistObject.externalUri,
              images: artistObject.images,
            ),
          ],
          album: albumObject,
          durationMs: (track['durationMs'] as num?)?.toInt() ?? 0,
          isrc: track['isrc'] as String? ?? track['id'] as String,
          explicit: track['explicit'] as bool? ?? false,
        );
      }).toList(growable: false) ??
          const <SpotubeFullTrackObject>[];

      return CuratedArtist(artist: artistObject, tracks: tracks);
    }).toList(growable: false) ??
        const <CuratedArtist>[];

    return CuratedCatalog(artists: artists);
  } catch (error, stackTrace) {
    AppLogger.reportError(error, stackTrace);
    return const CuratedCatalog(artists: []);
  }
});
