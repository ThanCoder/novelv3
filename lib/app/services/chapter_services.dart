import 'package:novel_v3/app/factorys/file_scanner_factory.dart';

import '../novel_dir_app.dart';

class ChapterServices {
  static Future<List<Chapter>> getList(String novelPath) async {
    return await FileScannerFactory.getScanner<Chapter>().getList(novelPath);
  }
}
