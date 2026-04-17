import 'dart:io';

import 'package:beedle/foundation/logging/logger.dart';
// Les imports `objectbox.g.dart` seront générés par `build_runner`.
import 'package:beedle/objectbox.g.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Wrapper d'accès au store ObjectBox de Beedle.
///
/// Créé **une seule fois** au bootstrap (kernel provider).
class ObjectBoxStore {
  ObjectBoxStore._(this._store);

  final Store _store;

  Store get store => _store;

  /// Crée et ouvre le store dans le répertoire de l'app.
  static Future<ObjectBoxStore> create() async {
    final Log log = Log.named('ObjectBoxStore');
    final Directory docsDir = await getApplicationDocumentsDirectory();
    final String path = p.join(docsDir.path, 'beedle-db');
    log.info('Opening ObjectBox store at $path');
    final Store store = await openStore(directory: path);
    return ObjectBoxStore._(store);
  }

  void close() => _store.close();
}
