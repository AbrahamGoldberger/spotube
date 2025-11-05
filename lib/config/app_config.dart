/// Compile-time configuration flags that adjust Spotube's feature surface.
///
/// These values can be overridden using Dart defines at build time, allowing
/// downstream forks to tailor the experience without forking large chunks of
/// code. The defaults maintain Spotube's current behaviour while making it
/// easy to ship stripped-down builds (e.g. a locked down web player).
const bool _kEnablePluginsFlag =
    bool.fromEnvironment('SPOTUBE_ENABLE_PLUGINS', defaultValue: false);

/// When `true`, Spotube enforces an allow-list of artists/tracks loaded from
/// [kAllowListAssetPath]. This is disabled by default so the upstream project
/// keeps its current behaviour.
const bool artistAllowListEnabled = bool.fromEnvironment(
  'SPOTUBE_ENFORCE_ARTIST_ALLOW_LIST',
  defaultValue: true,
);

/// The asset that stores the allow-list configuration. Forks can override this
/// via `--dart-define` without touching the source tree.
const String kAllowListAssetPath = String.fromEnvironment(
  'SPOTUBE_ALLOW_LIST_ASSET',
  defaultValue: 'assets/config/allowlist.json',
);

/// The curated catalog that powers metadata-free builds.
const String kCuratedCatalogAssetPath = String.fromEnvironment(
  'SPOTUBE_CURATED_CATALOG_ASSET',
  defaultValue: 'assets/config/curated_catalog.json',
);

/// Whether the metadata plugin runtime should be available. Forks can turn
/// this off via `SPOTUBE_ENABLE_PLUGINS=false` to ship a build with a
/// hard-coded metadata source.
final bool metadataPluginsEnabled = _kEnablePluginsFlag;
