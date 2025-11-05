import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/models/metadata/metadata.dart';
import 'package:spotube/services/download_manager/download_status.dart';
import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/sourced_track.dart';

class DownloadManagerProvider extends ChangeNotifier {
  DownloadManagerProvider({required this.ref});

  final Ref<DownloadManagerProvider> ref;

  Future<bool> Function(SpotubeFullTrackObject track) onFileExists =
      (_) async => true;

  String get downloadDirectory => '';

  SourceCodecs get downloadCodec => SourceCodecs.m4a;

  int get $downloadCount => 0;

  final Set<SpotubeFullTrackObject> $backHistory = {};

  bool isActive(SpotubeFullTrackObject track) => false;

  Future<void> addToQueue(SpotubeFullTrackObject track) async {}

  Future<void> batchAddToQueue(List<SpotubeFullTrackObject> tracks) async {}

  Future<void> removeFromQueue(SpotubeFullTrackObject track) async {}

  Future<void> pause(SpotubeFullTrackObject track) async {}

  Future<void> resume(SpotubeFullTrackObject track) async {}

  Future<void> retry(SpotubeFullTrackObject track) async {}

  void cancel(SpotubeFullTrackObject track) {}

  void cancelAll() {}

  Future<SourcedTrack> mapToSourcedTrack(SpotubeFullTrackObject track) {
    return Future.error(
      UnsupportedError('Track downloads are not supported on the web build.'),
    );
  }

  ValueNotifier<DownloadStatus>? getStatusNotifier(
    SpotubeFullTrackObject track,
  ) {
    return null;
  }

  ValueNotifier<double>? getProgressNotifier(SpotubeFullTrackObject track) {
    return null;
  }
}

final downloadManagerProvider = ChangeNotifierProvider<DownloadManagerProvider>(
  (ref) => DownloadManagerProvider(ref: ref),
);
