import 'dart:io';

import 'package:novel_v3/app/interfaces/file_scanner_interface.dart';
import 'package:novel_v3/app/novel_dir_app.dart';

class PdfFileScanner extends FileScannerInterface<NovelPdf> {
  @override
  void onError(String message) {
    NovelDirApp.showDebugLog(message, tag: 'PdfFileScanner');
  }

  @override
  Future<NovelPdf?> onParseFile(FileSystemEntity file) async {
    if (NovelPdf.isPdf(file.path)) {
      return NovelPdf.createPath(file.path);
    }
    return null;
  }
}
