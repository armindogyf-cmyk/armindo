import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class LocalDatabaseService {
  Database? _db;

  Future<Database> open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'epa_forense.db'));
    _db = sqlite3.open(file.path);
    _applySchema(_db!);
    return _db!;
  }

  void _applySchema(Database db) {
    const schema = _schema;
    for (final statement in schema.split(';')) {
      final trimmed = statement.trim();
      if (trimmed.isNotEmpty) {
        db.execute('$trimmed;');
      }
    }
  }

  static const _schema = '''
CREATE TABLE IF NOT EXISTS ingest_registry (
  source_id TEXT PRIMARY KEY,
  documento_id TEXT NOT NULL,
  hash_sha256 TEXT NOT NULL,
  timestamp_ingestao TEXT NOT NULL,
  tipo_fonte TEXT NOT NULL,
  caminho_origem TEXT NOT NULL,
  processo_associado TEXT,
  estado_extracao TEXT NOT NULL
);
''';
}
