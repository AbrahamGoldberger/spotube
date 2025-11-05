import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/config/app_config.dart';
import 'package:spotube/provider/metadata_plugin/library/playlists.dart';
import 'package:spotube/provider/metadata_plugin/core/user.dart';

bool useIsUserPlaylist(WidgetRef ref, String playlistId) {
  if (!metadataPluginsEnabled) {
    return false;
  }
  final userPlaylistsQuery = ref.watch(metadataPluginSavedPlaylistsProvider);
  final me = ref.watch(metadataPluginUserProvider);

  return useMemoized(
    () =>
        userPlaylistsQuery.asData?.value.items.any((e) =>
            e.id == playlistId &&
            me.asData?.value != null &&
            e.owner.id == me.asData?.value?.id) ??
        false,
    [userPlaylistsQuery.asData?.value, playlistId, me.asData?.value],
  );
}
