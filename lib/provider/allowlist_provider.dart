import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/config/app_config.dart';
import 'package:spotube/models/metadata/metadata.dart';
import 'package:spotube/services/logger/logger.dart';

class AllowList {
  final bool enabled;
  final Set<String> artists;
  final Set<String> tracks;

  const AllowList({
    required this.enabled,
    required this.artists,
    required this.tracks,
  });

  static const AllowList disabled = AllowList(
    enabled: false,
    artists: <String>{},
    tracks: <String>{},
  );

  bool allows(SpotubeTrackObject track) {
    if (!enabled) return true;
    if (tracks.contains(track.id)) {
      return true;
    }
    return track.artists.any((artist) => artists.contains(artist.id));
  }

  Iterable<SpotubeTrackObject> filter(
    Iterable<SpotubeTrackObject> candidates,
  ) {
    if (!enabled) return candidates;
    return candidates.where(allows);
  }
}

final _allowListStateProvider = FutureProvider<AllowList>((ref) async {
  if (!artistAllowListEnabled) {
    return AllowList.disabled;
  }

  try {
    final configJson = await rootBundle.loadString(kAllowListAssetPath);
    final dynamic parsed = json.decode(configJson);
    if (parsed is! Map<String, dynamic>) {
      return AllowList.disabled;
    }

    Set<String> _asSet(dynamic value) {
      if (value is List) {
        return value.whereType<String>().toSet();
      }
      return <String>{};
    }

    return AllowList(
      enabled: true,
      artists: _asSet(parsed['artists']),
      tracks: _asSet(parsed['tracks']),
    );
  } catch (error, stackTrace) {
    AppLogger.reportError(error, stackTrace);
    return AllowList.disabled;
  }
});

final allowListProvider = Provider<AllowList>((ref) {
  final allowList = ref.watch(_allowListStateProvider);
  return allowList.maybeWhen(
    data: (value) => value,
    orElse: () => AllowList.disabled,
  );
});
