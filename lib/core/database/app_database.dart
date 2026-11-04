import 'database_adapter.dart';

// Conditional imports: web vs native
import 'db_facade_stub.dart'
    if (dart.library.html) 'db_facade_web.dart'
    if (dart.library.io) 'db_facade_native.dart' as platform_db;

/// A unified facade so the rest of the app can just use `AppDatabase.instance`.
/// On web → WebDatabaseHelper (in-memory); on native → DatabaseHelper (sqflite).
class AppDatabase {
  static final DatabaseAdapter instance = platform_db.createDatabaseImpl();
}
