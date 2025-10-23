import 'package:novel_v3/more_libs/general_static_server/core/factory/database_factory.dart';
import 'package:novel_v3/more_libs/general_static_server/core/interfaces/database.dart';
import 'package:novel_v3/more_libs/general_static_server/core/models/tutorial.dart';

class TutorialServices {
  static final Map<String, Database<Tutorial>> _dbCache = {};

  static Database<Tutorial> get getLocalDB {
    final key = 'local';
    if (!_dbCache.containsKey(key)) {
      _dbCache[key] = DatabaseFactory.create<Tutorial>();
    }
    return _dbCache[key]!;
  }

  static Database<Tutorial> get getApiDB {
    final key = 'github';
    if (!_dbCache.containsKey(key)) {
      _dbCache[key] = DatabaseFactory.create<Tutorial>(type: DatabaseTypes.api);
    }
    return _dbCache[key]!;
  }
}
