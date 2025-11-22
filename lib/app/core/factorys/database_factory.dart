import 'package:novel_v3/app/core/interfaces/index.dart';
import 'package:novel_v3/app/core/types/database_types.dart';

class DatabaseFactory {
  static Database<T> create<T>({required DatabaseTypes type}) {
    if (type == DatabaseTypes.folder) {
      // if (T == Novel) {
      //   return NovelFolderDatabase() as Database<T>;
      // }
    }

    throw Exception('`T` Database Not Supported');
  }
}
