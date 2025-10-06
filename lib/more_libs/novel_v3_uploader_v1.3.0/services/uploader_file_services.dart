import '../novel_v3_uploader.dart';

class UploaderFileServices {
  static final Map<String, DatabaseInterface<UploaderFile>> _dbCache = {};

  static void clearDBCache() {
    _dbCache.clear();
    _historyDBCache.clear();
  }

  static DatabaseInterface<UploaderFile> getLocalDatabase(String novelId) {
    final key = 'local-$novelId';
    _dbCache[key] ??= DatabaseFactory.create<UploaderFile>(
      type: DatabaseTypes.local,
      novelId: novelId,
    );
    return _dbCache[key]!;
  }

  static DatabaseInterface<UploaderFile> getApiDatabase(String novelId) {
    final key = 'api-$novelId';
    _dbCache[key] ??= DatabaseFactory.create<UploaderFile>(
      type: DatabaseTypes.api,
      novelId: novelId,
    );
    return _dbCache[key]!;
  }

  static Future<List<UploaderFile>> getLocalList({
    required String novelId,
  }) async {
    final list = await getLocalDatabase(novelId).getAll(query: {'id': novelId});
    return list;
  }

  static Future<List<UploaderFile>> getApiList({
    required String novelId,
  }) async {
    final list = await getApiDatabase(novelId).getAll(query: {'id': novelId});
    return list;
  }

  // history
  static final Map<String, DatabaseInterface<UploaderFile>> _historyDBCache =
      {};
  static DatabaseInterface<UploaderFile> get getLocalHistoryDatabase {
    final key = 'local';
    _historyDBCache[key] ??= DatabaseFactory.create<UploaderFile>(
      type: DatabaseTypes.local,
      historyDatabase: true,
    );
    return _historyDBCache[key]!;
  }

  static DatabaseInterface<UploaderFile> get getApiHistoryDatabase {
    final key = 'api';
    _historyDBCache[key] ??= DatabaseFactory.create<UploaderFile>(
      type: DatabaseTypes.api,
      historyDatabase: true,
    );
    return _historyDBCache[key]!;
  }
}
