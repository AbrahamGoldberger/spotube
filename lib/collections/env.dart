import 'package:flutter/foundation.dart';
import 'package:spotube/utils/platform.dart';

enum ReleaseChannel {
  nightly,
  stable,
}

class Env {
  Env._();

  static final String lastFmApiKey =
      _stringFromEnvironment('LASTFM_API_KEY');

  static final String lastFmApiSecret =
      _stringFromEnvironment('LASTFM_API_SECRET');

  static final bool hideDonations = _boolishFromEnvironment(
    name: 'HIDE_DONATIONS',
    defaultValue: false,
  );

  static final ReleaseChannel releaseChannel = _releaseChannelFromString(
    _stringFromEnvironment('RELEASE_CHANNEL', fallback: 'nightly'),
  );

  static final bool enableUpdateChecker = kIsFlatpak ||
      _boolishFromEnvironment(
        name: 'ENABLE_UPDATE_CHECK',
        defaultValue: true,
      );

  static const String discordAppId = '1176718791388975124';

  static String _stringFromEnvironment(String name, {String fallback = ''}) {
    const valueFromEnv = String.fromEnvironment(name);
    return valueFromEnv.isNotEmpty ? valueFromEnv : fallback;
  }

  static bool _boolishFromEnvironment({
    required String name,
    required bool defaultValue,
  }) {
    final raw = _stringFromEnvironment(
      name,
      fallback: defaultValue ? '1' : '0',
    ).toLowerCase();
    return raw == '1' || raw == 'true';
  }

  static ReleaseChannel _releaseChannelFromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'stable':
        return ReleaseChannel.stable;
      default:
        return ReleaseChannel.nightly;
    }
  }
}
