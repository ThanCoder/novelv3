import 'package:novel_v3/app/core/factorys/all_file_scanner_factory.dart';
import 'package:novel_v3/app/core/factorys/file_scanner_factory.dart';

import '../novel_dir_app.dart';

class PdfServices {
  static Future<List<NovelPdf>> getScanList() async {
    return await AllFileScannerFactory.getScanner<NovelPdf>().scanList();
  }

  static Future<List<NovelPdf>> getList(String novelPath) async {
    return await FileScannerFactory.getScanner<NovelPdf>().getList(novelPath);
  }
}
