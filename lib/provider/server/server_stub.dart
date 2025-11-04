import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/provider/server/server_types.dart';

final serverProvider = FutureProvider<ServerHandle>(
  (ref) async => (server: null, port: 0),
);
