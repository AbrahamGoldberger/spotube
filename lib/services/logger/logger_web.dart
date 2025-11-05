import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static late final Logger log;

  static void initialize(bool verbose) {
    log = Logger(level: kDebugMode || (verbose && kReleaseMode) ? Level.all : Level.info);
  }

  static R? runZoned<R>(R Function() body) {
    return runZonedGuarded(body, (error, stackTrace) {
      reportError(error, stackTrace);
    });
  }

  static Future<void> reportError(
    dynamic error, [
    StackTrace? stackTrace,
    String message = '',
  ]) async {
    log.e(message, error: error, stackTrace: stackTrace);
  }
}

class AppLoggerProviderObserver extends ProviderObserver {
  const AppLoggerProviderObserver();

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.reportError(error, stackTrace);
  }
}
