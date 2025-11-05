import 'package:flutter/foundation.dart';
import 'package:spotube/utils/platform.dart';

enum ReleaseChannel {
  nightly,
  stable,
}

class Env {
  Env._();

  static const _lastFmApiKey = String.fromEnvironment('LASTFM_API_KEY');
  static const _lastFmApiSecret = String.fromEnvironment('LASTFM_API_SECRET');
  static const _hideDonationsRaw = String.fromEnvironment('HIDE_DONATIONS');
  static const _releaseChannelRaw = String.fromEnvironment('RELEASE_CHANNEL');
  static const _enableUpdateCheckRaw =
      String.fromEnvironment('ENABLE_UPDATE_CHECK');

  static String get lastFmApiKey => _stringWithFallback(_lastFmApiKey, '');

  static String get lastFmApiSecret =>
      _stringWithFallback(_lastFmApiSecret, '');

  static bool get hideDonations => _boolishFromEnvironment(
        rawValue: _hideDonationsRaw,
        defaultValue: false,
      );

  static ReleaseChannel get releaseChannel => _releaseChannelFromString(
        _stringWithFallback(_releaseChannelRaw, 'nightly'),
      );

  static bool get enableUpdateChecker => kIsFlatpak ||
      _boolishFromEnvironment(
        rawValue: _enableUpdateCheckRaw,
        defaultValue: true,
      );

  static const String discordAppId = '1176718791388975124';

  static String _stringWithFallback(String raw, String fallback) {
    return raw.isNotEmpty ? raw : fallback;
  }

  static bool _boolishFromEnvironment({
    required String rawValue,
    required bool defaultValue,
  }) {
    final normalized = rawValue.isEmpty
        ? (defaultValue ? '1' : '0')
        : rawValue.toLowerCase();
    return normalized == '1' || normalized == 'true';
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
