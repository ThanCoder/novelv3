import 'package:novel_v3/app/factorys/file_scanner_factory.dart';
import '../novel_dir_app.dart';

class NovelServices {
  static Future<List<Novel>> getList({bool isAllCalc = false}) async {
    final rootPath = FolderFileServices.getSourcePath();
    return await FileScannerFactory.getScanner<Novel>().getList(rootPath);
  }
}
