import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/models/metadata/metadata.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';

class WindowsAudioService {
  WindowsAudioService(Ref ref, AudioPlayerNotifier audioPlayerNotifier);

  Future<void> addTrack(SpotubeTrackObject track) async {}

  void dispose() {}
}
