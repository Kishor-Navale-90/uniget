import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Shared connection-opening logic so every Drift database in the
/// app — core's and every feature's — is configured identically.
///
/// On mobile/desktop this opens a native SQLite file via
/// `sqlite3_flutter_libs`. On Flutter Web, this same call is served by
/// a conditional-import counterpart (`sqlite_connection_web.dart`,
/// wired up in the app shell's build config) backed by Drift's
/// Wasm/IndexedDB executor — callers never need to know which one
/// they got, which is what lets a feature's repository code be
/// 100% platform-agnostic.
QueryExecutor openSqliteConnection(String dbName) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, '$dbName.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
