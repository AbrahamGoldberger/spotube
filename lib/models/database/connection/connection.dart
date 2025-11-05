import 'package:drift/drift.dart';

import 'native.dart' if (dart.library.html) 'web.dart';

QueryExecutor openConnection() => createExecutor();
