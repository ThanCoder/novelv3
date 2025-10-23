import '../core/index.dart';

class AppServices {
  static final Map<String, Database<App>> _dbCache = {};

  static Database<App> get getLocalDB {
    final key = 'local';
    if (!_dbCache.containsKey(key)) {
      _dbCache[key] = DatabaseFactory.create<App>();
    }
    return _dbCache[key]!;
  }

  static Database<App> get getApiDB {
    final key = 'github';
    if (!_dbCache.containsKey(key)) {
      _dbCache[key] = DatabaseFactory.create<App>(type: DatabaseTypes.api);
    }
    return _dbCache[key]!;
  }
}
