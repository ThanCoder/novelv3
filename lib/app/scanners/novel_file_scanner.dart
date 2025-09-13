import 'dart:io';

import 'package:novel_v3/app/core/interfaces/file_scanner_interface.dart';
import 'package:novel_v3/app/novel_dir_app.dart';

class NovelFileScanner extends FileScannerInterface<Novel> {
  bool isAllCalc;

  NovelFileScanner({this.isAllCalc = false});

  @override
  void onError(String message) {
    NovelDirApp.showDebugLog(message, tag: 'NovelFileScanner');
  }

  @override
  Future<Novel?> onParseFile(FileSystemEntity file) async {
    if (file.statSync().type != FileSystemEntityType.directory) null;
    // dir ပဲယူမယ်
    final novel = Novel.fromPath(file.path);
    if (isAllCalc) {
      // တွက်ပြီးထည့်မယ်
      final descLines = await File(novel.getContentPath).readAsLines();
      novel.cacheIsExistsDesc = descLines.isNotEmpty;
      // calc all size
      novel.cacheSize = await novel.getAllSize();
    }

    return novel;
  }
}
