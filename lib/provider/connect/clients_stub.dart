import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class BonsoirService {
  final String name;
  final Map<String, String> attributes;

  BonsoirService({required this.name, this.attributes = const {}});

  Future<void> resolve([dynamic _]) async {}
}

class ResolvedBonsoirService extends BonsoirService {
  final String host;
  final int port;

  ResolvedBonsoirService({
    required super.name,
    this.host = '',
    this.port = 0,
    super.attributes = const {},
  });
}

class BonsoirDiscovery {
  const BonsoirDiscovery();

  Stream<dynamic>? get eventStream => const Stream.empty();
  Future<void> get ready async {}
  dynamic get serviceResolver => null;

  Future<void> start() async {}
  Future<void> stop() async {}
}

class ConnectClientsState {
  final List<BonsoirService> services;
  final ResolvedBonsoirService? resolvedService;
  final BonsoirDiscovery discovery;

  const ConnectClientsState({
    this.services = const [],
    this.resolvedService,
    this.discovery = const BonsoirDiscovery(),
  });

  ConnectClientsState copyWith({
    List<BonsoirService>? services,
    BonsoirDiscovery? discovery,
    ResolvedBonsoirService? resolvedService,
  }) {
    return ConnectClientsState(
      services: services ?? this.services,
      discovery: discovery ?? this.discovery,
      resolvedService: resolvedService ?? this.resolvedService,
    );
  }
}

class ConnectClientsNotifier extends AsyncNotifier<ConnectClientsState> {
  @override
  FutureOr<ConnectClientsState> build() {
    return const ConnectClientsState();
  }

  Future<void> resolveService(BonsoirService service) async {}

  Future<void> clearResolvedService() async {}
}

final connectClientsProvider =
    AsyncNotifierProvider<ConnectClientsNotifier, ConnectClientsState>(
  ConnectClientsNotifier.new,
);
