import 'package:flutter/material.dart' as material;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';
import 'package:flutter_undraw/flutter_undraw.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotube/collections/fake.dart';

import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/fallbacks/anonymous_fallback.dart';
import 'package:spotube/components/fallbacks/error_box.dart';
import 'package:spotube/components/fallbacks/no_default_metadata_plugin.dart';
import 'package:spotube/config/app_config.dart';
import 'package:spotube/components/inter_scrollbar/inter_scrollbar.dart';
import 'package:spotube/components/track_tile/track_tile.dart';
import 'package:spotube/components/waypoint.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/hooks/controllers/use_shadcn_text_editing_controller.dart';
import 'package:spotube/modules/artist/artist_card.dart';
import 'package:spotube/provider/metadata_plugin/core/auth.dart';
import 'package:spotube/provider/metadata_plugin/library/artists.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/provider/curated_catalog_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:spotube/services/metadata/errors/exceptions.dart';

@RoutePage()
class UserArtistsPage extends HookConsumerWidget {
  static const name = 'user_artists';
  const UserArtistsPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    if (!metadataPluginsEnabled) {
      return const _CuratedArtistsLibrary();
    }
    final authenticated = ref.watch(metadataPluginAuthenticatedProvider);

    final artistQuery = ref.watch(metadataPluginSavedArtistsProvider);
    final artistQueryNotifier =
        ref.watch(metadataPluginSavedArtistsProvider.notifier);

    final searchText = useState('');

    final filteredArtists = useMemoized(() {
      final artists = artistQuery.asData?.value.items ?? [];

      if (searchText.value.isEmpty) {
        return artists.toList();
      }
      return artists
          .map((e) => (
                weightedRatio(e.name, searchText.value),
                e,
              ))
          .sorted((a, b) => b.$1.compareTo(a.$1))
          .where((e) => e.$1 > 50)
          .map((e) => e.$2)
          .toList();
    }, [artistQuery.asData?.value.items, searchText.value]);

    final controller = useScrollController();

    if (artistQuery.error case MetadataPluginException(:final errorCode)) {
      if (errorCode == MetadataPluginErrorCode.noDefaultPlugin ||
          errorCode == MetadataPluginErrorCode.pluginsDisabled) {
        return const Center(child: NoDefaultMetadataPlugin());
      }
    }

    if (authenticated.asData?.value != true) {
      return const AnonymousFallback();
    }

    if (artistQuery.hasError) {
      return ErrorBox(
        error: artistQuery.error!,
        onRetry: () {
          ref.invalidate(metadataPluginSavedArtistsProvider);
        },
      );
    }

    return SafeArea(
      bottom: false,
      child: Scaffold(
        child: material.RefreshIndicator.adaptive(
          onRefresh: () async {
            ref.invalidate(metadataPluginSavedArtistsProvider);
          },
          child: InterScrollbar(
            controller: controller,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CustomScrollView(
                controller: controller,
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    floating: true,
                    flexibleSpace: SizedBox(
                      height: 48,
                      child: TextField(
                        onChanged: (value) => searchText.value = value,
                        features: const [
                          InputFeature.leading(Icon(SpotubeIcons.filter)),
                        ],
                        placeholder: Text(context.l10n.filter_artist),
                      ),
                    ),
                  ),
                  const SliverGap(10),
                  if (filteredArtists.isNotEmpty || artistQuery.isLoading)
                    SliverLayoutBuilder(builder: (context, constrains) {
                      return SliverGrid.builder(
                        itemCount: filteredArtists.length + 1,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          mainAxisExtent: constrains.smAndDown ? 225 : 250,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          if (filteredArtists.isNotEmpty &&
                              index == filteredArtists.length) {
                            if (artistQuery.asData?.value.hasMore != true) {
                              return const SizedBox.shrink();
                            }

                            return Waypoint(
                              controller: controller,
                              isGrid: true,
                              onTouchEdge: artistQueryNotifier.fetchMore,
                              child: Skeletonizer(
                                enabled: true,
                                child: ArtistCard(FakeData.artist),
                              ),
                            );
                          }

                          return Skeletonizer(
                            enabled: artistQuery.isLoading,
                            child: ArtistCard(
                              filteredArtists.elementAtOrNull(index) ??
                                  FakeData.artist,
                            ),
                          );
                        },
                      );
                    })
                  else if (filteredArtists.isEmpty &&
                      searchText.value.isEmpty &&
                      !artistQuery.isLoading)
                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: [
                          Undraw(
                            height: 200 * context.theme.scaling,
                            illustration: UndrawIllustration.followMeDrone,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Text(
                            context.l10n.not_following_artists,
                            textAlign: TextAlign.center,
                          ).muted().small()
                        ],
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: [
                          Undraw(
                            height: 200 * context.theme.scaling,
                            illustration: UndrawIllustration.taken,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Text(
                            context.l10n.nothing_found,
                            textAlign: TextAlign.center,
                          ).muted().small()
                        ],
                      ),
                    ),
                  const SliverSafeArea(sliver: SliverGap(10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CuratedArtistsLibrary extends HookConsumerWidget {
  const _CuratedArtistsLibrary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(curatedCatalogProvider);
    final playlist = ref.watch(audioPlayerProvider);
    final player = ref.read(audioPlayerProvider.notifier);
    final controller = useShadcnTextEditingController();
    final searchTerm = useState('');

    useEffect(() {
      controller.text = searchTerm.value;
      return null;
    }, [searchTerm.value]);

    return catalogAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: ErrorBox(
          error: error,
          onRetry: () => ref.invalidate(curatedCatalogProvider),
        ),
      ),
      data: (catalog) {
        final query = searchTerm.value.trim().toLowerCase();
        final artists = query.isEmpty
            ? catalog.artists
            : catalog.artists
                .where(
                  (artist) => artist.artist.name
                      .toLowerCase()
                      .contains(query),
                )
                .toList();

        return SafeArea(
          bottom: false,
          child: Scaffold(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  floating: true,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: controller,
                      placeholder: Text(context.l10n.filter_artist),
                      onChanged: (value) => searchTerm.value = value,
                      features: const [
                        InputFeature.leading(Icon(SpotubeIcons.search)),
                      ],
                    ),
                  ),
                ),
                const SliverGap(12),
                if (artists.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(context.l10n.nothing_found).muted(),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final curated = artists[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Card(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12,
                            children: [
                              Text(
                                curated.artist.name,
                                style: Theme.of(context).typography.h4,
                              ),
                              ...List.generate(curated.tracks.length, (trackIndex) {
                                final track = curated.tracks[trackIndex];
                                return TrackTile(
                                  index: trackIndex,
                                  playlist: playlist,
                                  track: track,
                                  onTap: () => player.load(
                                    curated.tracks,
                                    initialIndex: trackIndex,
                                    autoPlay: true,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SliverSafeArea(sliver: SliverGap(16)),
              ],
            ),
          ),
        );
      },
    );
  }
}
