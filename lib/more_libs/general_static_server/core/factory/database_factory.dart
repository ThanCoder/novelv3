import 'package:novel_v3/more_libs/general_static_server/core/databases/tutorial_api_database.dart';
import 'package:novel_v3/more_libs/general_static_server/core/databases/tutorial_local_database.dart';
import 'package:novel_v3/more_libs/general_static_server/core/models/tutorial.dart';

import '../index.dart';

class DatabaseFactory {
  static Database<T> create<T>({
    DatabaseTypes type = DatabaseTypes.local,
    bool isUseCacheList = true,
  }) {
    if (type == DatabaseTypes.local) {
      if (T == App) {
        return AppJsonDatabase() as Database<T>;
      }
      if (T == Tutorial) {
        return TutorialLocalDatabase(isUseCacheList: isUseCacheList)
            as Database<T>;
      }
    }
    if (type == DatabaseTypes.api) {
      if (T == App) {
        return AppApiDatabase() as Database<T>;
      }
      if (T == Tutorial) {
        return TutorialApiDatabase() as Database<T>;
      }
    }

    throw UnsupportedError('$T: Not Supported Database');
  }
}
