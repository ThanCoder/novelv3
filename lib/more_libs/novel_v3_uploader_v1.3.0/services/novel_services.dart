import '../novel_v3_uploader.dart';

class NovelServices {
  static final Map<String, DatabaseInterface<Novel>> _dbCache = {};
  static void clearDBCache() {
    _dbCache.clear();
  }

  static DatabaseInterface<Novel> get getLocalDatabase {
    if (_dbCache['local'] == null) {
      _dbCache['local'] = DatabaseFactory.create<Novel>(
        type: DatabaseTypes.local,
      );
    }
    return _dbCache['local']!;
  }

  static DatabaseInterface<Novel> get getApiDatabase {
    if (_dbCache['api'] == null) {
      _dbCache['api'] = DatabaseFactory.create<Novel>(type: DatabaseTypes.api);
    }
    return _dbCache['api']!;
  }

  static Future<List<Novel>> getLocalList() async {
    return await getLocalDatabase.getAll();
  }

  static Future<List<Novel>> getOnlineList() async {
    final database = getApiDatabase;
    return await database.getAll();
  }
}
