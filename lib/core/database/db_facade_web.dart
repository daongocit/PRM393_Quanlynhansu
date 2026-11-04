import 'database_adapter.dart';
import 'web_database_helper.dart';

/// Web implementation – uses in-memory data store.
DatabaseAdapter createDatabaseImpl() => WebDatabaseHelper.instance;
