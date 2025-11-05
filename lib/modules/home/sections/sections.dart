import 'package:auto_route/auto_route.dart';
import 'package:flutter_undraw/flutter_undraw.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:spotube/collections/routes.gr.dart';
import 'package:spotube/components/fallbacks/error_box.dart';
import 'package:spotube/components/fallbacks/no_default_metadata_plugin.dart';
import 'package:spotube/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:spotube/config/app_config.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/components/track_tile/track_tile.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/provider/curated_catalog_provider.dart';
import 'package:spotube/provider/metadata_plugin/browse/sections.dart';
import 'package:spotube/provider/metadata_plugin/utils/common.dart';
import 'package:spotube/services/metadata/errors/exceptions.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class HomePageBrowseSection extends HookConsumerWidget {
  const HomePageBrowseSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    if (!metadataPluginsEnabled) {
      return const _CuratedHomeCatalog();
    }
    final browseSections = ref.watch(metadataPluginBrowseSectionsProvider);
    final sections = browseSections.asData?.value.items;
    final ThemeData(:colorScheme) = Theme.of(context);

    if (browseSections.isLoading) {
      return SliverToBoxAdapter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Undraw(
              height: 200,
              illustration: UndrawIllustration.process,
              color: colorScheme.primary,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                const CircularProgressIndicator(),
                Text(context.l10n.building_your_timeline).muted,
              ],
            ),
            const Gap(16),
          ],
        ),
      );
    }

    if (browseSections.error case MetadataPluginException(:final errorCode)) {
      if (errorCode == MetadataPluginErrorCode.noDefaultPlugin ||
          errorCode == MetadataPluginErrorCode.pluginsDisabled) {
        return const SliverFillRemaining(
          child: Center(child: NoDefaultMetadataPlugin()),
        );
      }
    }

    if (browseSections.hasError) {
      return SliverFillRemaining(
        child: Center(
          child: ErrorBox(
            error: browseSections.error!,
            onRetry: () {
              ref.invalidate(metadataPluginBrowseSectionsProvider);
            },
          ),
        ),
      );
    }

    return SliverInfiniteList(
      hasReachedMax: browseSections.asData?.value.hasMore == false,
      isLoading: !browseSections.isLoading && browseSections.isLoadingNextPage,
      onFetchData: () {
        ref.read(metadataPluginBrowseSectionsProvider.notifier).fetchMore();
      },
      itemCount: sections?.length ?? 0,
      itemBuilder: (context, index) {
        final section = sections![index];
        if (section.items.isEmpty) return const SizedBox.shrink();

        return HorizontalPlaybuttonCardView(
          items: section.items,
          title: Text(section.title),
          hasNextPage: false,
          isLoadingNextPage: false,
          onFetchMore: () {},
          titleTrailing: section.browseMore
              ? Button.text(
                  child: Text(context.l10n.browse_all),
                  onPressed: () {
                    context.navigateTo(
                      HomeBrowseSectionItemsRoute(
                        sectionId: section.id,
                        section: section,
                      ),
                    );
                  },
                )
              : null,
        );
      },
    );
  }
}

class _CuratedHomeCatalog extends HookConsumerWidget {
  const _CuratedHomeCatalog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(curatedCatalogProvider);
    final playlist = ref.watch(audioPlayerProvider);
    final player = ref.read(audioPlayerProvider.notifier);
    final theme = Theme.of(context);

    return catalogAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => SliverFillRemaining(
        child: Center(
          child: ErrorBox(
            error: error,
            onRetry: () => ref.invalidate(curatedCatalogProvider),
          ),
        ),
      ),
      data: (catalog) {
        if (catalog.artists.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(context.l10n.no_tracks).muted(),
            ),
          );
        }

        return SliverList.builder(
          itemCount: catalog.artists.length,
          itemBuilder: (context, index) {
            final curatedArtist = catalog.artists[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      curatedArtist.artist.name,
                      style: theme.typography.h4,
                    ),
                    Text(context.l10n.top_tracks).muted(),
                    ...List.generate(curatedArtist.tracks.length, (trackIndex) {
                      final track = curatedArtist.tracks[trackIndex];
                      return TrackTile(
                        index: trackIndex,
                        playlist: playlist,
                        track: track,
                        onTap: () => player.load(
                          curatedArtist.tracks,
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
        );
      },
    );
  }
}
