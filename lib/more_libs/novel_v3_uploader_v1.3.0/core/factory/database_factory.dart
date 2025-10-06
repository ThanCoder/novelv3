import '../../novel_v3_uploader.dart';

class DatabaseFactory {
  static DatabaseInterface<T> create<T>({
    required DatabaseTypes type,
    String? novelId,
    bool historyDatabase = false,
  }) {
    if (T == Novel) {
      switch (type) {
        case DatabaseTypes.local:
          return LocalNovelDatabase() as DatabaseInterface<T>;
        case DatabaseTypes.api:
          return ApiNovelDatabase() as DatabaseInterface<T>;
      }
    }

    if (T == UploaderFile && !historyDatabase) {
      switch (type) {
        case DatabaseTypes.local:
          if (novelId == null) {
            throw UnsupportedError('T: `$T` Database Needed NovleId!');
          }
          return LocalUploaderFileDatabase(novelId) as DatabaseInterface<T>;
        case DatabaseTypes.api:
          return ApiUploaderFileDatabase() as DatabaseInterface<T>;
      }
    }
    // history
    if (T == UploaderFile && historyDatabase) {
      switch (type) {
        case DatabaseTypes.local:
          return LocalUploaderFileHistoryDatabase() as DatabaseInterface<T>;
        case DatabaseTypes.api:
          return ApiUploaderFileHistoryDatabase() as DatabaseInterface<T>;
      }
    }

    throw UnsupportedError('T: `$T` Not Supported Database!');
  }
}

enum DatabaseTypes { local, api }
