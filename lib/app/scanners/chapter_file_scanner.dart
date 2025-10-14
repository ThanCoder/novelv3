import 'dart:io';

import 'package:novel_v3/app/ui/novel_dir_app.dart';

import '../core/interfaces/file_scanner_interface.dart';

class ChapterFileScanner extends FileScannerInterface<Chapter> {
  @override
  void onError(String message) {
    NovelDirApp.showDebugLog(message);
  }

  @override
  Future<Chapter?> onParseFile(FileSystemEntity file) async {
    if (Chapter.isChapter(file.path)) {
      return Chapter.createPath(file.path);
    }
    return null;
  }
}
