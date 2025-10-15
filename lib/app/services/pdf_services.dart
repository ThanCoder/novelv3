import 'package:novel_v3/app/core/factorys/all_file_scanner_factory.dart';
import 'package:novel_v3/app/core/factorys/file_scanner_factory.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:than_pkg/than_pkg.dart';

import '../ui/novel_dir_app.dart';

class PdfServices {
  static Future<List<NovelPdf>> getScanList() async {
    return await AllFileScannerFactory.getScanner<NovelPdf>().scanList();
  }

  static Future<List<NovelPdf>> getList(String novelPath) async {
    return await FileScannerFactory.getScanner<NovelPdf>().getList(novelPath);
  }

  // recent db
  static TRecentDB? _recentDB;
  static void initRecentDB() {
    getRecentDB;
  }

  static TRecentDB get getRecentDB {
    _recentDB ??= TRecentDB()
      ..init(rootPath: PathUtil.getDatabasePath(name: 'pdf.recent.db.json'));
    return _recentDB!;
  }

  static Future<void> setRecent({
    required String novelId,
    required String pdfName,
  }) async {
    await getRecentDB.putString(novelId, pdfName);
  }

  static String getRecent({required String novelId}) {
    return getRecentDB.getString(novelId);
  }

  static bool isExistsRecent({
    required String novelId,
    required String pdfName,
  }) {
    final res = getRecent(novelId: novelId);
    if (res.isNotEmpty && res == pdfName) {
      return true;
    }
    return false;
  }
}
