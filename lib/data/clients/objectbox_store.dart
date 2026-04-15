import 'dart:io';

import 'package:beedle/foundation/logging/logger.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Les imports `objectbox.g.dart` seront générés par `build_runner`.
// TODO-USER: après le premier build_runner, ce fichier existe.
import 'package:beedle/objectbox.g.dart';

/// Wrapper d'accès au store ObjectBox de Beedle.
///
/// Créé **une seule fois** au bootstrap (kernel provider).
class ObjectBoxStore {
  ObjectBoxStore._(this._store);

  final Store _store;

  Store get store => _store;

  /// Crée et ouvre le store dans le répertoire de l'app.
  static Future<ObjectBoxStore> create() async {
    final log = Log.named('ObjectBoxStore');
    final docsDir = await getApplicationDocumentsDirectory();
    final path = p.join(docsDir.path, 'beedle-db');
    log.info('Opening ObjectBox store at $path');
    final store = await openStore(directory: path);
    return ObjectBoxStore._(store);
  }

  void close() => _store.close();
}
