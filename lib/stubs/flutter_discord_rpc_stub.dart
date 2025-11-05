import 'dart:async';

class FlutterDiscordRPC {
  FlutterDiscordRPC._();

  static final FlutterDiscordRPC instance = FlutterDiscordRPC._();

  static Future<void> initialize(String appId) async {}

  Stream<bool> get isConnectedStream => const Stream<bool>.empty();

  bool get isConnected => false;

  Future<void> dispose() async {}

  Future<void> connect({bool autoRetry = false}) async {}

  Future<void> setActivity({RPCActivity? activity}) async {}

  Future<void> clearActivity() async {}

  Future<void> disconnect() async {}
}

class RPCActivity {
  const RPCActivity({
    this.details,
    this.state,
    this.assets,
    this.buttons = const <RPCButton>[],
    this.timestamps,
    this.activityType,
  });

  final String? details;
  final String? state;
  final RPCAssets? assets;
  final List<RPCButton> buttons;
  final RPCTimestamps? timestamps;
  final ActivityType? activityType;
}

class RPCAssets {
  const RPCAssets({
    this.largeImage,
    this.largeText,
    this.smallImage,
    this.smallText,
  });

  final String? largeImage;
  final String? largeText;
  final String? smallImage;
  final String? smallText;
}

class RPCButton {
  const RPCButton({required this.label, required this.url});

  final String label;
  final String url;
}

class RPCTimestamps {
  const RPCTimestamps({this.start, this.end});

  final int? start;
  final int? end;
}

enum ActivityType { playing, streaming, listening, watching, competing }
